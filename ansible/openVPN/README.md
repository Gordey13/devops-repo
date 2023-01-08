vagrant box add ubuntu.amd64
vagrant init
vagrant up

ssh-copy-id 192.168.0.215
sudo adduser gordey sudo
vagrant ssh
ssh 192.168.0.215
cat ~/.ssh/id_rsa.pub
mkdir ~/.rsa
echo "ssh-rsa ADASS..." > ~/.ssh/autorized_keys
chmod 440 ~/.ssh/autorized_keys

ansible-galaxy --help (Бинарник для работы репой ролей)
ansible-galaxy role init  
molecule role --help - тестирование ролей

ansible-galaxy role init ansible-role-openvpn

Берем инструкцию и переводим в ansible автоматизацию
Устанавливаем пакеты
ansible-playbook -i inventories/vagrant/hosts -vD playbook.yml