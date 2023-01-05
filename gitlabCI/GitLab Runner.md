Установить, конфигурировать, запустить GitLab Runner и GitLab Docker Registry
Организовать bash скрипты для записи и хранения конфиденциальной информации в K8S
Описать процесс CI/CD по сборке образа Docker
Описать процесса CI/CD из 5 шагов Build, Push, Template, Helm Linter, Deploy
Описать процесс CI/CD по развертыванию приложения в кластер K8S с помощью Helm Chart
SaaS сервис запущен в кластер K8S GitLab Runner

Описать процесса CI/CD из 5 шагов Build, Push, Template, Helm Linter, Deploy

Build & Push - сборка образа контейнера и push собранного образа в Docker Registry
Test - запускает Docker Compose для тестирования проверки приложения
CleanUp - Очистка за собой после работы. Встроено в GitLab Runner

Template - 
Helm Linter - 
Deploy - развертыванию приложения в кластер K8S

https://github.com/southbridgeio/xpaste
https://gitlab.com/LuckySB/xpaste

Форкнуть к себе в гит
Сгенерировать ключ для работы с репозиторием ssh-keygen -t rsa
Добавить ssh ключи для работы с репозиторием Gordey13 - xpaste - Repository Settings - Deploy keys
git clone https://github.com/Slurmio/school-dev-k8s.git

1.gitlab-runner
2.install_pg
3.prepare_cluster
4.deploy
5.improvement_cicd 


gitlab-runner
- Добавляем helm repo: helm repo add gitlab https://charts.gitlab.io
helm repo add gitlab https://gitlab.com/Gordey13/charts.gitlab.io/
helm repo add gitlab https://gitlab.com/charts/charts.gitlab.io/
git clone https://gitlab.com/charts/charts.gitlab.io.git

- Установка gitlab-runner в кластер
Перед установкой нужно поправить файл с настройками: values.yaml
Для того, чтобы раннер зарегистрировался, нужно будет вписать уникальный токен, взятый из вашего форка xpaste вот тут: Settings - CI/CD - Runners - Specific runners - registration token. Скопируйте его из Gitlab и вставьте в файл values.yaml, в переменную runnerRegistrationToken.
Как вы уже поняли, для установки мы пойдем знакомым путём Helm, выполнив команды:
helm upgrade -i gitlab-runner gitlab/gitlab-runner -f values.yaml -n gitlab-runner --create-namespace

- Проверка регистрации раннера
Там же, где вы брали токен для регистрации раннера, можно будет посмотреть на него (если всё сделано правильно) в списке "Available specific runners"

Установка и регистрация GitLab Runner
1.Настройки репозитория: curl -L "https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh" | sudo bash
2. Установка Runner: apt-get install gitlab-runner
3. Регистрация: gitlab-runner register 
sudo gitlab-runner register \
  --non-interactive \
  --url "https://gitlab.com/" \
  --registration-token "GR1348941n4yF9c8d4cqfjH-gd2AH" \
  --executor "docker" \
  --docker-image alpine:latest \
  --description "docker-runner" \
  --maintenance-note "Free-form maintainer notes about this runner" \
  --tag-list "docker" \
  --run-untagged="true" \
  --locked="true" \
  --access-level="not_protected"

URL: https://gitlab.com/
token: GR1348941n4yF9c8d4cqfjH-gd2AH
Теги указывают, на каких раннерах должны выполняться те или иные задачи
linux postgres saas-linux-amd64 gitlab ubuntu masterK8S docker-exec alpine:3.16
shell — выбираем исполнителя командный интерпретатор
virtualbox, kubernetes, custom, docker-ssh, parallels, shell, instance, docker, ssh, docker+machine, docker-ssh+machine
https://gitlab.com/Gordey13/xpaste/-/settings/ci_cd


Устанавливаем Базу Данных PostgreSQL
helm install postgresql bitnami/postgresql --namespace xpaste-development --atomic --timeout 120s --create-namespace
Postrgesql будет установлен с логином и паролем, указанными в values.yaml чарта.
Без использования Persistance Volume


Подготовка кластера : prepare_cluster
- ./setup.sh xpaste development
Проверка namespace xpaste-development: namespace for project already exists
Создаем CI ServiceAccount: serviceaccount/xpaste-development created
Создаем CI role: role.rbac.authorization.k8s.io/xpaste-development created
Создаем CI rolebinding: rolebinding.rbac.authorization.k8s.io/xpaste-development created
Получаем токен access token for new CI user: ...eyJhbGciOiJ...
Из переменных окружения строим: 
Проверяем наличие namespace:ServiceAccount:Role:RoleBind
Создаем ServiceAccount:Role:RoleBind
Получаем токен ...iJSUzI1NiIsImtpZ...

- Добавить переменную "Gordey13 - xpaste - CI/CD Settings - Variables" K8S_DEV_CI_TOKEN = токен, No Protect variable, Yes Mask variable
- Создаем секрет для gitlab-Registry
- Добавить УЗ токен : "Gordey13 - xpaste - Repository Settings - Deploy tokens" YES read_registry 
- Deploy Token: gitlab+deploy-token-1499116 : Fo9LB5zhmu1Rbj6VGKtG
- Создаем секрет для репозитория: ./docker_pull_secret.sh : secret/xpaste-gitlab-registry created
- Создаем секрет для PostgreSQL : user, pass, key ./xpaste_secret.sh

1. Запускаем скрипт `setup.sh`
bash setup.sh xpaste development
В конце своего выполнения скрипт выдаст нам токен, который необходимо сохранить.

2. Создание variables в gitlab
Для доступа из Gitlab в Kubernetes нам необходимо добавить в Gitlab переменную, в которой будет содержаться токен с предыдущего шага.

* Переходим в Gitlab
Для этого открываем в браузере свой форк xpaste.

* Добавляем переменную
Для этого в левом меню находим `Settings -> CI/CD -> Variables` и нажимаем Expand. Жмем кнопку `Add Variable` и в поле `Key` вводим имя переменной:
K8S_DEV_CI_TOKEN
В поле `Value` вводим скопированный токен из вывода команды setup.sh (пункт 1) и нажимаем `Add Variable`.

3. Создаем token для доступа в registry
Для этого переходим в раздел `Settings -> Repository -> Deploy tokens` и нажимаем Expand.
В поле `Name` вводим
k8s-pull-token

Cтавим галочку рядом с `read_registry`. Все остальные поля оставляем пустыми. Нажимаем `Create deploy token`.
!!НЕ ЗАКРЫВАЕМ ОКНО БРАУЗЕРА!!

4. Создаем secret в kubernetes
Создаем secret, который будет использоваться для image pull. Для этого возвращаемся на первый master и выполняем команду:
Вносим нужные данные в скрипт `docker_pull_secret.sh` и запускаем его:

Соответственно подставляя на место `<>` нужные параметры, которые получили на `шаге 3`.
vim docker_pull_secret.sh
./docker_pull_secret.sh

5. Создание секрета для приложения
Создаем секрет, из которого при деплое будут взяты значения для переменных окружения, таких как доступы к БД и секретный ключ.
Вносим нужные данные в скрипт xpaste_secret.sh (в данном случае ничего не меняем) и запускаем его:
vim xpaste_secret.sh
./xpaste_secret.sh
`secret-key-base xxxxxxxxxxxxx` это не плэйсхолдер. Можно так и оставить.


deploy
Имена должны совпадать в stages и stage. Имя job может быть другим.
Временный УЗ для job

Добавляем конфиг CI/CD в Gitlab
В этой части добавляем последний шаг - конфиг для Gitlab CI/CD для сборки, тестирования и деплоя приложения в кластер k8s. Деплой производится с использованием утилиты Helm v3.
Gitlab CI/CD описывается в файле `.gitlab-ci.yml` в формате `yaml`. По умолчанию Gitlab ищет этот файл в корне проекта, путь до файла может быть переопределен в настройках проекта.

1. Подготавливаем CI/CD
Для этого скопируем заранее подготовленный шаблон `.gitlab-ci.yml` в проект `xpaste`, выполнив команду:
cp .gitlab-ci.yml ~/xpaste/

2. Адрес Kubernetes API
В файле `.gitlab-ci.yml` указан адрес kube api. Так как runner запущен внутри кластера кубернтес, можем указать название сервиса kubernetes.default

3. Настройка ingress
Доступ к приложению будет осуществляться через ingress. Ingress устанавливается вместе с приложением, но для его корректной работы необходимо прописать ему адрес.
Для этого откроем `values.yaml`:
vi ~/xpaste/.helm/values.yaml

В переменной host необходимо указать DNS название, которое вы выдали сайту xpaste:
- host: xpaste.s<Ваш номер логина>.edu.slurm.io
+ host: xpaste.s000001.edu.slurm.io

Сохраняем все изменения и пушим их в gitlab. Для этого необходимо выполнить команды:
cd ~/xpaste
git add .
git commit -am "Add CI/CD config"
git push

4. Переключаемся в namespace приложения
Наше приложение xpaste устанавливается в другой namespace `xpaste-development`.
Для удобства работы, чтобы не набирать каждый раз опцию `--namespace` изменим namespace, который kubectl использует по умолчанию:
kubectl config set-context --current --namespace=xpaste-development

5. Проверка результата
Для проверки результата необходимо перейти в Gitlab в раздел `ci/cd -> pipelines` форка проекта xpaste.
Можно воспользоваться прямой ссылкой: `https://gitlab.com/<наименование своего нэймспэйса>/xpaste/pipelines`. `<наименование своего нэймспэйса>` необходимо заменить на свой каталог в гитлабе.
В результате все job должны закончиться без ошибок.

6.Открываем приложение в браузере
В браузере открываем URL: http://xpaste.s<Ваш номер логина>.edu.slurm.io. Открывать нужно в режиме `инкогнито`.

-   GitLab в Docker https://hub.docker.com/r/gitlab/gitlab-runner/tags
-   Использовать образ и запустить GitLab в к8с
-   Запустить GitLab в shell в группе docker и использовать kaniko для сборки образа

docker run --rm -v /srv/gitlab-runner/config:/etc/gitlab-runner gitlab/gitlab-runner register \
  --non-interactive \
  --executor "docker" \
  --docker-image alpine:latest \
  --url "https://gitlab.com/" \
  --registration-token "PROJECT_REGISTRATION_TOKEN" \
  --description "docker-runner" \
  --maintenance-note "Free-form maintainer notes about this runner" \
  --tag-list "docker,aws" \
  --run-untagged="true" \
  --locked="false" \
  --access-level="not_protected"

Добавил в группу докер для запуска команд sudo usermod -aG docker gitlab-runner

kaniko собирает образы контейнеров из Dockerfile без Docker. 
Затем отправляет их в указанный реестр Docker. 
Рекомендуется использовать kaniko — готовый образ-executor
который можно запустить как контейнер Docker или контейнер в Kubernetes

вставьте Dockerfile со всеми его зависимостями в контейнер kaniko
-v <путь_в_хосте>:<путь_в_контейнере>
в Kubernetes есть вольюмы
Аргумент --context - укажет путь к прикрепленному каталогу (внутри контейнера)
Аргумент --dockerfile - указывает путь к Dockerfile (включая имя)
Аргумент --destination - с полным URL к реестру Docker (включая имя и тег образа)

- docker pull gcr.io/kaniko-project/executor:debug-v1.3.0
- mkdir -p ~/kaniko/.docker
- echo "{\"auths\":{\"$CI_REGISTRY\":{\"username\":\"$CI_REGISTRY_USER\",\"password\":\"$CI_REGISTRY_PASSWORD\"}}}" > ~/kaniko/.docker/config.json
- docker run \
  -v $CI_PROJECT_DIR:/workspace \
  -v ~/kaniko/.docker/config.json:/kaniko/.docker/config.json \
  gcr.io/kaniko-project/executor:debug-v1.3.0 \
  --context=/workspace \
  --cache=true \
  --cache-repo=$CI_REGISTRY_IMAGE \
  --dockerfile=/workspace/Dockerfile \
  --destination=${CI_REGISTRY_IMAGE}:$CI_COMMIT_REF_SLUG.$CI_PIPELINE_ID

https://console.cloud.google.com/gcr/images/kaniko-project/global/executor

/home/gitlab-runner/builds/vzzoGr9T/0/Gordey13/xpaste | registry.gitlab.com/gordey13/xpaste | master | 693350650 | registry.gitlab.com | gitlab-ci-token | h3iCWaqzhAPaGDLWnDQW
$CI_PROJECT_DIR | $CI_REGISTRY_IMAGE | $CI_COMMIT_REF_SLUG | $CI_PIPELINE_ID | $CI_REGISTRY | $CI_REGISTRY_USER | $CI_REGISTRY_PASSWORD

docker run -it \
-v ~/builds/vzzoGr9T/0/Gordey13/xpaste:/workspace \
-v ~/kaniko/.docker/config.json:/kaniko/.docker/config.json \
gcr.io/kaniko-project/executor:debug-v1.3.0 \
--context=/workspace \
--cache=true \
--cache-repo=registry.gitlab.com/gordey13/xpaste \
--dockerfile=/workspace/Dockerfile \
--destination=registry.gitlab.com/gordey13/xpaste:master.693350650

/home/gitlab-runner/builds/vzzoGr9T/0/Gordey13/xpaste | registry.gitlab.com/gordey13/xpaste | master | 693367517 | registry.gitlab.com | gitlab-ci-token | jMAy4aBfxBqQhAA_VzgG

docker pull alpine:3.16

docker run -it --rm \
-v ~/builds/vzzoGr9T/0/Gordey13/xpaste:/workspace \
-v ~/kaniko/.docker/config.json:/kaniko/.docker/config.json \
alpine:3.16

pwd /
/workspace

docker container stop gallant_lumiere
docker container rm gallant_lumiere

- echo "$CI_PROJECT_DIR | $CI_REGISTRY_IMAGE | $CI_COMMIT_REF_SLUG | $CI_PIPELINE_ID | $CI_REGISTRY | $CI_REGISTRY_USER | $CI_REGISTRY_PASSWORD" > ~/kaniko/config.json

error checking push permissions -- make sure you entered the correct tag name, and that you are authenticated correctly, and try again: checking push permission for "registry.gitlab.com/gordey13/xpaste:master.693378141": creating push check transport for registry.gitlab.com failed: Get "https://registry.gitlab.com/v2/": dial tcp 35.227.35.254:443: i/o timeout

ошибка проверки push-разрешений - убедитесь, что вы ввели правильное имя тега и что вы прошли правильную аутентификацию, и повторите попытку: проверка push-разрешений для "registry.gitlab.com/gordey13/xpaste:master.693378141 ": создание push-контрольного транспорта для registry.gitlab.com не удалось: Получить "https://registry.gitlab.com/v2 /": набрать tcp 35.227.35.254:443: тайм-аут ввода-вывода

docker login -u gitlab-ci-token -p GZcPGASx4vc1z-2Eez3G registry.gitlab.com
Login Succeeded

WARNING! Using --password via the CLI is insecure. Use --password-stdin.
WARNING! Your password will be stored unencrypted in /root/.docker/config.json.
Configure a credential helper to remove this warning. See
https://docs.docker.com/engine/reference/commandline/login/#credentials-store

docker image ls
docker image push registry.gitlab.com/gordey13/alpine:3.16

Error response from daemon: pull access denied for registry.gitlab.com/gordey13/alpine, repository does not exist or may require 'docker login': denied: requested access to the resource is denied
docker push registry.gitlab.com/gordey13/xpaste:alpine:3.16

docker image push --all-tags registry-host:5000/myname/myimage

docker build -f ./app/Dockerfile -t hello_django:latest ./app

docker build --no-cache -t registry.gitlab.com/gordey13/xpaste ~/builds/vzzoGr9T/0/Gordey13/xpaste/
apk update && apk add --no-cache nginx nodejs dcron tzdata postgresql-dev libxslt-dev shared-mime-info
apk update
WARNING: Ignoring http://dl-cdn.alpinelinux.org/alpine/v3.7/community/x86_64/APKINDEX.tar.gz: network error (check Internet connection and firewall)

docker run -it --rm alpine:3.16

rm -rf /var/cache/apk
mkdir /var/cache/apk

From the logs provided, the issue seems to be a network issue:
 network error (check Internet connection and firewall)
Possible Root causes:
    Your machine does not have internet access
    You are using a proxy to access the internet
    Your firewall does not allow the access

docker run ubuntu apt-get update

wget http://dl-cdn.alpinelinux.org/alpine/v3.7/community/x86_64/APKINDEX.tar.gz

docker network create --driver bridge common
docker run -it ubuntu:latest

pkill docker
iptables -t nat -F
ifconfig docker0 down
brctl delbr docker0
docker -d
systemctl start docker

docker network ls
4cc88612c2ca   bridge    bridge    local нет
23571b4538f7   common    bridge    local нет 
2dbd373c2d33   host      host      local есть выход в интернет
66b0aa7358ea   none      null      local нет

docker run -it --network bridge ubuntu:latest bash
docker run -it --network host ubuntu:latest bash

docker run -it --rm --network host alpine:3.16 есть выход в интернет
docker run -it --rm --network bridge alpine:3.16 

Удалить все остановленные контейнеры, используйте флаг –q в команде docker rm и передайте ей ID контейнеров, которые нужно удалить:
docker rm $(docker ps -a -f status=exited -q)

docker rm db63dffa12f4 4d6c6e325021 ba30a90c618d b579b293e2af 4bd8ce4b3d75 236b07fd249a 34377845ef90 b3e353b26b79 e3ada38e6821 5071b2a6be5b d67ef79900c8 cf222b10de31 addd44c75269 83bfb62a4970 cc5c8f15ed6e

docker ps -a -f status=exited -f status=created

Чтобы удалить эти контейнеры, нужно ввести:

docker rm $(docker ps -a -f status=exited -f status=created)

