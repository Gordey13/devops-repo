https://habr.com/ru/post/322036/
Часть I Ansible:
Проект Zalando Patroni:
    https://github.com/zalando/patroni
    Patroni — это демон на python, позволяющий автоматически обслуживать кластеры PostgreSQL
    - Актуальность кластера поддерживается распределенным DCS хранилищем (Zookeeper, etcd, Consul)

Виртуалки разворачиваются из шаблона
    База Centos 7
    Обновленное (ядро, системные пакеты)
    Менеджер нода Ansible server
    Автоматизирован процесс управления нодами

Подготовить ноды установив необходимые компоненты:
    Готовим инвентарь ресурсов hosts для Ansible /etc/ansible/hosts
    Создаем директорию для playbook /etc/ansible/tasks 
    Набор пакетов и библиотек для создания рабочего окружения
        - essentialsoftware.yml
    Для администрирования нужно запустить агент VMWare
        - open-vm-tools.yml
    Подготовка сервера к установке основной части софта
        - Настроить синхронизацию времени с помощью ntp
            - ntpd.yml запускаем кроном ntp клиент раз 5 минут
        - Сконфигурировать Zabbix agent для мониторинга
            - zabbix.yml поменять только адрес сервера
        - ssh ключи и authorized_keys
            Перенос ssh ключей и настройка ssh вынесена в отдельную роль, которую можно найти, например, на ansible-galaxy
Конфигурируем на сервера созданную конфигурацию:
Запускаем обработку всех серверов: --- cluster-pgsql.yml
    ansible-playbook cluster-pgsql.yml --skip-tags patroni
        Аргумент --skip-tags заставляет Ansible пропустить шаг
        Ansible заходит на сервера под root
        Если без прав root, то надо добавить спец. флаг "become: true"->(sudo)
Подготовка закончена.

Часть II
Разворачиваем кластер
    - Устанавливаем PostgreSQL и все компоненты 
    - Заливаем для них индивидуальные конфиги
Роли Ansible для установки Patroni: 
    - https://github.com/gitinsky/ansible-role-patroni
    - Переработал и добавил playbook haproxy и keepalived
    - Создаем каталог для новой роли, и подкаталоги для ее компонентов:
        `mkdir /etc/ansible/roles/ansible-role-patroni/tasks`
        `mkdir /etc/ansible/roles/ansible-role-patroni/templates`
PostgreSQL кластер состоит из компонентов:
    - haproxy для отслеживания состояния серверов и перенаправления запросов на мастер сервер
    - keepalived для обеспечения наличия единой точки входа в кластер — виртуального IP

Первый playbook 
    - Устанавливает PostgreSQL из родного репозитория
    - Дополнительные пакеты требуемые Patroni
    - Скачивает с GitHub саму Patroni
    - Заливает конфигурацию для текущего сервера Patroni
    - systemd unit для запуска демона в системе
    - Запускает демон Patroni
        Шаблоны конфигов и systemd unit должны лежать в каталоге templates внутри роли

Общие переменные, для всего кластера укажем в инвентаре hosts
    - patroni_scope — название кластера в Consul
    - patroni_node_name — название сервера в Consul
    - patroni_rest_password — пароль для http интерфейса Patroni
    - patroni_postgres_password: пароль для user postgres
    - patroni_replicator_password — пароль для user replicator на slave
    - Настройка ssh (ключи, пользователи)
    - timezone для сервера
    - Приоритет сервера в кластере keepalived
    - Меняется имя сервер и приоритет (1-2-3) для 3 серверов

Конфигурируем haproxy 
    - Haproxy устаналивается на каждом хосте haproxy.yml
    - Содержит в своем конфиге ссылки на все сервера PostgreSQL
    - Проверяет какой сервер сейчас является мастером  и отправляет запросы на него через Patroni — REST интерфейс
    - При запросе server:8008 Patroni возвращает отчет по состоянию кластера в json
    - Отражает кодом ответа http является ли данный сервер мастером Статус:200-Лидер / Статус:503-Нет
    - Конфигурация haproxy haproxy.cfg