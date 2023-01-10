Box -- установка бокса для системы виртуализации Virtualbox...
Образ Box'a подходят друг к другу, если одна система виртуализации. К примеру virtualbox.

vagrant box <subcommand> [<args>]
    add -- добавить Box
    list -- оторбразить список Box
    outdated -- проверка на устаревание Box образов
    prune -- удалить все старые Box
    remove -- Удалить Box образ
    repackage --
    update -- Обновить версию Box образа

vagrant box add centos/7 --provider virtualbox :: Добавить Box образ centos/7 для системы виртуализации:
    virtualbox
    vmware
    hyperv
    libvirt

vagrant box list -- Отобразить существие образы в распоряжение

vagrant box remove --box-version -- удалить образ Box по версии
vagrant box remove ubuntu/xenial64 --box-version 20200904.0.0

vagrant box update --box ubuntu/xenial64 -- обновить образ Box
vagrant box outdated --global -- проверка всех Box на устаревание образов