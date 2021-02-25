# Lab 1

## Kubernetes Installation

We'll use `kubeadm` to spawn our cluster.
Our cluster will be composed of:

- 1 Control-plane/Worker node

Steps:

- Check `kubeadm` arguments with: `kubeadm init --help`
- Check node requirements:

```shell
sudo kubeadm init phase preflight
```

### Control plane

With kubeadm, control-plane components are spawned as static pods on the node's
kubelet.

Let's init the control plane:

```shell
sudo kubeadm init
```

- kubeadm starts the kubelet with the right config on this node as a systemd service

```shell
systemctl status kubelet
```

- After that it generates kubeconfig file which holds their credentials and information on the cluster.

```shell
sudo ls /etc/kubernetes/*.conf
```

- kubeadm creates the static pods manifests for control-plane components.

```shell
sudo ls /etc/kubernetes/manifests/
```

- Check that control-plane components containers are running:

```shell
sudo docker container ls
```

Now you can use your cluster, but you need to configure kubectl for cluster admin:
```shell
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

- At this point, you should be able to use `kubectl` to interact with the
  cluster.
- Check cluster state with `kubectl get nodes`
- Check cluster components pods with `kubectl get pods -n kube-system`


### Transformation du control-plane en worker

- Here, our cluster will have only one node which will be used as `control-plane` and `worker`
- Transform the control-plane into a worker:

```shell
kubectl taint node control-plane node-role.kubernetes.io/master-
```

- This command removes a restriction which prevents application from running on a `control-plane` node

## 2.3: Network solution

At this moment, the cluster isn't in a usable state. You can check it with:
`kubectl get nodes`. It still lacks a network addon to enable cross cluster
communication. There are many availables, you can check it [there](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#pod-network).
We will deploy _Weave Net_.

- Deploy a network solution on the cluster

```shell
sudo sysctl net.bridge.bridge-nf-call-iptables=1
K8S_VERSION=$(kubectl version | base64 | tr -d '\n')
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=${K8S_VERSION}"
```

- Check that nodes are now ready with:

```shell
kubectl get nodes -w
```

- Create a nginx pod:
  `kubectl run nginx-pod --image=nginx` 

- Create a centos pod:  
  `kubectl run shell-pod --image=centos:7 -- sleep infinity` 

- Get the IP of nginx pod: 
  `kubectl get pods -o wide`

- Check that the 2 pods can communicate:
  `kubectl exec shell-pod -- curl -s <NGINX_IP>`

- Create a service pointing to nginx : 
  `kubectl expose pod nginx-pod --name=nginx --port=80`

- Check that the 2 pods can communicate using DNS:
  `kubectl exec shell-pod -- curl -s nginx`
