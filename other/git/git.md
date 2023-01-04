Установка Git
`sudo apt-get install git`
`git --version`

как сделать ssh ключ для git?
На своей виртуалке сделай
`ssh-keygen -t rsa -b 4096 -C "твоя@почта-из-гита"`
из своей домашней директории возьми публичную часть ключа
`cat /home/yodo/.ssh/id_rsa.pub`

Потом на Github, зайди в Settings, раздел SSH ключи
И добавь туда содержимое своего публичного ключа из прошлой команды.

```

git config --global user.name "pyneng" - имя пользователя
git config --global user.email "github_email@gmail.com - email пользователя
git config --list - Настройки
ssh-keygen -t rsa -b 4096 -C "github_email@gmail.com" - Генерация нового SSH ключа
eval "$(ssh-agent -s)" - Запуск ssh-agent
ssh-add ~/.ssh/id_rsa - Добавить ключ в ssh-agent
cat ~/.ssh/id_rsa.pub - публичный ключ
ssh -T git@github.com - проверить
git remote set-url origin git@github.com:Gordey13/devops_lesson_trial.git
git config --list - конфигурация
ssh://git@github.com:Gordey13/devops_lesson_trial.git - SSH путь
```

зайти на свой Git и скопировать оттуда ssh ссылку на fork репозитория
`git clone твоя/ссылка/на/гит`

Задач DevOPS инженера является настройка CI/CD - создание конвейера, в котором разработчик пишет код, заливает его в гит, код проходит автоматические тесты после чего собирается и выкладывается на тестовое пространство

```
git config --global user.name "Gordey"
git config --global user.email gm-liker@yandex.ru
```

Создаем ветку (команды нужно делать в папке, в которую скачался репозиторий после git clone, обычно это название репозитория)
`git checkout -b dev`
`git checkout -b <имяветки>` является шорткатом для `git branch <имяветки>` (cоздание новой ветки из текущей) за которым идет 
git checkout <имяветки> (переключение на эту ветку)
`git status`
`git add . `
`git commit -m "Add new file"`
`git push`

rxrb0XiqLHRAg5yszRmT
```
Принудительно удалить файлы без подтверждения.
rm -rf 1.txt
Удалите все файлы, но оставьте 1.txt
rm -rf !(1.txt)
```
https://russianblogs.com/article/20231291223/

залить все наши измеения в github
`git push --set-upstream origin dev`

1. Получаем хэш-код коммита, к которому хотим вернуться.
2. Заходим в папку репозитория и пишем в консоль:
	git reset --hard hash куда хотим вернутся
	git push --force