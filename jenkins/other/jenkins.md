**Jenkins** система с открытым исходным кодом, то есть продукт доступен для просмотра, изучения и изменения. Кстати создан на базе **Java**. Дженкинс позволяет автоматизировать часть процесса разработки программного обеспечения, без участия человека. Данная система предназначена для обеспечения процесса непрерывной интеграции программного обеспечения.


##### Ставим Java на нашу машину
`sudo apt install openjdk-8-jre-headless`

Установка Jenkins
```
Проверьте вашу версию Java командой:
java -version

Добавьте ключ репозитория:
wget -q -O - https://pkg.jenkins.io/debian/jenkins.io.key | sudo apt-key add -

Добавьте адрес репозитория Debian в файл sources.list:
sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'

Обновите пакеты apt:
sudo apt update
Установите Jenkins:
sudo apt install jenkins

Запустите Jenkins:
sudo systemctl start jenkins

Убедитесь, что Jenkins активен:
sudo systemctl enable jenkins && sudo systemctl status jenkins
```

##### Что, если я не обновлю ключ подписи репозитория?
Ошибка при обновление пакетов джинкинса
https://www.jenkins.io/blog/2020/07/27/repository-signing-keys-changing/
```
sudo apt-get install -y gnupg2 gnupg gnupg1
ROOT sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 9B7D32F2D50582E6<the key>
![[Pasted image 20220809221112.png]]
DOCKER : RUN apt-get update && apt-get install -y gnupg

if you already downloaded gpg key then add key using command
- sudo apt-key add jenkins-ci.org.key  

W: GPG error: https://pkg.jenkins.io/debian-stable binary/ Release: The following signatures couldn't be verified because the public key is not available: NO_PUBKEY FCEF32E745F2C3D5
E: The repository 'https://pkg.jenkins.io/debian-stable binary/ Release' is not signed.
N: Updating from such a repository can't be done securely, and is therefore disabled by default.
N: See apt-secure(8) manpage for repository creation and user configuration details.

E: gnupg, gnupg2 and gnupg1 do not seem to be installed, but one of them is required for this operation
- sudo apt-get install -y gnupg2 gnupg gnupg1
```


- Сейчас веб-интерфейс Jenkins должен быть доступен на порту 8080 твоей виртуальной машины
- Нужно ввести временный пароль, который находится в **/var/lib/jenkins/secrets/initialAdminPassword**
- Далее нажимай "Установить предложенные плагины"

- Оставлять Jenkins на белом адресе крайне не рекомендовано т.к. там есть еще несколько лазеек через которые сервер могут взломать.
- На реальном проде стоит подключить SSL, чтобы защитить данные передаваемые через веб-интерфейс

Приступить непосредственно к созданию CI/CD. 
Задачи у нас будут такие:
- Подключить репозиторий с сайтом к Jenkins.
- Написать сборку контейнера, которая будет срабатывать каждый раз, когда в репозиторий будут пушить новый коммит.

##### Jenkins: Ошибка подключения к удаленому репозиторию
stderr: No ECDSA host key is known for github.com and you have requested strict checking. Host key verification failed. fatal: Could not read from remote repository.
https://stackoverflow.com/questions/21557998/jenkins-failed-to-connect-to-repository

1. Switch to jenkins user `sudo -iu jenkins`
2. On Ubuntu, placed your `id_rsa` and `id_rsa.pub` files in `/var/lib/jenkins/.ssh`
3. Generate `ssh-keygen -t rsa -b 4096 -C "твоя@почта-из-гита"`
4. Make Jenkins own them `sudo chown -R jenkins /var/lib/jenkins/.ssh/`
5. Make sure that Jenkins key is added as deploy key with RW access in GitHub (or similar) - use the `id_rsa.pub` key for this.
Now everything should jive with the SCM Sync Plugin.

В GitHub у тебя уже лежит публичная часть ключа, в Jenkins нужно положить полную.
`git@github.com:Gordey13/devops_lesson_trial.git`

- нужно указать плагину SCM чтобы он опрашивал указанную ветку репозитория на предмет изменений с указанной периодичностью.

- Формат времени указывается как в cron. Укажем каждую минуту для удобства.
``*/1 * * * *``
https://crontab.cronhub.io/

- При запуске сборки Jenkins скачает всю ветку к себе на сервер
- Файлы можно будет найти тут **/var/lib/jenkins/workspace/**
- путь также содержится в переменной $WORKSPACE которую можно использовать в сборках.
создав шаг сборки типа "shell" `ls -lrt $WORKSPACE`

Список переменных окружения : sudo
http://185.43.4.163:8080/env-vars.html/

Вставляй его в поле команды shell
Управлять конфигурацией контейнера и веб-сервера в нем можно прямо отсюда. Они будут каждый раз обновляться при сборке.
- Чтобы не было проблем между Docker и Jenkins, добавь последнего в группу Docker.
`usermod -a -G docker jenkins`
- добавить Jenkins в `/etc/sudoers`, чтобы спокойно исполнять в нем комманды с sudo.
`jenkins ALL=(ALL) NOPASSWD: ALL`

https://www.digitalocean.com/community/tutorials/how-to-edit-the-sudoers-file-ru
```
Обычно visudo открывает файл /etc/sudoers в текстовом редакторе vi. Однако в Ubuntu команда visudo настроена на использование текстового редактора nano
sudo update-alternatives --config editor
```

Файлы в каталоге `/etc/sudoers.d` также следует редактировать с помощью команды `visudo`
`sudo visudo -f /etc/sudoers.d/`

```
# Configuration for jenkins
Defaults:jenkins !requiretty
Defaults:jenkins lecture = never
jenkins ALL=(ALL) NOPASSWD: ALL
jenkins ALL=(ALL:ALL) NOPASSWD: ALL
```

#!/bin/bash
#!/bin/sh -xe
-x будет печатать каждую команду; 
-e когда любая команда завершает код со сбоем любой команды, это приведет к тому, что оболочка немедленно прекратит выполнение сценария
Установить скобки и убрать комменты в командах

##### Shell скрипт для развертывания контейнера
#!/bin/sh -x
sudo mkdir -p "~/build/site"
sudo chown root:jenkins -R "~/build/"
sudo chmod 775 -R "~/build/"
sudo rsync -av "$WORKSPACE/landing/" "~/build/site/"
sudo echo "
server {
 
    server_name 192.168.20.2;
 
    access_log /var/log/nginx_access.log;
 
    error_log /var/log/nginx_error.log;
 
    root /var/www;
 
    location / {
 
                index  index.html index.htm index.php;
 
    }
 
} " > "~/build/site.conf"

sudo echo "FROM nginx
RUN apt update && apt-get install -y locales

///# Locale
RUN sed -i -e \
  's/# ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen \
   && locale-gen
 
ENV LANG ru_RU.UTF-8
ENV LANGUAGE ru_RU:ru
ENV LC_LANG ru_RU.UTF-8
ENV LC_ALL ru_RU.UTF-8
 
RUN  mkdir /var/www
RUN  rm -f /etc/nginx/conf.d/default.conf
COPY site.conf  /etc/nginx/conf.d/
COPY site/. /var/www/
RUN  chown nginx:nginx -R /var/www/" > "~/build/Dockerfile"
 
sudo docker rm -f web
cd "~/build/"
sudo docker build -f "~/build/Dockerfile" . -t web/dev
sudo docker run --name web -p 80:80 -d web/dev
sudo rm -rf "~/build/"

##### !!!!!!!!!!!!! Изучи лог сборки в Jenkins
`docker exec -it web ls -l /var/www`
Если изменений не видно, стоить проверить, все ли верно у тебя настроено:
- Ты сделал коммит именно в **main** ветку, на которую мы настроили сборку.
- В гите не нарушена структура папок - в корне landing папка с содержимым сайта.
- У тебя на сервере, во временной папке, куда Jenkins загружает репозиторий, все должно быть также, как в гите.
- Также проверь содержимое папки **/var/www** в контейнере. Можешь ориентироваться на кол-во картинок в images, в первом коммите их больше.
- Изучи лог сборки в Jenkins!!!!!!!!!!!!!!

`tar -xvf first_commit.tar` - извлечь из tar архива
`wget http://distrib.yodo.me/second_commit.tar` - получить данные по ссылке


