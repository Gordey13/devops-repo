Nginx - http-proxy-сервер. Балансер
Получает запрос пользователя, отправить его на backend php-fpm, 
когда FPM ответит Nginx-у о том что тот самый первый запрос обработан и отдаст ответ, 
Nginx передаст ответ назад пользователю.

FPM это полноценный менеджер процессов, который следит за
выполнение процессов, ограничениями, утечками памяти и т.д

Пакетный менеджер - это программа которая подключается к репозиторию, 
читает список от чего зависит данная программа, 
скачивает и устанавливает ПО и занимается его удалением.
apt-get install <название> для debian / ubuntu
yum install <название> для redhat / centos

Главный пользователь в Linux - это root
Команда sudo позвоялет пользователям запуск команд с правами root

sudo apt update && sudo apt upgrade -y
sudo apt-get install wget

man wget - справка по этой команде.

Midnight Commander (MC) - создавать, удалять, копировать, переименовывать файлы, папки, 
редактировать файлы и переходить из каталога в каталог
Вызов mc
sudo apt-get install mc - Установить

В одной панели вы можете работать с файлами локально, а в другой на удаленном хосте.
Функциональные клавиши клавиатуры F1-F10
Переключение между панелями происходит по клавише Tab.

Когда открыто меню или всплывающее окно. К примеру, если нажать F2, 
то мы вызовем всплывающее окно в котором можем выбрать что сделать с файлом - запаковать, просмотреть, скопировать и т.д. 

В mc две области видимости:
    Файловый менеджер
    Консоль
Переключается область видимости сочетанием клавиш Ctrl + o

- Любой объект файловой системы это файл. 
Бывают файлы с разными свойствами - текстовый, бинарный, сокет, буфер, директория, ссылка и др.
- Система директорий в *nix древовидная. Корень обозначается как "/"
- Любой примонтированный диск ассоциируется с папкой в этой древовидной системе
- В каждой директории содержатся два служебных файла
Один из них обозначается точкой - это указатель папки на саму себя.
Второй обозначается двумя точками - это указатель на папку выше в иерархии.

Создавать F7 и удалять F8 директории
/tmp особенность в том, что она очищается при перезагрузке системы
mkdir  имя_Каталога

Создать и отредактировать файл 
touch NewFile.txt для создания пустого файл
Просмотреть F3 или отредактировать F4
Midnight Commander идет в комплекте редактор mcedit

Текстовый редактор по умолчанию
cd ~ и открываем файл .bashrc
Не существует, создай
export $EDITOR="/usr/bin/mcedit"

Две панели для копирования/перемещения файла
перейти в правую панель Tab и перейти в папку /tmp
Возвращаемся в левую панель Tab
Наводим курсор на файл .bashrc и нажимаем F5

sudo apt install --no-install-recommends 
    nginx /
    mariadb-server /
    php /&
    php-fpm /
    php-zip /
    php-mysql /
    php-curl /
    php-gd /
    php-mbstring /
    php-xml /
    php-xmlrpc

sudo mysql -u root - установить пароль пользователю root в базу

MariaDB > set password for 'root'@'localhost' = PASSWORD('ieyah7Aew6oom8ohsooghies');
MariaDB > exit;

проверить запущены ли сервисы systemctl
systemctl status nginx

что в windows называется сервис, в linux называется "демон"
"демон" - это постоянно запущенная программа
За запуск, остановку, перезапуск и мониторинг состояния демона отвечает менеджер инициализации

ubuntu менеджер инициализации systemd
Утилита systemctl посредник для общения с systemd
Запрос на запуск или остановку демона, либо запрашивать его статус
systemctl status mаriadb - Проверим запущен ли MySQL
sudo systemctl start nginx - Запустить nginx

Конфиг Nginx лежит тут /etc/nginx/nginx.conf 
cat /etc/nginx/nginx.conf - Вывести содержимое файла

include создавать для каждого сайта  свой конфиг.
Nginx подгрузит все содержимое папки /etc/nginx/conf.d/*conf в один большой конфигурационный файл 

Закрывайте nginx.conf нажав Ctrl-X

sudo wget http://distrib.sipteco.com/website.conf
Выполнить консольную команду Ctrl + o
Отредактируем F4

Веб-сервер может обрабатывать запросы на множество сайтов
Поле server_name нужно вебсерверу чтобы распределять входящие запросы и понимать какой запрос какому сайту отправить. 

server {
    listen 80;
    listen 443;
    server_name ubuntu-wordpress.ru www.ubuntu-wordpress.ru; доменное имя сайта.
    set $rootpath /var/www/ubuntu-wordpress.ru/; указываем путь до корня сайта
    root $rootpath; определяем что корень сайта находится в переменной rootpath
    client_max_body_size 8M; необходимо для установки некоторых модулей wordpress
access_log /var/log/nginx/ ubuntu-wordpress.ru _access.log; указываем пути до логов
error_log /var/log/nginx/ ubuntu-wordpress.ru _error.log;
    location / {
    root $rootpath;
    index index.html index.php index.htm;
    try_files $uri $uri/ @notfound;
    location /wp-admin { #если сайт будет открыт для всего интернета, то в целях безопасности стоит закрыть доступ до админки сайта для всех кроме разрешённыS
    index index.php;
    try_files Suri Suri/ /index.php?Sargs;
    allow 127.0.0.1/32;
    allow <Ваш_ip>/32;
    deny all;
    location -* \.(jpg|jpeg|gif|css|png|js|ico|html)$ { #настроим кеширование статических файлов для уменьшения расхода трафика и увеличения скорости работы $
    expires 180m;
    }
    location ~* \.php$ { #самый важный локейшн для сайта
    root $rootpath;
    try_files $uri = 404; #указываем что если не получилось найти файл - отдать ошибку
    fastegi_split_path_info "(.+\.php)(/.+)$; #необходимо для безопасности
    fastcgi_pass unix:/var/run/php-fpm/php73-ubuntu-wordpress.sock; #указываем путь к сокету или к порту пула php-fpm (это настроим позднее)
    fastcgi_index index.php; #несколько служебных параметров необходимых для корректной работы сайта
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    include fastcgi_params;
    location @notfound {
    error_page 404 /4xx.html;
        return 404;

sudo systemctl reload nginx - для изменения конфигов в памяти nginx. Необходимо перезагрузить nginx
загрузим наш измененный конфиг в память nginx

sudo mkdir -p /var/www/ubuntu-wordpress.ru/
chown - это команда которая передает права : \
-Rsudo chown -R www-data:www-data /var/www/
Конфиги PHP-FPM лежат /etc/php/7.2/fpm/pool.d/
Удаляем файл www.conf стандартный и создадим свой cd /etc/php/7.2/fpm/pool.d/
rm  /etc/php/7.2/fpm/pool.d/www.conf
Нажимайте Tab когда пишете путь. Он поможет вам автоматом дописывать сам путь.
Скачаем файл конфига wget http://distrib.sipteco.com/ubuntu-wp.conf

sudo systemctl reload php7.2-fpm - Проверим все ли окей 
sudo systemctl restart php7.2-fpm - перезапустим php-fpm 
sudo systemctl  status php7.2-fpm - все огонь работает! 

touch /var/www/ubuntu-wordpress.ru/index.php
nano /var/www/ubuntu-wordpress.ru/index.php
<?php phpinfo(); phpinfo(INFO_MODULES); ?>

MySQL как самый популярный вариант
mysql -u root -p
create database wp_mysitedb; - Создадим базу данных для Wordpress
CREATE USER 'wpuser'@'localhost' IDENTIFIED BY '1';  Создадим пользователя wpuser с паролем 1
'wpuser'@'localhost' после собаки указывает адрес с которого вы будете подключаться. 
wpuser1@<адрес с которого обращается веб сервер>
Дадим пользвателю wpuser права на чтение и запись к базе
GRANT ALL PRIVILEGES ON  wp_mysitedb. * TO 'wpuser'@'localhost';
FLUSH PRIVILEGES;

В linux нет "расширений" у файлов как в windows. 
файл называется latest-ru_RU.tar.gz
скачаем в него архив с wordpress
sudo wget https://ru.wordpress.org/latest-ru_RU.tar.gz

Распакуем при помощи tar
ключ -z Tar сам запустит gzip
ключ -x говорит команде tar чтомы распаковываем, а не запаковываем
ключ -v  показывает результат работы (verbose)
ключ -f говорит о том что мы распаковываем именно файл с архивом

tar -xzvf latest-ru_RU.tar.gz
про все опции tar ты можешь прочитать при помощи man tar

cp - команда копирования 
ключ -r скопировать рекурсивнно - все что лежит внутри
-p ключ говорит сохранить все права на файл не перезаписывая их 
wordpress/* говорит, что надо сначала скопировать именно файлы внутри wordpress

Дадим nginx права
chown -R nginx:nginx /var/www/ubuntu-wordpress.ru
chown -R www-data:www-data /var/www/ubuntu-wordpress.ru