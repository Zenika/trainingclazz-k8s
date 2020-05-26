## Introduction

Dans l'execrice précédent, vous avez exposé l'application *whoami* à l'intérieur du cluster grâce à un service ClusterIP.
Maintenant vous voulez la rendre publique en l'exposant aux clients externes. Une façon d'atteindre cet objectif est
d'utiliser un Ingress Kubernetes.

Un Ingres expose des routes HTTP et HTTPS de l'extérieur du cluster Kubernetes vers des services déployés à l'intérieur
du cluster.

Afin de pouvoir créer des objets de type Ingress, il faut au préalable installer un *Ingress Controller* dans le cluster.
Vous allez utiliser *Traefik*, un puissant Ingress Controller et Reverse Proxy (https://containo.us/traefik/).  

## Installer Traefik

Appliquez les "Role Based Access Control" (RBAC) qui permettent à Traefik de récupérer des informations sur votre service:
```shell script
kubectl apply -f tp4-traefik-rbac.yml
```

Installez *Traefik*:
```shell script
kubectl apply -f tp4-traefik-ingress-controller.yml
```

## Exposer l'application whoami avec un Ingress

Dans cet exercice, Traefik est déployé en tant que Deployment à 1 réplica. Trouvez le noeud sur lequel tourne le Pod Traefik: 
```shell script
kubectl get pod -o wide -n kube-system | grep traefik
``` 

Dans votre interface Strigo, connectez-vous à ce noeud pour récupérer son nom DNS public en utilisant le menu "machine info".

Enfin, **éditer** le fichier tp4-whoami-ingress.yml et mettez le nom DNS que vous venez de récupérer dans l'entrée `host` (ligne 11).

Créez le Ingress *whoami-ingress*:
```shell script
kubectl apply -f tp4-whoami-ingress.yml
```

Vous pouvez visualiser l'Ingress créé:
```shell script
kubectl get ing 
```

## Accéder à l'application whoami dans votre navigateur

Ouvrez un navigateur et copiez/collez le nom DNS récupéré précédemment.
Vous obtiendrez une réponse de votre application whoami !

## Conclusion

Félicitations ! Vous avez réussi à déployer votre application sur Kubernetes et la rendre accessible publiquement.

## Plus d'informations sur le déploiement et l'exposition d'un Ingress Controller

Ici vous avez utilisé la façon la plus simple de déployer et d'exposer un Ingress Controller.
Vous auriez pu utiliser plusieurs réplicas dans le Deployment voire utiliser un DaemonSet pour avoir de la haute
disponibilité.
De plus, vous auriez pu exposer Traefik via un service de type NodePort afin de le rendre accessible sur n'importe quel
noeud du cluster.
Quand l'infra le permet, vous pouvez faire encore mieux, exposer Traefik via un service de type LoadBalancer et le rendre
ainsi accessible sans avoir à utiliser les noms DNS des noeuds du cluster. 

Pour plus d'informations, vous pouvez consulter la documentation en ligne de Traefik: https://docs.traefik.io.
Vous y découvrirez notamment la nouvelle version v2.

Amusez-vous bien !
