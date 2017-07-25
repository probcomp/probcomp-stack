## Initial Setup
- Download account.json from console with appropriate access, store in ~/.gcp/probcomp.json
- Install gcloud and configure kubectl for access
```
brew install caskroom/cask/google-cloud-sdk kubectl
gcloud components install docker-credential-gcr
gcloud components install kubectl
gcloud container clusters get-credentials probcomp-testing \
    --zone us-east1-d --project hazel-aria-174703
```

## Deploy to GKE
```
cd gcp/services
kubectl apply -f 01_jupyter_data.yml
kubectl apply -f 50_jupyter.yml
```

## Useful Commands
* check stateful volumes
```
kubectl get storageclass standard
```
* check service status
```
kubectl get service jupyter
```
* check logs
```
kubectl logs jupyter-0
```
* check pod status (if service is not running as expected)
```
kubectl describe pod jupyter-0
```
* delete the service
```
kubectl delete -f 50_jupyter.yml
```
