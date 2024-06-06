## Lab 1 - minikube setup

Goal: Start a `kubernetes` cluster on the VM.

### minikube startup

- Launch minikube with the following command:

```shell
minikube start --kubernetes-version v1.30.0 --nodes 3
```

- Use the following command to check that minikube is running.

```shell
minikube status
```

### Download resources

Download the lab from the [zenika's github](https://github.com/Zenika/trainingclazz-k8s).

```shell
mkdir -p ~/workspace
cd ~/workspace
git clone -b refonte https://github.com/Zenika/trainingclazz-k8s
```

ℹ️ You can use this repo anytime outside this lab ;-)
