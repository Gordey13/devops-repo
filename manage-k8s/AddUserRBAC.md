RBAC Доступ по сертификату.
В Kubernetes пользователей как таковых нет. Но можно эмулировать доступ пользователя используя ssl сертификаты. Для этого имя пользователя добавляют в dn сертификата. Например:
`cn=gordey,dc=koclin,dc=local`

Генерируем ключ пользователя.
`openssl genrsa -out artur.key 4096`

Создадим временную директорию.
`mkdir users`
`cd users/`

Создадим конфигурационный файл opessl csr.cnf.
```yaml
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn

[ dn ]
CN = gordey
DC = koclin
DC = local

[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
basicConstraints=CA:FALSE
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=serverAuth,clientAuth
```

Генерируем запрос на сертификат.
`openssl req -config csr.cnf -new -key artur.key -nodes -out artur.csr`

Поместим содержимое файла csr в формате base64 в переменную среды окружения BASE64_CSR:
`export BASE64_CSR=$(cat artur.csr | base64 | tr -d '\n')`

Создаём файл csr.yaml с запросом на подпись:
```yaml
apiVersion: certificates.k8s.io/v1beta1
kind: CertificateSigningRequest
metadata:
name: artur_csr
spec:
groups:
- system:authenticated
  request: ${BASE64_CSR}
  usages:
- digital signature
- key encipherment
- server auth
- client auth
```

Применяем запрос.
`cat csr.yaml | envsubst | kubectl apply -f -`

Проверяем наличие запроса:
`kubectl get csr`

Подписываем и генерируем сертификат:
`kubectl certificate approve artur_csr`

Поместим сертификат пользователя в файл.
`kubectl get csr artur_csr -o jsonpath={.status.certificate} | base64 --decode > artur.crt`

Создание файла config
Получаем информацию о подключении к кластеру.
`kubectl cluster-info`

Kubernetes master is running at https://192.168.1.15:6443

Начинаем создавать файл конфигурации.
Сначала добавим информацию о кластере.
```yaml
kubectl config --kubeconfig=./config set-cluster k8s --server=https://192.168.218.49:6443 \
--certificate-authority=/etc/kubernetes/pki/ca.crt --embed-certs=true
```

Добавляем пользователя.
`kubectl config --kubeconfig=./config set-credentials artur --client-key=artur.key --client-certificate=artur.crt --embed-certs=true`

Определяем контекст.
`kubectl config --kubeconfig=./config set-context default --cluster=k8s --user=artur --namespace kubetest`

Устанавливаем контекст по умолчанию.
`kubectl config --kubeconfig=./config use-context default`

Проверяем доступ к серверу
`kubectl --kubeconfig=./config -n kubetest get pods`

Мы должны получить сообщение об ошибке доступа пользователя gordey к ресурсу. Это нормально. На данном этапе мы сконфигурировали доступ к кластеру для пользователя – конфигурационный файл для программы kubectl.

Доступ к элементам API кластера мы будем описывать отдельно.

Скопируйте полученный config файл в домашнюю директорию пользователя gordey:
`mkdir /home/artur/.kube`
`cp config /home/artur/.kube`
`chown -R artur:artur /home/artur/.kube`

ServiveAccount используют для доступа к API Kubernetes из приложений.
Когда в системе создаётся pod, ему по умолчанию присваивается default ServiceAccount текущего namespace.
Посмотреть ServiceAccount в namespace можно следующим образом:
`kubectl -n kubetest get serviceaccounts`

Создавать ServiceAccount можно прямо в командной строке:
`kubectl -n kubetest create serviceaccount testaccount`

Или при помощи yaml файла:
```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
name: testaccount
namespace: kubetest
```
`kubectl apply -f file.yaml`

Если приложение (pod) запускается без явного указания ServiceAccount, ему присваивается ServiceAccount default.

Для определения ServiceAccount, при описании пода используйте serviceAccountName.

При запуске приложения ему автоматически подключается директория /var/run/secrets/kubernetes.io/serviceaccount в которой находятся файлы:
    ca.crt – сертификат CA кластера.
    Namespace – содержит имя namespace, в котором находится pod.
    token – содержит токен, используемый для доступа к API кластера.

Если вы хотите получать доступ к API кластера не из приложения, а, например из командной строки при помощи curl. Необходимо получить токен соответствующего ServiceAccount:
```yaml
kubectl -n kubetest get secret $(kubectl -n kubetest get serviceaccount kubetest-account \
-o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 –decode
```