#!/bin/bash

echo "--------- Start ubuntu-20.04-apt-lock-fix.sh"

#!/bin/bash

echo 'DPkg::Lock::Timeout "900";' > /etc/apt/apt.conf.d/99-dpkg-timeout

apt-get remove -y unattended-upgrades

wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | apt-key add -

echo "--------- End ubuntu-20.04-apt-lock-fix.sh"

echo "--------- Start strigo.sh"

#!/bin/bash

hostnamectl set-hostname '{{ .STRIGO_RESOURCE_NAME }}'
sed --in-place "0,/^127.0.0.1/s/$/ $(hostnamectl status --static) $(hostnamectl status --static).zenika.labs.strigo.io/" /etc/hosts

apt-get update
apt-get install -y cloud-guest-utils

cat <<\EOF > /etc/profile.d/00_strigo_context.sh
export INSTANCE_NAME='{{ .STRIGO_RESOURCE_NAME }}'
export PUBLIC_DNS={{ .STRIGO_RESOURCE_DNS }}
export PUBLIC_IP=$(ec2metadata --public-ipv4)
export PRIVATE_DNS={{ .STRIGO_RESOURCE_DNS }}
export PRIVATE_IP=$(ec2metadata --local-ipv4)
export HOSTNAME='{{ .STRIGO_RESOURCE_NAME }}'
EOF
. /etc/profile.d/00_strigo_context.sh

echo "--------- End strigo.sh"

echo "--------- Start docker.sh"

#!/bin/bash

dpkg --purge docker docker-engine docker.io containerd runc
apt-get autoremove --purge -y
apt-get update
apt-get install -y \
    jq \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

docker_base_settings='{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "5k",
    "max-file": "3",
    "compress": "true"
  }
}'
echo "${docker_base_settings}" "${docker_extra_settings:-{\}}" | jq --slurp '.[0] * .[1]' > /etc/docker/daemon.json
systemctl restart docker

usermod -aG docker ubuntu
loginctl terminate-user ubuntu

echo "--------- End docker.sh"

echo "--------- Start tls-certificate.sh"
ZEROSSL_EAB_KID="d3GmAeDzGx3v9UI3ZUgOlQ"
ZEROSSL_EAB_HMAC_KEY="Nn90w7WR3RUjsrdlB0IJnes94SWhcuAyvndk0YPczKw7dJDS4esHz42Ng4tM4kEDQzaBzccNLyKqc4WD9xb_EQ"
#!/bin/bash

apt-get update
apt-get install -y --no-install-recommends certbot acl

if [[ -n "${ZEROSSL_EAB_KID}" && -n "${ZEROSSL_EAB_HMAC_KEY}" ]]; then
  # https://github.com/zerossl/zerossl-bot/blob/master/zerossl-bot.sh
  ZEROSSL_OPTS="--eab-kid ${ZEROSSL_EAB_KID} --eab-hmac-key ${ZEROSSL_EAB_HMAC_KEY} --server https://acme.zerossl.com/v2/DV90"
fi
certbot certonly --non-interactive --agree-tos --register-unsafely-without-email \
   ${ZEROSSL_OPTS} \
  --standalone --cert-name labs.strigo.io --domain '{{ .STRIGO_RESOURCE_DNS }}' || true

if [ ! -f /etc/letsencrypt/live/labs.strigo.io/privkey.pem ]; then
  # Fallback to self-signed certificate
  mkdir -p /etc/letsencrypt/{live,archive}/labs.strigo.io/
  openssl req -newkey rsa:2048 -x509 -days 7 -nodes \
    -subj "/CN={{ .STRIGO_RESOURCE_DNS }}" \
    -addext "subjectAltName=DNS:{{ .STRIGO_RESOURCE_DNS }},IP:${PUBLIC_IP:-127.0.0.1}" \
    -addext "keyUsage=critical,digitalSignature,keyEncipherment" \
    -addext "extendedKeyUsage=serverAuth,clientAuth" \
    -addext "certificatePolicies=2.23.140.1.2.1" \
    -keyout /etc/letsencrypt/archive/labs.strigo.io/privkey.pem \
    -out /etc/letsencrypt/archive/labs.strigo.io/cert.pem
  cp /etc/letsencrypt/archive/labs.strigo.io/cert.pem /etc/letsencrypt/archive/labs.strigo.io/chain.pem
  cp /etc/letsencrypt/archive/labs.strigo.io/cert.pem /etc/letsencrypt/archive/labs.strigo.io/fullchain.pem
  ln -s /etc/letsencrypt/archive/labs.strigo.io/* /etc/letsencrypt/live/labs.strigo.io/
fi

setfacl --modify user:ubuntu:rX /etc/letsencrypt/{live,archive}
setfacl --modify user:ubuntu:rX /etc/letsencrypt/archive/labs.strigo.io/privkey*.pem

cat <<\EOF > /etc/profile.d/tls_certificate.sh
export TLS_PRIVKEY=/etc/letsencrypt/live/labs.strigo.io/privkey.pem
export TLS_CERT=/etc/letsencrypt/live/labs.strigo.io/cert.pem
export TLS_CHAIN=/etc/letsencrypt/live/labs.strigo.io/chain.pem
export TLS_FULLCHAIN=/etc/letsencrypt/live/labs.strigo.io/fullchain.pem
EOF
. /etc/profile.d/tls_certificate.sh

echo "--------- End tls-certificate.sh"

echo "--------- Start code-server.sh"
code_server_settings="{\"telemetry.telemetryLevel\": \"off\", \"files.exclude\": { \"**/.*\": true }, \"vs-kubernetes\": { \"disable-linters\": [ \"resource-limits\" ] }, \"yaml.schemas\": { \"kubernetes\": [\"*.yml\"] }}"
code_server_extensions="ms-kubernetes-tools.vscode-kubernetes-tools oderwat.indent-rainbow tomoki1207.pdf"
code_server_tls_key_path="${TLS_PRIVKEY}"
code_server_tls_cert_path="${TLS_FULLCHAIN}"
#!/bin/bash

set -e

apt-get update
apt-get install -y curl jq
last_code_server_release=$(curl -sL -H "Accept: application/vnd.github.v3+json" https://api.github.com/repos/coder/code-server/releases/latest | grep -Po '/code-server/releases/tag/v\K[^"]*')
code_server_version=${code_server_version:-${last_code_server_release}}
curl -fsSLo /tmp/code-server.deb "https://github.com/coder/code-server/releases/download/v${code_server_version}/code-server_${code_server_version}_amd64.deb"
apt-get install -y /tmp/code-server.deb

mkdir --parent /home/ubuntu/.config/code-server/
cat << EOF > /home/ubuntu/.config/code-server/config.yaml
bind-addr: {{ .STRIGO_RESOURCE_DNS }}:${code_server_port:-9999}
auth: password
password: '{{ .STRIGO_WORKSPACE_ID }}'
disable-telemetry: true
EOF
if [ -n "${code_server_tls_cert_path}" ] && [ -n "${code_server_tls_key_path}" ]; then
  cat << EOF >> /home/ubuntu/.config/code-server/config.yaml
cert: ${code_server_tls_cert_path}
cert-key: ${code_server_tls_key_path}
EOF
elif [ -n "${code_server_tls_cert_path}" ] || [ -n "${code_server_tls_chain_path}" ]; then
  echo "One of TLS key or cert is missing, skipping TLS configuration" >&2
fi
chown -R ubuntu: /home/ubuntu/.config/

systemctl enable --now code-server@ubuntu

cat <<\EOF > /etc/profile.d/code-server-terminal.sh
if [ "$USER" = "ubuntu" ]; then
  echo -ne '\nCode-server '
  grep '^password:' ~/.config/code-server/config.yaml
  echo
fi
EOF

if [ "{{ .STRIGO_USER_EMAIL }}" = "{{ .STRIGO_EVENT_HOST_EMAIL }}" ]; then
  # defines the message about the code-server version
  if [ "${code_server_version}" = "${last_code_server_release}" ]; then
      code_server_version_message="The last release version of code server is installed (${last_code_server_release})"
  else
      code_server_version_message="!!! Version ${code_server_version} of code server is installed, but a newer release exists (${last_code_server_release})"
  fi

  cat << EOF >> /etc/profile.d/code-server-terminal.sh
if [ "\$USER" = "ubuntu" ]; then
  echo -e "${code_server_version_message}. Trainees do not see this message."
fi
EOF
fi

if [[ ${code_server_extensions} && ${code_server_extensions-_} ]]; then
  code_server_extensions_array=($code_server_extensions)
  for code_server_extension in ${code_server_extensions_array[@]}; do
    sudo -iu ubuntu code-server --install-extension ${code_server_extension}

    if [ "${code_server_extension}" = "coenraads.bracket-pair-colorizer-2" ]; then
      # fixes bracket colorization (https://github.com/coder/code-server/issues/544#issuecomment-776139127) until code-server 3.11?
      sudo ln -s /usr/lib/code-server/lib/vscode/node_modules /usr/lib/code-server/lib/vscode/node_modules.asar
    fi
  done
fi

code_server_base_settings='{
  "workbench.startupEditor": "none",
  "security.workspace.trust.enabled": false,
  "telemetry.enableTelemetry": false,
  "telemetry.telemetryLevel": "off",
  "files.exclude": {
    "**/.*": { "when": ".bashrc" }
  }
}'
mkdir --parent /home/ubuntu/.local/share/code-server/User/
echo "${code_server_base_settings}" "${code_server_settings:-{\}}" | jq --slurp '.[0] * .[1]' > /home/ubuntu/.local/share/code-server/User/settings.json
chown -R ubuntu: /home/ubuntu/.local/

loginctl terminate-user ubuntu

echo "--------- End code-server.sh"

echo "--------- Start http-server.sh"

#!/usr/bin/env sh

apt-get update
apt-get install -y --no-install-recommends python3

sudo -u ubuntu mkdir --parent ~ubuntu/public/

cat << EOF > /lib/systemd/system/http-server@.service
[Unit]
Description=Simple static public web server
After=network.target

[Service]
Type=exec
ExecStart=/usr/bin/python3 -m http.server ${http_server_port:-9997} --directory /home/%i/public/
Restart=always
User=%i

[Install]
WantedBy=default.target
EOF
systemctl enable --now http-server@ubuntu

echo "--------- End http-server.sh"

echo "--------- Start materials-helper.sh"

#!/bin/bash

apt-get update
apt-get install -y --no-install-recommends unzip python3 python3-pip
pip3 install gdown==5.1.0

GDOWN_RETRY_MAX=5

function gdown {
  local retries=${GDOWN_RETRY_MAX}
  until [ ${retries} -lt 1 ]; do
    if command gdown $@; then
      break
    fi
    retries=$(( retries - 1 ))
    echo "gdown failed, retrying in 1 seconds..." >&2
    sleep 1
  done
  if [ ${retries} -lt 1 ]; then
    echo "gdown failed ${GDOWN_RETRY_MAX} times, giving up." >&2
    return 1
  fi
}

echo "--------- End materials-helper.sh"

echo "--------- Start Installation/strigo/init_kubernetes.sh"
#!/bin/bash

apt-get update
apt-get install -y \
    curl \
    socat \
    software-properties-common \
    zip \
    jq \
    conntrack \
    tree

apt-get remove -y command-not-found

mkdir -p /usr/local/bin/

curl -fsSLo /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 \
  && chmod +x /usr/local/bin/yq

KUBERNETES_VERSION=1.30.0
curl -fsSLo /usr/local/bin/kubectl https://dl.k8s.io/release/v${KUBERNETES_VERSION}/bin/linux/amd64/kubectl \
  && chmod +x /usr/local/bin/kubectl
kubectl completion bash > /etc/bash_completion.d/kubectl
kubectl version --client

curl -fsSLo /usr/local/bin/minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 \
  && chmod +x /usr/local/bin/minikube
minikube completion bash > /etc/bash_completion.d/minikube
minikube version

cat <<EOF > /etc/profile.d/minikube.sh
export MINIKUBE_DRIVER=docker
export MINIKUBE_WANTUPDATENOTIFICATION=false
export MINIKUBE_WANTREPORTERRORPROMPT=false
export MINIKUBE_IN_STYLE=true
export MINIKUBE_KUBERNETES_VERSION=${KUBERNETES_VERSION}

alias k='kubectl'
EOF
echo 'complete -o default -F __start_kubectl k' >> /etc/bash_completion.d/minikube

curl -fsSL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
helm completion bash > /etc/bash_completion.d/helm
helm version

(
  set -x; cd "$(mktemp -d)" &&
  OS="$(uname | tr '[:upper:]' '[:lower:]')" &&
  ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" &&
  KREW="krew-${OS}_${ARCH}" &&
  curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" &&
  tar zxvf "${KREW}.tar.gz" &&
  mv "$KREW" /usr/local/bin/kubectl-krew
  rm -f "${KREW}.tar.gz"
)
echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> /home/ubuntu/.bashrc

sudo -u ubuntu kubectl-krew install ctx ns
cat <<EOF >> /home/ubuntu/.bashrc
alias kubens='kubectl ns'
alias kubectx='kubectl ctx'
alias k=kubectl
EOF

curl -o /tmp/k9s.tar.gz -L https://github.com/derailed/k9s/releases/latest/download/k9s_Linux_amd64.tar.gz
tar -xvzf /tmp/k9s.tar.gz -C /tmp/
mv /tmp/k9s /usr/local/bin/

apt-get install -y source-highlight
echo "export LESSOPEN='|/usr/share/source-highlight/src-hilite-lesspipe.sh %s'
export LESS='RN'" >> /home/ubuntu/.bashrc
echo 'yaml = yaml.lang
yml = yaml.lang' >> /usr/share/source-highlight/lang.map
curl -fsSLo /usr/share/source-highlight/yaml.lang https://git.savannah.gnu.org/cgit/src-highlite.git/plain/src/yaml.lang

pip install yamllint
echo 'export PATH="/home/ubuntu/.local/bin:$PATH"' >> /home/ubuntu/.bashrc
mkdir -p /home/ubuntu/.config/yamllint
cat <<EOF >> /home/ubuntu/.config/yamllint/config
extends: relaxed

rules:
  line-length: disable
EOF

sed --in-place 's/^#force_color_prompt=yes/force_color_prompt=yes/' /home/ubuntu/.bashrc
curl -fsSLo /etc/bash_completion.d/kube-ps1 https://github.com/jonmosco/kube-ps1/raw/master/kube-ps1.sh
echo 'PS1='\''${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\] $(kube_ps1)\$ '\''' >> /home/ubuntu/.bashrc

git clone https://github.com/Yggdroot/indentLine.git /home/ubuntu/.vim/pack/vendor/start/indentLine
sudo -u ubuntu -- vim -u NONE -c "helptags  ~/.vim/pack/vendor/start/indentLine/doc" -c "q"

cat <<EOF >> /home/ubuntu/.vimrc
set paste
set background=dark
set number
set listchars=tab:!·,trail:·
set invlist
highlight CursorLine   cterm=NONE ctermbg=darkblue ctermfg=white
set cursorline
set expandtab
set sw=2
set ts=2
set scrolloff=5
set sts=2
let g:indentLine_char = '⦙'
EOF
cat <<EOF >> /home/ubuntu/.bashrc
alias pres='vim -c "setl filetype=yaml" -'
EOF

chown -R ubuntu:ubuntu /home/ubuntu/.vimrc /home/ubuntu/.config /home/ubuntu/.vim

killall -9 /home/ubuntu/.strigo/tmux
rm -f /home/ubuntu/tmux-*

echo "--------- End Installation/strigo/init_kubernetes.sh"
