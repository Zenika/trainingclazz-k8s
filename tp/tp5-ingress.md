# Lab 5 - Ingress

In the previous exercise, you have exposed the *whoami* application internally using a service of type ClusterIP.
Now you want to go public and open your application to external clients. One way to do this is by using a Kubernetes Ingress.

Ingress exposes HTTP and HTTPS routes from outside the cluster to services within the cluster.
To be able to create Ingress objects in your cluster, you need to first install an *Ingress Controller*.
You will use Traefik, a powerful Ingress Controller and reverse proxy (https://containo.us/traefik/)

## Ingress Controller

- Activate the `ingress` addon:

```shell
minikube addons enable ingress
```

- Wait for the controller to be ready by running the following command:

```shell
kubectl wait --namespace ingress-nginx\
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller\
  --timeout=90s
```

- Display all objects created in the `ingress-nginx` Namespace with the following command:

```shell
kubectl get pod,svc,deploy,rs,job -n ingress-nginx
```

- Expose the Ingress Controller:

```shell
docker container run --name expose-ingress-controller --detach --network minikube --publish 80:80 alpine/socat tcp-listen:80,fork,reuseaddr tcp-connect:minikube:80
```

## Ingress whoami

> **Note**: For the rest of the lab, replace `FIXME`, with the IP of your minikube machine: `minikube ip`

- Expose the `whoami` Service by an _Ingress_ which will have to respond on the url `whoami.FIXME.sslip.io`

```shell
kubectl apply -f tp5-whoami-ingress.yml
```

- Check that the _Ingress_ is correctly configured with `kubectl get ingress`
- Test the url `http://whoami.FIXME.sslip.io/`, check by refreshing the page that you arrive alternately on the different Pods of the Service (see `Hostname`)

- Observe the logs of the Pod `ingress-nginx-controller-...` of the Namespace `ingress-nginx`


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
