# Lab 2 

Les [Deployments](https://kubernetes.io/fr/docs/concepts/workloads/controllers/deployment/) vous permettent de gérer vos [Pods](https://kubernetes.io/fr/docs/concepts/workloads/pods/pod/). Cet objet vous permettra de mettre à jour et ou à l'echelle vos applications.

Vous utiliserez la commande [`kubectl`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands) pour interagir avec votre cluster.

## Déployer une application

Dans ce TP, vous allez déployer une image docker de l'application [cataas](https://hub.docker.com/r/y0an/cataas). Il s'agit d'une application web qui affiche des informations sur l'hôte qui l'héberge (ainsi que sur la requête http) et un chat 😺.

Pour cela vous allez *apply* (appliquer) le descripteur yaml du *deployment* [tp2-deploy-cataas.yaml](./tp2-deploy-cataas.yaml) :
```bash
kubectl apply -f tp2-deploy-cataas.yaml
```

Comme vous pouvez le voir dans le fichier [tp2-deploy-cataas.yaml](./tp2-deploy-cataas.yaml), ce descripteur va créer le `deployment` de nom **cataas**. Celui-ci instanciera **3 pods** (via un `replicaset`) contenant l'image docker de **cataas**.  

## Vérification

* Vérifiez que le déploiement s'est déroulé sans accroc
```bash
kubectl rollout status deploy cataas
# Devrait afficher
deployment "cataas" successfully rolled out
```

* Listez les déploiements (du `namespace` courant)
```bash
kubectl get deploy
# Devrait afficher (au delta de la colonne AGE)
NAME     READY   UP-TO-DATE   AVAILABLE   AGE
cataas   3/3     3            3           5m4s
```
Vous devriez voir le déploiement *cataas*, ainsi que le nombre de réplicas en fonctionnement.

* Consultez les informations détaillées du déploiement *cataas*
```bash
kubectl describe deploy cataas
```
Cette commande vous affiche entre autres : l'état et les événements du déploiement, ce qui a été déployé (`template` du pod) et avec combien d'instances.


* Listez les pods (du `namespace` courant)
```bash
kubectl get po
# Vous devriez avoir quelque chose comme
NAME                          READY   STATUS    RESTARTS   AGE
pod/cataas-66688d8f77-7cg4r   1/1     Running   0          14m
pod/cataas-66688d8f77-mh946   1/1     Running   0          14m
pod/cataas-66688d8f77-w9pxj   1/1     Running   0          14m
```
Vous pouvez constater que les 3 pods ont bien été créés pour correspondre à l'état désiré.

* Que se passe-t-il si un pod est "détruit" ?  

1. Choisissez un pod `cataas-....` depuis la liste précédente et supprimez le
```bash
# Attention vos pods n'auront pas les même identifiants, ces UUI sont donnés à titre d'exemple
kubectl delete po cataas-66688d8f77-w9pxj
```
2. Listez à nouveaux les pods (du `namespace` courant)
```bash
kubectl get po 
# Vous devriez avoir quelque chose comme
NAME                      READY   STATUS    RESTARTS   AGE
cataas-66688d8f77-7cg4r   1/1     Running   0          21m
cataas-66688d8f77-dbs5j   1/1     Running   0          8s
cataas-66688d8f77-mh946   1/1     Running   0          21m
```
Comme vous pouvez le voir vous avez toujours 3 réplicas. Il y a cependant une différence par rapport à tout à l'heure : un des réplicas est plus jeune que les autres (et il a un identifiant que vous n'aviez pas précédemment).  
Comment cela fonctionne-t-il ? Votre descripteur de `deployment` spécifie que vous deviez avoir 3 `replicas`. Le `controller manager` de kubernetes fait en sorte que l'état réel et l'état désiré soit alignés.

* Changez le nombre de réplicas :
```bash
# Augmenter le nombre de "replicas"
kubectl scale deploy cataas --replicas=5
# Consultez l'état du déploiement
kubectl get deploy cataas
# Vous devriez avoir quelque chose comme
NAME     READY   UP-TO-DATE   AVAILABLE   AGE
cataas   5/5     5            5           28m
```
Comme vous pouvez le constater, vous avez maintenant 5 réplicas dans votre déploiement.  

Pour finir affichez tous les pods !
