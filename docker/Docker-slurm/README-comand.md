Краткая шпаргалка по командам Docker

docker search <name> поиск образа в Registry

docker pull <name> скачать образ из Registry

docker build <path/to/dir> собрать образ

docker run <name> запустить контейнер из образа

docker rm <name> удалить контейнер

docker ps || docker container ls вывести список работающих контейнеров

docker logs <name> показать логи контейнера

docker start/stop/restart <name> действия с контейнером
Практическая работа

    Давайте запустим контейнер с Nginx. Для этого нам сперва нужно выяснить название образа, из которого можно будет запустить Nginx. Поищем его на Docker Hub:

docker search nginx

    Нашли образ, запускаем Nginx:

docker run nginx

    Не отдает консоль. Делаем Ctrl+C, смотрим на контейнеры и образы:

docker ps
docker ps -a
docker images

    Видим что контейнер остановлен и имеет странное имя. Запускаем снова, но уже с необходимыми ключами, затем смотрим результат:

docker run --name my-app -d nginx
docker ps
docker images

    Мы запустили контейнер с Nginx, это веб-сервер, а значит на него можно постучаться. В выводе docker ps видим открытый 80-ый порт:

[root@docker.s000099.slurm.io /]# docker ps
CONTAINER ID   IMAGE     COMMAND                  CREATED              STATUS              PORTS     NAMES
0f2a5c061d37   nginx     "/docker-entrypoint.…"   About a minute ago   Up About a minute   80/tcp    my-app

однако в списке открытых портов на сервере его нет:

netstat -nlp

    Разберемся с ситуацией. Посмотреть детальную информацию о контейнере нам поможет команда docker inspect, выполним ее и посмотрим блок о настройке сети:

docker inspect my-app

    Видим что порт не прокинут на наш сервер. Выясним IP-адрес нашего контейнера и обратимся к нему с помощью curl:

docker inspect my-app | grep IPAddress
curl <your_ip_address>

    Убедимся, что ответ был действительно от Nginx из контейнера, посмотрим логи:

docker logs my-app

    Подчищаем за собой:

docker stop my-app && docker rm my-app && docker rmi nginx

---
Делаем первые шаги в запуске своего приложения в Docker

    Переходим в каталог docker_course/practice/2.basics/3.start_your_app

    Далее переходим в папку hello/. Внутри видим два скрипта. Попробуем выполнить hello.py:

cd hello/
python hello.py

    Теперь попробуем запустить его в Docker. Сперва нам нужно собрать образ, поэтому выполняем команду:

docker build .

    Поругалось на отсутствие dockerfile, это правильно. Ведь Docker пока не знает по какой инструкции собрать образ. Копируем dockerfile из папки выше:

cp ../Dockerfiles/Dockerfile ./

    Запускаем снова сборку образа и видим, что сборка пошла:

docker build .

    Смотрим на образы и видим странное имя. Мы не поставили тег, исправляемся. Пересобираем образ, удалив прошлый:

docker images
docker rmi <image ID>
docker build . -t work

    Теперь образ собрался как надо, можем запускать наше приложение:

docker run --name hello -d work

    Смотрим в список работающих контейнеров и не видим там наше приложение. Почему?

    В папке есть второй скрипт, long.py. Давайте соберем образ с ним, предварительно скопировав новый dockerfile и заменив им прошлый:

cp ../Dockerfiles/Dockerfile_long ./Dockerfile
docker build -t long .

    Обратите внимание, сборка прошла быстрее, а в строчках вывода сборки появились сообщения Using cache.

    Запустим наше приложение и теперь можем увидеть, что с ним все ОК и в списке контейнеров оно работает:

docker run --name test_long -d long
docker container ls

    Подчищаем за собой:

docker stop test_long && docker rm $(docker ps -a -q) && docker rmi $(docker images -q)

Запустим свой web-сервер в Docker

    Переходим в каталог nginx и смотрим dockerfile:

cd ../nginx/
vim Dockerfile

    Правим custom.conf, подставив в плейсхолдер свой номер логина:

server {
    listen       80;
    server_name  docker.s<ваш номер логина>.edu.slurm.io; <-- Подправить!

    Собираем и запускаем Nginx в Docker. При запуске добавляем ключик --rm, чтобы контейнер после остановки удалился сам:

docker build -t nginx .
docker run --rm --name nginx -p 80:80 -d nginx

    Пробуем обращаться curl'ом или заходить через браузер в режиме "Инкогнито" на свой сайт

curl http://docker.s000099.edu.slurm.io
curl http://docker.s000099.edu.slurm.io/test

    Теперь давайте войдем внутри контейнера и посмотрим что там:

docker exec -it nginx /bin/bash

    Установим vim и внесем произвольные изменения в index.html:

apt-get update && apt-get install vim
vim /usr/share/nginx/html/index.html

    Теперь выйдем из контейнера, остановим его и затем запустим заново:

exit
docker stop nginx
docker run --rm --name nginx -p 80:80 -d nginx

    Зайдем снова внутрь контейнера и убедимся что все наши правки и vim пропали. Выйдем из контейнера:

docker exec -it nginx /bin/bash
vim
exit

    В dockerfile из которого был запущен контейнер, были обозначены переменные окружения. Проверим что они там есть:

docker exec nginx env

    Попробуем добавить еще одну переменную окружения при запуске контейнера, сперва остановив текущий:

docker stop nginx
docker run --rm --name nginx -p 80:80 -e abc=xyz -d nginx
docker exec nginx env

    Подчищаем за собой:

docker stop nginx && docker rmi $(docker images -q)

Best Practices

    Переходим в каталог best_practices/

cd ../best_practices

    Видим уже знакомые нам dockerfile, конфиг Nginx, а также папку с нашим кодом app. Пробуем собрать образ

docker build -t test_size .

    Замерим размер получившегося образа:

docker images

    Размер получился достаточно большой для запуска простого Nginx'а. Оптимизируем dockerfile. Изменим строку установки на:

RUN apt-get update && apt-get install -y \
    nginx \
 && rm -rf /var/lib/apt/lists/*

тем самым сократив количество слоев и добавив очистку кеша apt-get.

    Пробуем собрать еще раз образ и замерим размер:

docker build -t test_size_2 .
docker images

    Стало лучше, но давайте продолжим. У нас в папке лежит PDF-файл, который точно не нужен для работы нашего Nginx. Исключаем его из сборки через добавление .dockerignore, добавив туда также наш Dockerfile и .git:

touch .dockerignore
echo ".git" > .dockerignore
echo "Dockerfile" >> .dockerignore
echo "*.pdf" >> .dockerignore

    Собираем еще раз и смотрим как теперь:

docker build -t test_size_3 .
docker images

    Сделаем еще лучше. Изменим базовый образ на alpine. Для этого меняем первые три строчки нашего dockerfile на это:

FROM alpine

COPY . /opt/

RUN apk add --no-cache nginx && mkdir -p /run/nginx

    Собираем еще раз и смотрим как теперь:

docker build -t test_size_4 .
docker images

    С размером теперь стало гораздо лучше. Осталось еще немного причесать dockerfile.

    Опускаем оба COPY из Dockerfile'а ниже уровня EXPOSE
    Раздаем базовому образу и приложению конкретные версии

alpine:3.14.3
...
RUN apk add --no-cache --repository http://dl-cdn.alpinelinux.org/alpine/v3.14/main nginx=1.20.2-r0 \
 && mkdir -p /run/nginx

или

alpine:3.14.3
...
ENV NGINX_VERSION 1.20.2-r0

RUN apk add --no-cache nginx=${NGINX_VERSION} && mkdir -p /run/nginx

Итоговый dockerfile выглядит теперь вот так:

FROM alpine:3.14.3

ENV NGINX_VERSION 1.20.2-r0

RUN apk add --no-cache nginx=${NGINX_VERSION} && mkdir -p /run/nginx

EXPOSE 80

COPY . /opt/
COPY custom.conf /etc/nginx/conf.d/

CMD ["nginx", "-g", "daemon off;"]

---
В реальной работе с Docker необходимо будет работать с Dockerfile. При этом, крайне важно знать как правильно их писать, от этого будет зависеть скорость сборки и деплоя, размер образа и даже безопасность.
Исправьте нижеуказанный Dockerfile согласно Best Practices:

FROM ubuntu:latest
COPY ./ /app
WORKDIR /app
RUN apt-get update
RUN apt-get upgrade
RUN apt-get -y install libpq-dev imagemagick gsfonts ruby-full ssh supervisor
RUN gem install bundler
RUN curl -sL https://deb.nodesource.com/setup_9.x | sudo bash -
RUN apt-get install -y nodejs

RUN bundle install --without development test --path vendor/bundle
RUN rm -rf /usr/local/bundle/cache/*.gem 
RUN apt-get clean 
RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
CMD [“/app/init.sh”]

Ответ можно посмотреть здесь: https://habr.com/ru/company/southbridge/blog/452108/


FROM ruby:2.5.5-stretch

WORKDIR /app
COPY Gemfile* /app

RUN curl -sL https://deb.nodesource.com/setup_9.x > setup_9.x \
    && echo "958c9a95c4974c918dca773edf6d18b1d1a41434  setup_9.x" | sha1sum -c - \
    &&  bash  setup_9.x \
    && rm -rf setup_9.x \
    && apt-get -y install libpq-dev imagemagick gsfonts nodejs \
    && gem install bundler \
    && bundle install --without development test --path vendor/bundle \  
    && rm -rf /usr/local/bundle/cache/*.gem \
    && apt-get clean  \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* 

COPY . /app
RUN rake assets:precompile

CMD ["bundle", "exec", "passenger", "start"]
---
Необходимо запустить контейнер с MySQL версии 5.7. Сделать так, чтобы к этому контейнеру можно было подключится по порту 3306 прямо с сервера. Имя контейнера должно быть my-database.

docker run
	--detach
	--rm 
	-p 6603:3306
	--name=my-database 
	--env="MYSQL_ROOT_PASSWORD=123 
	mysql/mysql-server:5.7
---