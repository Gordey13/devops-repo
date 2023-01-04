#### Запускаем Jenkins.
Jenkins мощный инструмент, с его помощью выстраивают процесс Continuous Integration (CI). Docker позволяет “упаковать” приложение со всем его окружением и зависимостями в контейнер. В таком контейнере и будет “жить” Jenkins. Большим плюсом такой связки (Jenkins + Docker) будет, что Jenkins поднимится автоматически (вместе с докером), если машина на которой он был перезагрузилась (или другие проблемы). Начнем:

-   Устанавливаем [Docker](https://www.docker.com/ "Docker").
-   Заходим в настройки Docker’а и даем ему доступ к диску, где будут храниться все данные Jenkins’а. Settings -> Shared Drives. (я дал доступ к диску С).
- Это необходимо, что бы при повторном запуске контейнера все данные не были потерянны. Иначе Jenkins стартует чистый с default settings.
-   Команда запуска контейнера:
```xml
 docker run -p 8081:8080 -p 50000:50000 --restart unless-stopped  -v C:/Users/Vladimir/Documents/Jenkins:/var/jenkins_home jenkins
```

#### Расммотрим команду:
- p Jenkins поднимится на localhost:8081. Если нужно запустить на другом порту - замените 8081 на нужный. Второе значение менять не нужно.
– restart флаг говорит, что контейнер будет перезапущен, если докер упадет по ошибке.
- v флаг указывает path, где будут храниться все данные Jenkins’а. (об этом говорилось выше) (C:/Users/Vladimir/Documents/Jenkins - замените на свой путь)

#### Настраиваем Jenkins для дальнейшей работы.
После успешного запуска Jenkins, будет написано
```xml
INFO:

Jenkins initial setup is required. An admin user has been created and a password generated.
Please use the following password to proceed to installation:

0e254d78e77e412ab623d5ac1d58e7d9

This may also be found at: /var/jenkins_home/secrets/initialAdminPassword
```
- **0e254d78e77e412ab623d5ac1d58e7d9** - это пароль Administrator password (у вас будет другой). Его необходимо ввести на **localhost:8081**
- Все готово. Дальше следуем инструкциям и создаем профиль админа.

#### Полезные команды докера.
1.  Получить список контейнеров  
    (если не указать ключ -a, то будет показаны только работающие контейнеры)  
    **docker ps -a**
2.  Для того, чтобы остановить контейнер  
    **docker stop CONTAINER ID**
3.  Удалить контейнер (можно удалить только остановленный контейнер).  
    Команде можно передать как CONTAINER ID, так и NAME  
    **docker rm CONTAINER ID**
	Понадобится когда захотим остановить контейнер и освободить порты.