# Grafana
С небольшим изvенениями в ConfigMap
Установка в командной строке:

    kubectl create ns loki
    kubectl -n loki apply -f manifests/

Установка как приложение ArgoCD:

    kubectl -n loki apply -f argo-app/argo-app.yaml