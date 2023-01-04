# Nexus
Nexus внутри kubernetes, свой docker registry.

- Про Nexus, общие вопросы выбора технологии deployment
- StatefulSet - теория
- Namespace для Nexus, LimitRange на namespace
- Файлы Deploy nexus
- Headless service
- StatefulSet
- Service, ссылка на конкретный pod в StatefulSet
- Ingress
- Пароль админа Nexus и первоначальная настройка Nexus
- Настройка репозитория для хранения Docker образов
- Пользователи и роли
- ssl порт и сертификат для репозитория
- push образа в Nexus

Nexus : Docker registry 
Хранилище: Helm chart, NPM, Maven repo, Docker registry...

Ingress Controller 80 443 port
Class Storage: NFS provisioner
Установка с помощью kubernetes манифестов yaml
3 сущности: Deployment, DemonSet, StatefulSet

StatefulSet
- Статическое имя пода [0],[1],[2]
- Статическое хранилище размещение на той же ноде
- Гарантия деплоя по порядку приложений [0],[1],[2]
- Удаление[0]-Установка[0], ...

Конфигурируем динамический PV на примере:
- Проекта "Kubernetes NFS-Client Provisioner":
https://github.com/vbouchaud/nfs-client-provisioner
+ Установить helm chart или deploy
+ Конфигурируем Namespace nfs-client-provisioner
+ Конфигурируем LimitRange Namespace
+ RBAC - ServiceAccount = Role + RoleBinding, ClusterRole + ClusterRoleBinding
- Конфигурируем StorageClass - профиль, описание массив lablo
- reclaimPolicy: Retain = нужно подтвердить удаление. Delete - удаляет данные 
- Конфигурируем сервис Deployment nfs-client-provisioner
- Проверить какие директории экспортируем `cat /etc/exports`
  mkdir data | chown gordey:gordey data
  nano /etc/exports | exportfs -a
  mount -t nfs 192.168.0.111:/var/k8s/data /mnt
- Заполнить поля ENV host:path
- Запросить 1Gi PVC для сервиса fluentd
- Запросить 1Gi PVC для сервиса postgresql

Конфигурируем Nexus:
+ Конфигурируем Namespace
+ Конфигурируем LimitRange Namespace
+ Конфигурируем сервис Headless (clusterIP:None)
+ Конфигурируем StatefulSet + указываем рабочий storageClass
+ Конфигурируем дополнительный Service (pod-name:nexus-0)
+- Конфигурируем правило Ingress для Ingress controller
+ Выводим первичный пароль для Nexus cd /var/opt/nfs cat admin.password (можно через контейнер)
+ Создаем репозиторий DockerRegistry (Docker hosted по HTTP 8083)

cert-manager - утилита для управления сертификатами.
`kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.10.0/cert-manager.yaml` / delete

Сертификаты для ingress
В первую очередь создаем секрет с ключом и сертификатом ЗА. Что бы не мучиться берем их из текущей версии кубера.
- `kubectl -n nexus create secret tls kube-ca-secret --cert=/etc/kubernetes/ssl/ca.pem --key=/etc/kubernetes/ssl/ca-key.pem`
Изучаем файл 02-certs.yaml. В файле используются CRD, добавленные при установке certmanager.
Применяем файл.
- `kubectl -n nexus get issuers`
- `kubectl -n nexus get certificate`

Подписываем сертификат и создаем ключ
10. Терминацию SSL помещаем на Ingress Controller
+ Создаем роль Пользователя (Docker-User-Role) (add, view, edit, read)
+ Создаем УЗ и присваиваем права Docker-User-Role
+ Создаем дополнительный порт 8083 в манифестах в Service, Ingress, StatefulSet
14. Терминация TLS на host взять из секретов
15. Конфигурируем RBAC для репозитория DockerRegistry
- Помещаем в файле csr.cnf домен [ dn ] CN = n.gordey.local
- Генерируем ключ `openssl genrsa -out nexus.key 4096`
echo "[ req ]
  default_bits = 2048
  prompt = no
  default_md = sha256
  distinguished_name = dn
  
  [ dn ]
  CN = nexus-tls.cluster.local

  [ v3_ext ]
  authorityKeyIdentifier=keyid,issuer:always
  basicConstraints=CA:FALSE
  keyUsage=keyEncipherment,dataEncipherment
  extendedKeyUsage=serverAuth,clientAuth" > csr.cnf
- Делаем запрос на подписание `openssl req -config csr.cnf -new -key nexus.key -nodes -out nexus.csr`
- Помещаем в среду окружения `export BASE64_CSR=$(cat nexus.csr | base64 | tr -d '\n')`

echo "apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: nexus_csrv2
spec:
  groups:
    - system:authenticated
  request: ${BASE64_CSR}
  signerName: kubernetes.io/kube-apiserver-client
  usages:
    - digital signature
    - key encipherment
    - server auth
    - client auth" > csr.yaml

  - Помещаем в среду k8s сертификат `cat csr.yaml | envsubst | kubectl apply -f -`
  - Проверяем наличие запроса: `kubectl get csr`
  - Подтверждаем сертификат `kubectl certificate approve nexus_csrv2` /deny
  - Помещаем сертификат Nexus. `kubectl get csr nexus_csrv2 -o jsonpath={.status.certificate} | base64 --decode > nexus.crt`



  - Добавляем сертификат в виде Секрета в систему `kubectl -n nexus create secret tls nexus-tls --cert=nexus.crt --key=nexus.key`
19. Установить сертификат в Win машину. Сертификат Авторити
- Выводим сертификат cat /etc/kubernetes/pki/ca.crt
- Устанавливаем сертификат в Win
20. Добавляем в Docker Registry image
- Авторизуемся в `docker login -u user-docker -p 12345! https://nexus.cluster.local:8083/`
- Добавляем `tag docker tag 9e5022ebdd96 n.gordey.local/nexus/k8s2:v0.01`
- Push в `docker push 9e5022ebdd96 n.gordey.local/nexus/k8s2:v0.01`