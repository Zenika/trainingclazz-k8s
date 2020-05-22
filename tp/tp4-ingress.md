## Introduction

In the previous exercise, you have exposed the *whoami* application internally using a service of type ClusterIP.
Now you want to go public and open your application to external clients. One way to do this is by using a Kubernetes Ingress.

Ingress exposes HTTP and HTTPS routes from outside the cluster to services within the cluster.
To be able to create Ingress objects in your cluster, you need to first install an *Ingress Controller*. 
We will use traefik, a powerful Ingress Controller and reverse proxy (https://containo.us/traefik/)

## Install traefik

Enable the RBAC:
```shell script
kubectl apply -f tp4-traefik-rbac.yml
```

Install *traefik*:
```shell script
kubectl apply -f tp4-treafik-ingress-controller.yml
```

## Expose the whoami application using an Ingress

Traefik is deployed as a Deployment with one replica. Find out the node on which runs the corresponding Pod:
```shell script
kubectl get pod -o wide -n kube-system | grep traefik
``` 

Connect to that node using your Strigo interface, and retrieve the public DNS name of that node using the machine info
menu.

Finally, edit the file tp4-whoami-ingress.yml and put the DNS name you just retrieved in the *host* entry.

Create the *whoami-ingress*:
```shell script
kubectl apply -f tp4-whoami-ingress.yml
```

You can view the created ingress using:
```shell script
kubectl get ing 
```

## Access the whoami application in your browser

Open your browser and copy/paste the DNS name you retrieved earlier.
You will get an answer from the *whoami* application right in your browser.

## Conclusion
Congratulations ! you have successfully deployed your application on Kubernetes and made it public !

## Further info about deploying an Ingress Controller
Here, we used the simplest way to deploy the traefik ingress controller. We could have exposed it via a NodePort service
to make it accessible on any node of the cluster. When the infra allows it, the Ingress Controller is better exposed via
a LoadBalancer service and hence making it accessible without using the nodes DNS names.