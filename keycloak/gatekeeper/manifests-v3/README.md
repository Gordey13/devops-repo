# Подстановка данных из Secret 
Используем init container.
Данные из secret помещаем в среду окружения init контейнера.

В отдельном volume создаем конфигурационный файл, использую sed или 
[envsubst](https://www.opennet.ru/man.shtml?topic=envsubst&category=1&russian=2).

В основном контейнере подключаем volume со сгенерированным конфиг файлом.