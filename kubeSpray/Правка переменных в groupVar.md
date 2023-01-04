grep -r "kubelet_load_modules" . = нет
grep -r "download_run_once" .
echo "download_run_once: True" >> ~/kubespray/inventory/dev/group_vars/all/download.yml
grep -r "kube_basic_auth" . = нет

- Изменяем имя cluster_name
- Изменяем сеть flannel_interface_regexp 

Правка переменных в groupVar
Настройка переменных group_vars/all
group_vars/all/all.yml
kubelet_load_modules: true - разрешает kubelet подгрузать необходимые модули ядра
kubeadm_enabled: false - установить обычным способом
kube_read_only_port: 10255 

group_vars/all/docker.yml
docker_storage_options: -s overlay2 - запускаем докер с файловым драйвером overlay2

group_vars/all/download.yml
download_run_once: true - оптимизация заргузки образов и файлов. Загружаем на один сервер. Далее копируем на остальные.

group_vars/etc.yml
etcd_snapshot_count: "5000" - количество записей в журнале etcd, которая храниться в памяти
etcd_ionice: "-c2 -n0" - повышаем приоритет при работе с диском
etcd_memory_limit: 0 - отключаем лимиты по памяти

Настройка переменных group_vars/k8s_cluster
group_vars/k8s-cluster/k8s-cluster.yml
kube_version: v1.22.15 - версия K8S
kube_oidc_auth: false - отключаем 2 вида аутентификации
kube_basic_auth: false - оставляем только по токену
kube_network_plugin: flannel - сеть с помощью flannel
kube_service_addresses: 10.100.0.0/16 - адреса сети для сервисов clusterIP
kube_pods_subnet: 10.0.0.0/16 - адреса сети для подов
kube_apiserver_insecure_port: 0 - отключаем без парольный доступ к API_server
kube_proxy_mode: iptables - режим работы kube-proxy (ipvs | iptables)
cluster_name: dev.local - имя кластера
kubeconfig_localhost: true - скопировать админские настройки для подключения к кластеру на сервер где был запуск ansilbe
kubectl_localhost: true - скопировать утилиту управления кластером kubectl
kubelet_authentication_token_webhook: true - открыть доступ по токену
kubelet_authorization_mode_webhook: true - открыть доступ по токену

group_vars/k8s-cluster/k8s-net-flannel.yml
flannel_backend_type: "host-gw" - запускаем в режиме host-gateway. Добавляет статические маршруты. 
flannel_interface_regexp: '192\\.168\\.0\\.\\d{1,3}' - regex указывает flannel на каком интерфейсе надо прописывать маршруты

Addons
group_vars/k8s-cluster/addons.yml
ingress_nginx_enabled: true - включаем установку контроллера nginx
ingress_nginx_host_network: true - использовать тип сети host-network
ingress_nginx_configmap:
  server-tokens: "False" - не показывать версию
  proxy-body-size: "2048M" - принимать запросы до 2Гб
  proxy-buffer-size: "16k" - буфферы приема в 16Кб
  worker-shutdown-timeout: "180" - сколько секунд ждать завершения воркеров при релоуде конфигов
ingress_nginx_nodeselector: - на каких узлах запускать ingress controller
  node-role.kubernetes.io/ingress: "ingress1" - запускаться надо на "ingress1"
ingress_nginx_tolerations: - Сопротивляемость. 
  - key: "node-role.kubernetes.io/ingress"
  operator: "Exists" - 

group_vars/kube-ingress.yml
node_labels:
  node-role.kubernetes.io/ingress: "ingress1" - необходимо установить метку
node_taints: - Зараза.
  - "node-role.kubernetes.io/ingress=:NoSchedule" - запретить запускаться на ноде новые поды