# Lab 4 - Service and test

A Kubernetes *Service* exposes an application to its consumers, whether internal or external.

## whoami service

The *whoami* described in the file `tp4-whoami-svc.yml` handles the pods of the *whoami* deployment using their labels *app: whoami*
(see the selector entry).

Create the *whoami* service from the file `tp4-whoami-svc.yml`:
```shell script
kubectl apply -f tp4-whoami-svc.yml
```

List the available services, and make sure the *whoami* has been created:
```shell script
kubectl get svc
```

Inspect the service whoami:
```shell script
kubectl describe svc whoami
```

Notice the *Endpoints* section. It contains the IPs and ports of the service's destination pods.

## Scale the deployment and check the service's Endpoints
Scale your deployment to 2 replicas:
```shell script
kubectl scale deploy whoami --replicas=2
```

Check the Endpoints section of the Service:
```shell script
kubectl describe svc whoami
```

Scale up to 3 replicas:
```shell script
kubectl scale deploy whoami --replicas=3
```

And check the Endpoints section again:
```shell
kubectl describe svc whoami
```
What do you observe ?

## Request the whoami service from within the gateway pod

Create the gateway Pod described in the file `tp4-gateway-pod.yml`:
```shell script
kubectl apply -f tp4-gateway-pod.yml
```

Check that the gateway pod has been created and wait until it is in a *Running* state:
```shell script
kubectl get pods
```

Connect to the gateway pod using:
```shell script
kubectl exec -it gateway -- bash
```

From within the gateway pod, request the whoami using the curl client:
```shell script
curl whoami:8080
```

Notice that the service has been reached using its DNS name *whoami*, using the right port.
You don't need to bother to find the pod IPs behind this service. It's done automatically for us.

Execute the above command several times. You'll see different responses from different pods if you do have many replicas in your deployment.
Exit the container with `exit`.

You can check the DNS response directly:

```shell
kubectl exec gateway -- nslookup whoami
kubectl exec gateway -- nslookup whoami.default
kubectl exec gateway -- nslookup whoami.default.svc
kubectl exec gateway -- nslookup whoami.default.svc.cluster.local
```

## Conclusion

Kubernetes services expose your application in a discoverable and persistent way.
They load-balance the requests automatically on the different pods present in the Endpoints list of the service.
The Endpoints list is updated dynamically and transparently by Kubernetes.

In this exercise you have seen the Kubernetes default type of services which is called ClusterIP.
There are other types of services in Kubernetes: [NodePort, LoadBalancer...] (https://kubernetes.io/fr/docs/concepts/services-networking/service/).
Apart from some subtleties, regarding external exposition for example, all the services share the same concepts as seen here.

## Bonus
If you have some time left at the end of this session, try to figure out what is behind the *kubernetes* service which appears when you list the services.
