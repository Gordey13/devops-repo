## Удалить лишнее.
В файле values.yaml удаляем все параметры, не используемые в чарте.
После этого обязательно проверяем работоспособность чарта c параметрами по умолчанию.
`helm template app ./openresty > app.yaml`

## Добавить нужное
В первую очередь должна быть сформирована документация к чарту. 
Что бы другие люди могли без проблем его использовать.

### Chart.yaml
Начнём с простого, добавим дополнительную информацию в Chart.yaml.
```yaml
home: https://github.com/Gordey13/devops-repo/helm
maintainers:
  - name: Gordey
```

### values.yaml
Настоятельно рекомендуется в файле values.yaml добавить комментарии,
описывающие параметры.

В директории myTemplates находится пример файла values.yaml с комментариями. 
Скопируйте этот файл в директорию с чартом.

### README.md
README.md - это основной файл документации по чарту.

В директории myTemplates находится пример файла README.md.
Скопируйте этот файл в директорию с чартом.

## Создание файла чарта.
Для создания чарта используем команду package:
`helm package openresty-art`

Итого будет создан файл openresty-art-0.1.0.tgz

## Публикация чарта.
Для публикации чарта подойдёт любой WEB серверер. Но мы воспользуемся
существующим https://github.com/

В директории helm создадим директорию charts. Перенесём в неё файл
openresty-art-0.1.0.tgz. Перейдём в эту директорию и создадим 
файл index.jaml
`helm repo index . --url https://raw.githubusercontent.com/BigKAA/youtube/master/helm/charts`

Запушим в github эту директорию со всеми файлами.

После этого можно пользоваться чартом, находящимся в https://raw.githubusercontent.com/BigKAA/youtube/master/helm/charts 

Подключим репозиторий.
```yaml
    helm repo add openresty-art https://raw.githubusercontent.com/BigKAA/youtube/master/helm/charts
    helm repo update
    helm repo list
    helm search repo | grep openresty
```
Если git приватный, т.е. для доступа к нему требуется логин и пароль. При добавлении репозитория 
потребуется ввести эти логин и пароль.