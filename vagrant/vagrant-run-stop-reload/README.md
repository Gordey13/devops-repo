
vagrant ssh myserver -- подключиться к VM

Vagrant - запуск, остановка и перезагрузка машин
vagrant up -- включить VM
vagrant halt -- отключить VM. Отправить команду shutdown c сохранением изменений
vagrant reload -- перезапустить VM. Можно изменить параметры конфигурации. Будут применины конфигурации из vagrantfile, кроме provision.

Суть: VM сохраняет состояние после запуска и после остановки

Чтобы подтянуть изменения из Vagrantfile, блока provision
Команда vagrant provision - приводит VM к состоянию декларируемого в файле vagrantfile + блок provision

vagrant reload --provision -- перезапустить сборку VM + блок provision команды