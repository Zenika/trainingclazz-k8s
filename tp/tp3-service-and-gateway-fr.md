## Introduction
Un service Kubernetes permet d'exposer une application à ses consommateurs, internes ou externes.

## Service whoami-svc
Le service *whoami-svc* décrit dans le yaml suivant "accroche" les pods du deployment *whoami* grâce à leurs labels
*app: whoami* (voir l'entrée selector).

Créez un fichier whoami-svc.yml avec le contenu suivant:

```yaml
apiVersion: v1
kind: Service

metadata:
  name: whoami-svc
  
spec:
  selector:
    app: whoami
  ports:
    - port: 8080
      targetPort: 80
```
 
Créez le service:

```shell script
kubectl apply -f whoami-svc.yml
``` 

Listez les services disponibles, et assurez-vous que le service whoami-svc a bien été créé:

```shell script
kubectl get svc
``` 

Inspectez le service whoami-svc avec la commande suivante:

```shell script
kubectl describe svc whoami-svc 
``` 

Remarquez la section *Endpoints* du service. Elle contient les IPs et ports des pods vers lesquels
kubernetes enverra les requêtes destinées au service.

## Scaler le déploiement et observer les endpoints du service

Scalez votre déploiement en passant à 2 réplicas:
```shell script
kubectl scale deploy whoami --replicas=2
```

Observez la section Endpoints du service:
```shell script
kubectl describe svc whoami-svc
```  

Repassez à 3 réplicas:
```shell script
kubectl scale deploy whoami --replicas=3
```

Et observez à nouveau la liste des Endpoints
```shell
kubectl describe svc whoami-svc
```  
Que remarquez-vous ?
 
## Consommation du service whoami-svc depuis un pod gateway 

Créez un fichier gateway.yml avec le contenu suivant:
```yaml
apiVersion: v1
kind: Pod

metadata:
  name: gateway
  
spec:
  containers:
    - name: gateway
      image: centos:7
      command: ["sleep", "infinity"]
```

Créez le pod gateway:
```shell script
kubectl apply -f gateway.yml
```

Vérifiez que le pod gateway a bien été créé et attendez qu'il soit dans un état *Running*

```shell script
kubectl get pods
```

Connectez-vous au pod gateway en exécutant la commande suivante:
```shell script
kubectl exec -it gateway -- bash
``` 

Depuis le pod gateway, consommez le service whoami-svc avec le client curl:
```shell script
curl whoami-svc:8080
``` 

Notez bien qu'on a consommé le service par son nom DNS *whoami-svc*, en utilisant le bon port du service.
On ne s'est pas préoccupé de découvrir les IPs des pods qui se cachent derrière.

Exécutez la commande plusieurs fois, vous verrez que des pods différents vous répondent
(si vous avez plusieurs réplicas dans votre deployment).

## Conclusion
Les services Kubernetes permettent d'exposer vos applications de façon stable et pérenne.
Ils load-balancent les requêtes automatiquement vers les pods présents dans la liste des Endpoints.
Cette liste est maintenue dynamiquement à jour par Kubernetes.

Le type de service que nous avons vu ici s'appelle ClusterIP, c'est le type par défaut. Il existe d'autres types
de service dans Kubernetes: [NodePort, LoadBalancer...] (https://kubernetes.io/fr/docs/concepts/services-networking/service/).
À part quelques subtilités, notamment d'expostion à l'extérieur, le principe reste le même.

## Bonus
S'il vous reste du temps à la fin de cette session, essayez de découvrir à quoi correspond le service dont le nom est
*kubernetes*, et qui apparait lorsque vous listez les services.
