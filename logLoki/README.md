# FLG
Установка стека FluentBit - Loki - Grafana
Почему Fluentbit а не Portmail? Потому что первый у нас используется
везде, умеет многострочные логи, мы его хорошо знаем и не придется переделывать
инфраструктуру сбора логов.

## Minio
В качестве хранилища, будем использовать minio.
[Процесс установки minio](../minio)
## Loki
[Установка loki](01-loki)
## Grafana
[Установка Grafana](02-grafana)
## Fluentbit
[Установка Fluentbit](03-fluentbit)