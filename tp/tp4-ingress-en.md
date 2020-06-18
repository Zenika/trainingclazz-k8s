## Introduction

In the previous exercise, you have exposed the *whoami* application internally using a service of type ClusterIP.
Now you want to go public and open your application to external clients. One way to do this is by using a Kubernetes Ingress.

Ingress exposes HTTP and HTTPS routes from outside the cluster to services within the cluster.
To be able to create Ingress objects in your cluster, you need to first install an *Ingress Controller*. 
You will use Traefik, a powerful Ingress Controller and reverse proxy (https://containo.us/traefik/)

## Install Traefik

Apply this Role Based Access Control (RBAC) that allow Traefik to know some information on your service:
```shell script
kubectl apply -f tp4-traefik-rbac.yml
```

Install *Traefik*:
```shell script
kubectl apply -f tp4-traefik-ingress-controller.yml
```

## Expose the whoami application using an Ingress

Here, Traefik is deployed as a Deployment with one replica. Find out the node on which runs the corresponding Pod:
```shell script
kubectl get pod -o wide -n kube-system | grep traefik
``` 

Connect to that node using your Strigo interface, and retrieve the public DNS name of that node using the machine info
menu.
If you have difficulties accessing "machine info", you can try one of these tricks : 

- In the browser with the dev tools : `document.querySelector('div.object.connect-local').click()`
- Or from the terminal : `nslookup $(curl ifconfig.me)`

Finally, **edit** the file tp4-whoami-ingress.yml and put the DNS name you just retrieved in the `host` entry (line 11).

Create the Ingress *whoami-ingress*:
```shell script
kubectl apply -f tp4-whoami-ingress.yml
```

You can view the created ingress using:
```shell script
kubectl get ing 
```

## Access the whoami application in your browser

Open your browser and copy/paste the DNS name you retrieved earlier followed by the path */whoami*.
You will get an answer from the *whoami* application right in your browser.

## Expose the Traefik dashboard

**Edit** the tp4-traefik-dashboard-ingress.yml file and put the DNS name you used earlier in the `host` entry (ligne 10).

Create the Ingress *traefik-dashboard-ingress* :
```shell script
kubectl apply -f tp4-traefik-dashboard-ingress.yml
```

You can now visualize the Traefik dashboard by visiting the URL composed by the DNS name used earlier followed by the
path */* in your browser.

## Conclusion

Congratulations ! you have successfully deployed your application on Kubernetes and made it public !

## Further info about deploying and exposing an Ingress Controller

Here, you used the simplest way to deploy and expose the Traefik ingress controller.
You could have used more replicas in the Deployment or used a DaemonSet to make it highly available. 
Furthermore, you could have exposed it via a NodePort service to make it accessible on any node of the cluster.
When the infra allows it, the Ingress Controller is better exposed via a LoadBalancer service and hence making it
accessible without using the nodes DNS names.

Please check the Traefik online documentation for more info and discover the fresh Traefik v2: https://docs.traefik.io

Enjoy !
