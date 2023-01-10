ssh notebook
sudo apt update
sudo apt-get install vagrant
wget https://app.vagrantup.com/centos/boxes/7/versions/2004.01/providers/virtualbox.box -O virtualbox.box
NEW!!! wget https://app.vagrantup.com/ubuntu/boxes/focal64/versions/20230107.0.0/providers/virtualbox.box -O focal64.box 

vagrant box add --name centos7.box
enp7s0

vagrant box add ubuntu ubuntu.box --provider virtualbox
vagrant box add centos centos7.box --provider virtualbox
vagrant init ubuntu -- Инициализировать файл vagrantfile
vagrant up

sudo apt-get remove docker docker-engine docker.io containerd runc

server.vm.synced_folder "/home/gordey/vagrant-zabbix/compose","/home/ubuntu"

    sudo apt-get update
    sudo apt-get install \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg-agent \
        software-properties-common \
        docker-ce \
        docker-compose \
        docker-ce-cli \
        git \
        containerd.io -y
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo apt-key fingerprint 0EBFCD88
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo usermod -aG docker $USER
    https://github.com/vanohaker/zabbix-compose/blob/main/docker-compose-server-amd64.yaml -O srv-zabbix.yaml
    docker-compose -f server-zabbix.yaml up -d

docker stop $(docker ps -a -q)
docker container rm $(docker ps -a -q)

