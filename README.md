# devops-repo
Observability (Monitoring, Logging)
Logging:
  - Кластер логирования FluentBit + ElasticSearch + Kibana
  - Кластер логирования FluentBit + Fluentd(forward) + NFS -> file.log
  - Кластер логирования FluentBit + Kafka + Vector + ElasticSearch + Kibana
  - Кластер логирования FluentBit + HazelCast

Monitoring в кластере K8s:
  - Мониторинг Prometheus + Grafana = PG стек
  - Мониторинг TICK стека InfluxDB, Telegraf, Grafana
  - Мониторинг VictoriaMetrics + Karma + Vmalert + Alertmanager + Grafana + Wmagent + Node-exporter, KSM
  - Тонкая настройка Dashbords для Grafana
  - Тонкая настройка Alertmanager, Karma
  - Zabbix через Docker-compose : server -- agent

Прочие:
  - Metallb
  - Docker MultiStage Build
  - Настройка timezone в контейнере
  - Gatekeeper
  - Keycloak
  - Кластер Selenoid + Docker + GGR (load balancer) + GGR UI + Selenoid UI + nginx
  - Vagrant

CI/CD:
  - ArgoCD доставка и развертывание
  - GitLab Runner в K8S
  - Helm Charts в K8S
  - Процесс CI/CD по сборке образа Docker
  - Процесс CI/CD по развертыванию приложения в кластер K8S
  - Упаковка Helm Chart
  - Процесс CI/CD из шагов Build, Test, Push, Template, Helm Linter, Deploy
  - Nexus / Docker Registry local / Java Registry 
  - Hashicorp Vault в kubernetes

Кластер Kubernetes (Ansible KubeSpray):
  - ResourceQuota
  - PriorityClass
  - RBAC
  - Secret (CredPSW/USR, TLS, CredDockerR) 
  - Ingress Controller
  - Kubernetes Network

Базы:
  - Кластер ElasticSearch + Kibana
  - Кластер PostgreSQL, Patroni, etcd, HAProxy
  - Отказоустойчивый Kafka + Zookeeper кластер
  - Кластер CephFS
  - Кластер Opensearch + Dashboard + Cert-manager

Ansible:
  - Ansible роль по конфигурированию OpenVPN