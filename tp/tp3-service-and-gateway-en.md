## Introduction
A Kubernetes *Service* exposes an application to its consumers, whether internal or external.

## cataas-svc service
The *cataas-svc* described in the file tp3-cataas-svc.yml handles the pods of the *cataas* deployment using their labels *app: cataas*
(see the selector entry).
 
Create the *cataas-svc* service from the file tp3-cataas-svc.yml:
```shell script
kubectl apply -f tp3-cataas-svc.yml
``` 

List the available services, and make sure the *cataas-svc* has been created:
```shell script
kubectl get svc
``` 

Inspect the service cataas-svc:
```shell script
kubectl describe svc cataas-svc 
``` 

Notice the *Endpoints* section. It contains the IPs and ports of the service's destination pods.

## Scale the deployment and check the service's Endpoints
Scale your deployment to 2 replicas:
```shell script
kubectl scale deploy cataas --replicas=2
```

Check the Endpoints section of the Service:
```shell script
kubectl describe svc cataas-svc
```  

Scale up to 3 replicas:
```shell script
kubectl scale deploy cataas --replicas=3
```

And check the Endpoints section again:
```shell
kubectl describe svc cataas-svc
```  
What do you observe ?
 
## Request the cataas-svc service from within the gateway pod 

Create the gateway Pod described in the file tp3-gateway-pod.yml:
```shell script
kubectl apply -f tp3-gateway-pod.yml
```

Check that the gateway pod has been created and wait until it is in a *Running* state:
```shell script
kubectl get pods
```

Connect to the gateway pod using:
```shell script
kubectl exec -it gateway -- bash
``` 

From within the gateway pod, request the cataas-svc using the curl client:
```shell script
curl cataas-svc:8080/api
``` 

Notice that the service has been reached using its DNS name *cataas-svc*, using the right port.
You don't need to bother to find the pod IPs behind this service. It's done automatically for us.

Execute the above command several times. You'll see different responses from different pods if you do have many replicas
in your deployment.


## Conclusion
Kubernetes services expose your application in a discoverable and persistent way.
They load-balance the requests automatically on the different pods present in the Endpoints list of the service.
The Endpoints list is updated dynamically and transparently by Kubernetes.

In this exercise you have seen the Kubernetes default type of services which is called ClusterIP.
There are other types of services in Kubernetes: [NodePort, LoadBalancer...] (https://kubernetes.io/fr/docs/concepts/services-networking/service/).
Apart from some subtleties, regarding external exposition for example, all the services share the same concepts as seen here.

## Bonus
If you have some time left at the end of this session, try to figure out what is behind the *kubernetes* service which appears
when you list the services.
