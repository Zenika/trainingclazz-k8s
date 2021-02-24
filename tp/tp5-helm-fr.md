## Helm

- Nettoyer le cluster avec les commandes suivantes :

```shell
kubectl delete deploy,ds,svc --all
kubectl delete pvc,pv --all
kubectl delete pods --all
docker image rm $(docker image ls -q)
```

- Installer le client `helm` ([documentation](https://helm.sh/docs/intro/install/))

```shell
# don't curl | bash IRL
curl -s https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
```

- Vérifier que `Helm` est correctement installé :

```shell
helm version
```

- Créer un Namespace `dockercoins` :

```shell
kubectl create ns dockercoins
```

- Se positionner dans le répertoire `dockercoins`
- Visualiser le contenu du fichier `values.yml` fourni
- Récupérer les dépendances :

```shell
helm dependency update
```

- Déployer une release :

```shell
public_ip=${PUBLIC_IP}  # or $(minikube ip)
echo "public_ip: ${public_ip}"
helm install dockercoins . \
  --set ingress.webui.host=dockercoins.${public_ip}.xip.io \
  --namespace dockercoins
```

- Observez la sortie produite par la commande d'installation
- Surveiller la création des Pods dans le Namespace `dockercoins`
- Vérifier l'application dans votre navigateur à l'adresse `dockercoins.<PUBLIC_IP>.xip.io`
- Lister les releases avec `helm list --namespace dockercoins`
- Augmenter le nombre de replicas worker :

```shell
helm upgrade dockercoins \
  --reuse-values \
  --set replicaCount.worker=2 . \
  --namespace dockercoins
```

- Mettre à jour le worker :

```shell
helm upgrade dockercoins \
  --reuse-values \
  --set image.worker.version=1.1 . \
  --namespace dockercoins
```

- Observer la mise à jour par la commande `watch kubectl get pods,rs,ds,deploy,svc,ing -o wide -n dockercoins`
