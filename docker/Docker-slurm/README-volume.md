docker volume используется в основном для отладки приложений и активной разработки, а bind mount для долговременного хранения

---
Инструкция подключения к стенду. Чтобы запустить стенд данного модуля, нужно запустить стенд с любой страницы данного модуля.
Практическая работа:

Переходим в каталог docker_course/practice/3.volumes

Создадим тестовый том:

docker volume create slurm-storage

Вот он появился в списке:

docker volume ls

А команда inspect выдаст примерно такой список информации в json:

docker inspect slurm-storage
[
    {
        "CreatedAt": "2020-12-14T15:00:37Z",
        "Driver": "local",
        "Labels": {},
        "Mountpoint": "/var/lib/docker/volumes/slurm-storage/_data",
        "Name": "slurm-storage",
        "Options": {},
        "Scope": "local"
    }
]

В какой-то момент в Docker была введена команда --mount на замену -–volume, но старый синтаксис (и даже местами старое поведение) оставили для совместимости. Попробуем как-то использовать созданный том, запустим с ним контейнер:

docker run --rm --mount src=slurm-storage,dst=/data -it ubuntu:18.04 /bin/bash
echo $RANDOM > /data/file
cat /data/file
exit

А после самоуничтожения контейнера запустим абсолютно другой и подключим к нему тот же том. Проверяем, что в нашем файле:

docker run --rm --mount src=slurm-storage,dst=/data -it centos:8 /bin/bash -c "cat /data/file"

Вы должны увидеть то же самое значение.

А теперь примонтируем каталог с хоста:

docker run --mount src=/srv,dst=/host/srv,type=bind --name slurm --rm -it ubuntu:18.04 /bin/bash

Помните, что docker не любит относительные пути, лучше указывайте абсолютный!

Теперь попробуем совместить оба типа томов сразу:

docker run --mount src=/srv,dst=/host/srv,type=bind --mount src=slurm-storage,dst=/data --name slurm -it ubuntu:18.04 /bin/bash

Отлично, а если нам нужно передать ровно те же тома другому контейнеру?

docker run --volumes-from slurm --name backup --rm -it centos:8 /bin/bash

Вы можете заметить некий лаг в обновлении данных между контейнерами, это зависит от используемого Docker драйвера файловой системы.

Создавать том заранее необязательно, всё сработает в момент запуска docker run:

docker run --mount src=newslurm,dst=/newdata --name slurmdocker --rm -it ubuntu:18.04 /bin/bash

Посмотрим теперь на список томов:

docker volume ls

Ответ будет примерно таким:

DRIVER    VOLUME NAME
local     slurm-storage
local     newslurm

Ещё немного усложним нашу команду запуска, создадим анонимный том:

docker run -v /anonymous --name slurmanon --rm -it ubuntu:18.04 /bin/bash

Помните, что такой том самоуничтожится после выхода из нашего контейнера, так как мы указали ключ -–rm

Если этого не сделать, давайте проверим что будет:

docker run -v /anonymous --name slurmanon -it ubuntu:18.04 /bin/bash

И увидим что-то такое:

docker volume ls
DRIVER    VOLUME NAME
local     04c490b16184bf71015f7714b423a517ce9599e9360af07421ceb54ab96bd333
local     newslurm
local     slurm-storage

---
