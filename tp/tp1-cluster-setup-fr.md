# Lab 1

## Installation de Kubernetes

Vous utiliserez  `kubeadm` pour construire votre cluster.  
Il sera composé de :

- 1 noeud `Control-plane`
- 3 noeuds `Worker`

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
kubeadm init
```

- kubeadm démarre (sur ce noeud) le kubelet en tant service `systemd` avec la bonne configuration

```shell
# Vérifiez l'état du service kubelet
systemctl status kubelet
```

- L'initialisation a notamment créé les fichiers de configurations et identification de votre cluster

```shell
ls /etc/kubernetes/*.conf
```

- Ainsi que les fichiers de définitions statiques (*manifest*) des `pods` du `control-plane`.

```shell
ls /etc/kubernetes/manifests/
```

Vous pouvez maintenant utiliser votre cluster. Mais pour que la commande `kubectl` interagisse avec celui-ci, vous devez récupérer le fichier de configuration lui permettant de se connecter avec des droits administrateur :
```shell
  mkdir -p $HOME/.kube
  cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  chown $(id -u):$(id -g) $HOME/.kube/config
```

- Vous devriez pouvoir maintenant utiliser `kubectl` pour interagir avec votre cluster
- Vérifiez l'état du cluster avec `kubectl get nodes`
- Vérifiez l'état des pods système du cluster avec `kubectl get pods -n kube-system`


### Workers

- Utilisez kubeadm pour créer un jeton de démarrage ainsi que la commande `kubeadm join ...` que vous utiliserez sur chacun des `worker node`. 

```shell
kubeadm token create --print-join-command
```

Pour créer et associer au cluster un `worker node`, exécutez sur chacun des `worker node` la commande qui a été générée précédemment (avec la commande `kubeadm token ....`).  
Quand vous avez fini depuis le `control plane node` (d'où vous avez configuré kubectl pour qu'il interagisse avec votre cluster), vérifiez que vous avez bien tous les `nodes` dans votre cluster :

```shell
kubectl get nodes
```

## 2.3: Installation du réseau

Votre cluster n'est pas encore fonctionnel. Vous voyez cela en passant la commande `kubectl get nodes`.  

```shell-session
kubectl get nodes
```

Il manque encore le `network addon` pour permettre à vos `pods` de communiquer.
Il y a de nombreuses solutions. Vous pouvez voir cela [ici](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#pod-network).  
Dans cet atelier, vous utiliserez le `CNI` _Cilium_.

- Mettre en place le `CNI` _Cilium_ sur le cluster
- *Sur le noeud control plane*, déployez _Cilium_

```shell-session
cilium install --set cni.chainingMode=portmap
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
