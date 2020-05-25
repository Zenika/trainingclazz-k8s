# Lab 2 

Les [Deployments](https://kubernetes.io/fr/docs/concepts/workloads/controllers/deployment/) vous permettent de gérer vos [Pods](https://kubernetes.io/fr/docs/concepts/workloads/pods/pod/). Cet objet vous permettra de mettre à jour et ou à l'echelle vos applications.

Vous utiliserez la commande [`kubectl`](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands) pour interagir avec notre cluster.

## Déployer une application

Dans ce TP, vous allez déployer une image docker de l'application [whoami](https://github.com/containous/whoami). Il s'agit d'une application web qui affiche des information sur l'hôte qui l'herberge (ainsi que sur requête http).

Pour cela vous allez *apply* (appliquer) le descripteur yaml du *deployment* [tp2-deploy-whoami.yaml](./tp2-deploy-whoami.yaml) :
```bash
kubectl apply -f tp2-deploy-whoami.yaml
```

Comme vous pouvez le voir dans le fichier [tp2-deploy-whoami.yaml](./tp2-deploy-whoami.yaml), ce descripteur va créer le `deployment` de nom **whoami**. Celui-ci instanciera **3 pods** (via un `replicaset`) contenant l'image docker de **whoami**.  

## Vérification

* Vérifiez que le déploiement s'est déroulé sans accroc
```bash
kubectl rollout status deploy whoami
# Devrait afficher
deployment "whoami" successfully rolled out
```

* Listez les déploiements (du `namespace` courant)
```bash
kubectl get deploy
# Devrait afficher (au delta de la colonne AGE)
NAME     READY   UP-TO-DATE   AVAILABLE   AGE
whoami   3/3     3            3           5m4s
```
Vous devriez voir le déploiement *whoami*, ainsi que le nombre de réplicas en fonctionnement.

* Consultez les informations détaillés du déploiement *whoami*
```bash
kubectl describe deploy whoami
```
Cette commande vous affiche entre autres : l'état et les événements du déploiement, ce qui a été déployé (`template` du pod) et avec combien d'instances.


* Listez les pods (du `namespace` courant)
```bash
kubectl get po
# Vous devriez avoir quelque chose comme
NAME                          READY   STATUS    RESTARTS   AGE
pod/whoami-66688d8f77-7cg4r   1/1     Running   0          14m
pod/whoami-66688d8f77-mh946   1/1     Running   0          14m
pod/whoami-66688d8f77-w9pxj   1/1     Running   0          14m
```
Vous pouvez constater que les 3 pods ont bien été créer pour correspondre à l'état désiré.

* Que se passe t'il si un pod est "détruit" ?  

1. Choisissez un pod `whoami-....` depuis la liste précédente et supprimez le
```bash
# Attention vos pods n'auront pas les même identifiants, ces UUI sont donnés à titre d'exemple
kubectl delete po whoami-66688d8f77-w9pxj
```
2. Listez à nouveaux les pods (du `namespace` courant)
```bash
kubectl get po 
# Vous devriez avoir quelque chose comme
NAME                      READY   STATUS    RESTARTS   AGE
whoami-66688d8f77-7cg4r   1/1     Running   0          21m
whoami-66688d8f77-dbs5j   1/1     Running   0          8s
whoami-66688d8f77-mh946   1/1     Running   0          21m
```
Comme vous pouvez le voir vous avez toujours 3 réplicas. Il y a cependant une différence par rapport à toute à l'heure : un des réplicas est plus jeune que les autres (et il a un identifiant que vous n'aviez pas précédemment).  
Comment cela fonctionne t'il ? Votre descripteur de `deployment` spécifie que vous deviez avoir 3 `replicas`. Le `controller manager` de kubernetes fait en sorte que l'état réel et l'état désiré soit alignés.

* Changez le nombre de réplicas :
```bash
# Augmenter le nombre de "replicas"
kubectl scale deploy whoami --replicas=5
# Consultez l'état du déploiement
kubectl get deploy whoami
# Vous devriez avoir quelque chose comme
NAME     READY   UP-TO-DATE   AVAILABLE   AGE
whoami   5/5     5            5           28m
```
Comme vous pouvez le constater, vous avez maintenant 5 réplicas dans votre déploiement.  

Pour finir affichez tous les pods !
