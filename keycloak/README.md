# Keycloak
https://www.keycloak.org/
helmchart https://github.com/codecentric/helm-charts/tree/master/charts/keycloak

## Metallb
[https://metallb.universe.tf/](https://metallb.universe.tf/)
Убедится, что KubeProxy запущен с параметром: 
```yaml
ipvs:
  strictARP: true
---
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.10.2/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.10.2/manifests/metallb.yaml
```

Только при первой установке создаём сикрет:
`kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"`

Применяем базовую конфигурацию layer2.
`kubectl apply -f metallb/00-mlb.yaml`

Добавляем сервис для ingres-controller типа LoadBalancer
`kubectl apply -f metallb/01-lb-ingress-controller-svc.yaml`

## Установка keycloak
У нас установлен cert-manager. Добавляем ClusterIssuer (если он еще не установлен).
```yaml
kubectl -n cert-manager create secret tls kube-ca-secret \
    --cert=/etc/kubernetes/ssl/ca.crt \
    --key=/etc/kubernetes/ssl/ca.key
kubectl -n keycloak apply -f 00-certs.yaml
```

Подготовка манифестов
```yaml
helm repo add codecentric https://codecentric.github.io/helm-charts
helm template kk codecentric/keycloak -f values.yaml | \
    sed '/^#/d' | \
    sed '/helm.sh\/chart/d' | \
    sed '/managed-by: Helm/d' | \
    sed '/serviceName: kk-headless/d' | \
    sed '/podManagementPolicy/d' | \
    sed '/updateStrategy/d' | \
    sed '/type: RollingUpdate/d' | \
    sed '/serviceName/d' | \
    sed '/kind: StatefulSet/c\kind: Deployment' > manifests/02-keycloak.yaml
```

Установка. Можно руками:
`kubectl -n keycloak apply -f manifests`

Можно при помощи ArgoCD:
Пушим manifests/* в Git. Редактируем argo-app/{00-iam-project.yaml,01-keycloak-app.yaml}
`kubectl  apply -f argo-app`

## Настройка ArgoCD
https://argo-cd.readthedocs.io/en/stable/operator-manual/user-management/keycloak/