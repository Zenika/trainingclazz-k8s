## Introduction
Un service Kubernetes permet d'exposer une application à ses consommateurs, internes ou externes.

## Service cataas-svc
Le service *cataas-svc* décrit dans le fichier tp3-cataas-svc.yml "accroche" les pods du deployment *cataas* grâce à leurs labels
*app: cataas* (voir l'entrée selector).

Créez le service *cataas-svc*:
```shell script
kubectl apply -f tp3-cataas-svc.yml
``` 

Listez les services disponibles, et assurez-vous que le service cataas-svc a bien été créé:
```shell script
kubectl get svc
``` 

Inspectez le service cataas-svc avec la commande suivante:
```shell script
kubectl describe svc cataas-svc 
``` 

Remarquez la section *Endpoints* du service. Elle contient les IPs et ports des pods vers lesquels
kubernetes enverra les requêtes destinées au service.

## Scaler le déploiement et observer les endpoints du service

Scalez votre déploiement en passant à 2 réplicas:
```shell script
kubectl scale deploy cataas --replicas=2
```

Observez la section Endpoints du service:
```shell script
kubectl describe svc cataas-svc
```  

Repassez à 3 réplicas:
```shell script
kubectl scale deploy cataas --replicas=3
```

Et observez à nouveau la liste des Endpoints
```shell
kubectl describe svc cataas-svc
```  
Que remarquez-vous ?
 
## Consommation du service cataas-svc depuis un pod gateway 

Créez le Pod gateway depuis le fichier tp3-gateway-pod.yml:
```shell script
kubectl apply -f tp3-gateway-pod.yml
```

Vérifiez que le pod gateway a bien été créé et attendez qu'il soit dans un état *Running*

```shell script
kubectl get pods
```

Connectez-vous au pod gateway en exécutant la commande suivante:
```shell script
kubectl exec -it gateway -- bash
``` 

Depuis le pod gateway, consommez le service cataas-svc avec le client curl:
```shell script
curl cataas-svc:8080/api
``` 

Notez bien qu'on a consommé le service par son nom DNS *cataas-svc*, en utilisant le bon port du service.
On ne s'est pas préoccupé de découvrir les IPs des pods qui se cachent derrière.

Exécutez la commande plusieurs fois, vous verrez que des pods différents vous répondent
(si vous avez plusieurs réplicas dans votre deployment).

## Conclusion
Les services Kubernetes permettent d'exposer vos applications de façon stable et pérenne.
Ils load-balancent les requêtes automatiquement vers les pods présents dans la liste des Endpoints.
Cette liste est maintenue dynamiquement à jour par Kubernetes.

Le type de service que vous avez vu ici s'appelle ClusterIP, c'est le type par défaut. Il existe d'autres types
de service dans Kubernetes: [NodePort, LoadBalancer...] (https://kubernetes.io/fr/docs/concepts/services-networking/service/).
À part quelques subtilités, notamment d'expostion à l'extérieur, le principe reste le même.

## Bonus
S'il vous reste du temps à la fin de cette session, essayez de découvrir à quoi correspond le service dont le nom est
*kubernetes*, et qui apparait lorsque vous listez les services.
