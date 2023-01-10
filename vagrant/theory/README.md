Уровни именования виртуальных машин:
level 1 : Bringing machine 'default' up with 'virtualbox' provider…
level 2 : Setting the name of the VM: Vagrant_default_1599853387302_14104
level 3 : Name USER localhost

Обращаться для подключения к VM по имени vagrant ssh default
vagrant ssh-config
vagrant ssh hostname

Название машины VM на всех уровнях одинаково:
Vagrantfile именовать машину на level 1:
    config.vm.define "gitlab"

Vagrantfile именовать машину на level 2:
    config.vm.provider "virtualbox" do |vb|
        vb.name = "gitlab"
    end

Vagrantfile именовать машину на level 3:
    config.vm.hostname = "gitlab"

box -- виртуальная машина с установленной ОС

Registry VargatBox
https://app.vagrantup.com/boxes/search
vagrant init ubuntu/trusty64
```bash
Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/trusty64"
  end
```
vagrant up

wget ... -O virtualbox.deb -- скачать пакет и назвать virtualbox.deb
sudo apt-get install ./virtualbox.deb -- установить из пакета

ssh vagrant@127.0.0.1 -p 2222 -l /home/gordey/Vagrant/.vagrant/machines/default/virtualbox/private_key

vagrant destroy -- Уничтожить виртуальную машину
vagrant destroy -f -- Уничтожить VM

sudo apt-get install -y wget unzip
wget https://releases.hashicorp.com/vagrant/2.2.10/vagrant_2.2.10_linux_amd64.zip -0 vagrant.zip
unzip vagrant.zip
sudo mv vagrant /bin/