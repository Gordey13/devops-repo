---
# Проверка версии Ansible
- name: Check ansible version
  import_playbook: ansible_version.yml

# Настройка подключения к промежуточному серверу для дальнейшей работе внутрии локальной сети серверов. 
  roles:
    - { role: bastion-ssh-config, tags: ["localhost", "bastion"] }

# Устанавливаем необходимые пакеты и настраиваем системный репозиторий
  roles:
    - { role: bootstrap-os, tags: bootstrap-os}

# Собираем все необходимые сведения о серверах на которых будем разворачивать кластер K8S
  roles:
    - { role: kubernetes/preinstall, tags: preinstall }
    - { role: "container-engine", tags: "container-engine", when: deploy_container_engine|default(true) }
    - { role: download, tags: download, when: "not skip_downloads" }

# Устанавливаем кластер etcd 
  roles:
    - { role: etcd }

# Формируем сертификаты и расскладываем по клиентским узлам кластера
  roles:
    - { role: etcd }

# Запускаем на всех узлах Kubelet, генерируем сертификаты, создаем файлы конфигурации. 
  roles:
    - { role: kubernetes/node, tags: node }

# На мастер узлах запускаем компаненты control-plane, регистрируем Kubelet в кластере. 
# Настройка доступа администратора. 
# Настройка дополнительных кластерных ролей. 
# Настройка политики безопасноти.
  roles:
    - { role: kubernetes/control-plane, tags: master }
    - { role: kubernetes/client, tags: client }
    - { role: kubernetes-apps/cluster_roles, tags: cluster-roles }

# Если запускали в режиме KubeAdm на этом этапе подключаются Worker узлы
# Создаем манифесты сетевого плагина
# Устанавливаем метки на узлы
  roles:
    - { role: kubernetes/kubeadm, tags: kubeadm, when: "kubeadm_enabled" }
    - { role: kubernetes/node-label, tags: node-label }
    - { role: network_plugin, tags: network }

# При необходимости настраиваем Calico Route Reflector
  roles:
    - { role: network_plugin/calico/rr, tags: ['network', 'calico_rr'] }

# Если изменились сертификаты обновляем токены от сервис аккаунтов
# Патчим манифесты KubeProxy чтобы он НЕ запускался на Windows узлах 
  roles:
    - { role: win_nodes/kubernetes_patch, tags: ["master", "win_nodes"], when: "kubeadm_enabled" }

# Набор ролей, которые устанавливают дополнительный софт
# Внешний облачный контроллер
# Запускаем сетевой плагин
# Policy контроллеры
# Ingress контроллеры
# Внешние Provisioner для подключения PVC
# Остальной дополнительный софт (Helm, Dashbord, Metric-Server)
  roles:
    - { role: kubernetes-apps/external_cloud_controller, tags: external-cloud-controller }
    - { role: kubernetes-apps/network_plugin, tags: network }
    - { role: kubernetes-apps/policy_controller, tags: policy-controller }
    - { role: kubernetes-apps/ingress_controller, tags: ingress-controller }
    - { role: kubernetes-apps/external_provisioner, tags: external-provisioner }
    - { role: kubernetes-apps, tags: apps }

# Устанавливаем DNS сервер в кластер
  roles:
    - { role: kubernetes/preinstall, when: "dns_mode != 'none' and resolvconf_mode == 'host_resolvconf'", tags: resolvconf, dns_late: true }