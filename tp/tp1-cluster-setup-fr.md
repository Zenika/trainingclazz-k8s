# Lab 1

## Installation de Kubernetes

Vous utiliserez  `kubeadm` pour construire votre cluster.  
Il sera composé de :

- 1 noeud `Control-plane`/`Worker`

Étapes :

- Regardez l'aide de la commande `kubeadm` pour l'argument `init` : `kubeadm init --help`
- Vérifiez que le noeud rempli les attendus (pour installer kubernetes avec kubeadm) :

```shell
kubeadm init phase preflight
```

### Control plane

<!> Les commandes de cette section seront à exécuter depuis le `node` où vous voulez installer le `control plane`

`kubeadm` va installer les composants du `control-plane` en utilisant `kubelet` à partir des définitions de `pods`.

Initialisez le `control plane` (depuis le bon `node`):

```shell
sudo kubeadm init
```

- kubeadm démarre (sur ce noeud) le kubelet en tant service `systemd` avec la bonne configuration

```shell
# Vérifiez l'état du service kubelet
sudo systemctl status kubelet
```

- L'initialisation a notamment créé les fichiers de configurations et identification de votre cluster

```shell
sudo ls /etc/kubernetes/*.conf
```

- Ainsi que les fichiers de définitions statiques (*manifest*) des `pods` du `control-plane`.

```shell
sudo ls /etc/kubernetes/manifests/
```

- Constatez qu'il y a différents conteneurs `docker` qui sont maintenant démarrés sur le noeud du `control-plane`

```shell
sudo docker container ls
```

Vous pouvez maintenant utiliser votre cluster. Mais pour que la commande `kubectl` interagisse avec celui-ci, vous devez récupérer le fichier de configuration lui permettant de se connecter avec des droits administrateur :
```shell
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
(le sudo est utile quand vous n'êtes pas root et vous permet de configurer kubectl pour votre utilisateur)  

- Vous devriez pouvoir maintenant utiliser `kubectl` pour interagir avec votre cluster
- Vérifiez l'état du cluster avec `kubectl get nodes`
- Vérifiez l'état des pods système du cluster avec `kubectl get pods -n kube-system`


### Transformation du control-plane en worker

- Ici notre cluster n'aura qu'un seul noeud qui fera office de `control-plane` et de `worker`
- Transformez le control-plane en worker avec la commande suivante :

```shell
kubectl taint node control-plane node-role.kubernetes.io/master-
```

- Cette commande enlève une restriction qui empêche normalement vos applications de fonctionner sur un noeud du `control-plane`

## 2.3: Installation du réseau

Votre cluster n'est pas encore fonctionnel. Vous voyez cela en passant la commande `kubectl get nodes`.  
Il manque encore le `network addon` pour permettre à vos `pods` de communiquer.
Il y a de nombreuses solutions. Vous pouvez voir cela [ici](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#pod-network).  
Dans cet atelier, vous utiliserez le `CNI` _Weave Net_.

- Mettre en place le `CNI` _Weave Net_ sur le cluster

```shell
sudo sysctl net.bridge.bridge-nf-call-iptables=1
K8S_VERSION=$(kubectl version | base64 | tr -d '\n')
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=${K8S_VERSION}"
```

- Vérifiez que les pods sont maintenant `Ready` :

```shell
kubectl get nodes -w
```
(`-w` : watch)

- Créez un `pod` nginx-pod avec l'image nginx:
  `kubectl run nginx-pod --image=nginx` 

- Créez un `pod` avec l'image centos:  
  `kubectl run shell-pod --image=centos:7 -- sleep infinity` 

- Obtenez l'IP des pods nginx: 
  `kubectl get pods -o wide`

- Vérifiez que les pods peuvent communiquer :
  `kubectl exec shell-pod -- curl -s <NGINX_IP>`

- Créez un `service` pour le pod nginx : 
  `kubectl expose pod nginx-pod --name=nginx --port=80`

- Vérifiez que les pods peuvent communiquer avec les noms DNS (des services) :
  `kubectl exec shell-pod -- curl -s nginx`
