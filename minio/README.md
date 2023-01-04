# Основано на Bitnami MinIO
https://github.com/bitnami/charts/tree/master/bitnami/minio/

В качестве хранилища будет использоваться диски сервера. Поэтому необходимо жестко привязать
поды minio к соответствующим нодам кластера. Пометим две worker node при помощи label
`kubectl label nodes worker1.cluster.local minio=yes`
`kubectl label nodes worker2.cluster.local minio=yes`

Добавляем репо helm chart-а:
`helm repo add bitnami https://charts.bitnami.com/bitnami`

Учитываем, что для нормальной работы minio должны быть 4 физических хранилища. 
Т.е. в нашем случае, на каждой ноде будет по два диска для minio.

Подготавливаем файл манифеста, который будет взять за основу:
`helm template bitnami/minio -f values.yaml --namespace minio`
Удаляем все что нам не надо из файла и копируем его в manifests/01-minio.yaml

### kubectl
`kubectl create ns minio`
`kubectl apply -f manifests/`

### ArgoCD
`kubectl apply -f argo-app/project.yaml`
`kubectl apply -f argo-app/argo-app.yaml`

## WEB interface
Поскольку был установлен ingress, доступ к WEB интерфейсу:
http://minio.cluster.local