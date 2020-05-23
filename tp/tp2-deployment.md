# Lab 2 

[Deployments](https://kubernetes.io/fr/docs/concepts/workloads/controllers/deployment/) allow you to manage [Pods](https://kubernetes.io/fr/docs/concepts/workloads/pods/pod/). With this resource, you'll be able to update and scale quickly and easily your applications.

From now on, we'll be interacting with the cluster thanks to the [`kubectl` command](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands).

## Deploy the application

In this lab, we're going to deploy the [whoami](https://github.com/containous/whoami) application. It's a tiny webserver that prints out information about the node it's deployed on.

To do that, we're going to *apply* the yaml descriptor [tp2-deploy-whoami.yaml](./tp2-deploy-whoami.yaml) :
```bash
kubectl apply -f tp2-deploy-whoami.yaml
```

As you can see in the yaml, this descriptor will create a deployment called **whoami**. This deployment is going to control **3 pod replicas** based on the whoami docker image.

## Check

* Check that the deployment was successfully applied 
```bash
kubectl rollout status deploy whoami
# It should print the following 
deployment "whoami" successfully rolled out
```

* List all your deployments
```bash
kubectl get deploy
# It should print something similar to below 
NAME     READY   UP-TO-DATE   AVAILABLE   AGE
whoami   3/3     3            3           5m4s
```
Here you can see your `whoami` deployment. You can also see the number of replicas currently running.

* Get the details of that deployments
```bash
kubectl describe deploy whoami
```
This commands allows to get more info about your deployment, especially the number of replicas and the pod template.

* List the pods
```bash
kubectl get po
# It should print something similar to below 
NAME                          READY   STATUS    RESTARTS   AGE
pod/whoami-66688d8f77-7cg4r   1/1     Running   0          14m
pod/whoami-66688d8f77-mh946   1/1     Running   0          14m
pod/whoami-66688d8f77-w9pxj   1/1     Running   0          14m
```
Here you can see that 3 pods were created as requested.

* Now what happens if we delete a pod ? Lets try it.  

1. Pick a pod from the previous command and delete it
```bash
kubectl delete po whoami-66688d8f77-w9pxj
```
2. Now let's print the pods again 
```bash
kubectl get po 
# It should print something similar to below
NAME                      READY   STATUS    RESTARTS   AGE
whoami-66688d8f77-7cg4r   1/1     Running   0          21m
whoami-66688d8f77-dbs5j   1/1     Running   0          8s
whoami-66688d8f77-mh946   1/1     Running   0          21m
```
As you can see, you still have 3 replicas. Also note that the age is different on one pod. That's the one that the deployment created automatically when you deleted a pod.  
Why ? Because in your deployment descriptor, you requested 3 replicas. So whatever happens, the kubernetes controller manager will do everything to maintain that number.

* Change the number of replicas :
```bash
# Lets increase the number of replicas
kubectl scale deploy whoami --replicas=5
# Get the deployment again
kubectl get deploy whoami
# It should print something like below
NAME     READY   UP-TO-DATE   AVAILABLE   AGE
whoami   5/5     5            5           28m
```
As you can see, there is now 5 replicas attached to your deployment.

Now go ahead and print all the pods !
