На все ноды Установить sudo apt install sshpass 
sshpass==1.06

inventory/dev/host.ini
192.168.0.120
192.168.0.121
192.168.0.122
192.168.0.123
192.168.0.124

for i in `cat inventory/dev/host.ini`; do ssh -t gordey@$i "sudo apt-get install sshpass -y"; done
ansible-playbook -u gordey -i inventory/dev/inventory.ini cluster.yml -b --diff -kK --ask-pass
Разворачивается от 20 до 40 минут.

ИЗМЕНИЛ версию K8S с  v1.22.15 на v1.22.2
FAILED! => {"msg": "AnsibleMapping([(u'netcheck_server', AnsibleMapping([(u'enabled', u'
 ..... 
 'dict object' has no attribute u'v1.22.15'"}

УБРАЛ в запуске плейбука флаг --ask-pass
fatal: [master1]: FAILED! => {"changed": false, 
"cmd": "sshpass -d8 /usr/bin/rsync --delay-updates -F --compress --archive --rsh=/usr/bin/ssh -S none -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null --rsync-path=sudo rsync --out-format=<<CHANGED>>%i %n%L gordey@********92.********68.0.********20:/tmp/kubespray_cache/kubectl-v********.22.2-amd64 /tmp/kubespray_cache/kubectl-v********.22.2-amd64", 
"msg": "Warning: Permanently added '********92.********68.0.********20' (ECDSA) to the list of known hosts.\r\nsudo: no tty present and no askpass program specified\nrsync: connection unexpectedly closed (0 bytes received so far) 
1[Receiver]\nrsync error: error in rsync protocol data stream (code ********2) at io.c(235) [Receiver=3.********.2]\n", "rc": "VALUE_SPECIFIED_IN_NO_LOG_PARAMETER"}

отключить требование sudo tty: sed -i 's/Defaults requiretty/Defaults !requiretty/g' /etc/sudoers (это на всех узлах, которые вы используете Ansible)
измените ansible.cfg, чтобы иметь флаг tty для ssh http://docs.ansible.com/ansible/intro_configuration.html#ssh-args (это только на узле, на котором вы выполняете Ansible)
Какие именно переключатели вам нужны: ssh_args = -tt
https://stackoverflow.com/questions/39700335/ansible-synchronize-module-error-no-tty-present-and-no-askpass-program-specifi

enabling NOPASSWD on /etc/sudoers for the user
ВКЛЮЧИТЬ без пароля SUDO
Флаги -kK устарели используйте -b and --ask-become-pass

While the "no tty present" etc. error might suggest requiretty in /etc/sudoers being the culprit, it's disabled by default on Ubuntu 14.04, so it appears to be a red herring (and I added Defaults: !requiretty just to be sure, to no avail).


УБРАЛ -kK
fatal: [master2]: FAILED! => {"msg": "Missing sudo password"}


sudo -i - переключиться на УЗ root
sudo passwd root - изменить пароль УЗ root
sudo -i -u gordey - переключиться на УЗ gordey
sudo passwd -dl root - отключить root УЗ

ssh-copy-id Permission denied (publickey)
ssh-copy-id -i ~/.ssh/id_rsa.pub root@192.168.0.121
ssh -v -i ~/.ssh/id_rsa root@192.168.0.121

sudo -i
sudo passwd root
nano /etc/ssh/sshd_config
#PasswordAuthentication yes
PermitRootLogin yes
systemctl restart ssh
ssh-copy-id -i ~/.ssh/id_rsa.pub root@192.168.0.102
/root/.ssh/authorized_keys

-----BEGIN RSA PRIVATE KEY-----
MIIEpQIBAAKCAQEAz9lIfCeXLOq2n/FLfsOtliniZnat4UmoN2OTWCMUfqyycuK9
5ObMvxp1YY+QIwsgwtp2GKrtGShFbFRbfRESr+QvILgRdHkTKhCYlTWyupJoGskT
nPI53Wu89y9cxgHg1ynLUabnHUGe2zbFjSo4xaCnlpN4aLISkFaYxuL5GAavnQTW
//PGb5zrHcD3jMOjkYW3NOuynQ3oi4yLJLAZZp64iUjO0ozLDKMHdCrbcW8x/bq0
AS6odYEjszDqTg+JY1VH2qAgYEvKWAtu8VPorXjyQUw+MQ7Dtz/xmT6MeZe9LWGH
RZPSkecb0zwYlZ/B1uY0Uk32Eob+aSrt0qgGaQIDAQABAoIBAQCWXnb/Q1EucLwg
qFva4MwTqEefo1qWc0hckhCGIhLwthX/4aRKFuOnmgezxj4b7DAOaCgqHnabzbOz
9K+foptnXujtfd0662D+/LS2tfuQ2NyyDCjBUcilNQ2nsr8mjTNR1m2+q8XmN5Qq
ucxgHVynNVwpJpVlAPdHLy8mLAzT4KykAHu1NZ5TQyxmYeGfbCHjP26Z0zgCMjy4
CA8GTdB9avM3NNjouwr2+OTdFnoYHSC5/KwdmMVUiyUUMfPKRIKMexWEStsHmmtX
zBPsZgxvfwHVM0dcM7sKQjNVWIVydF4AEf9s27o4NhG80/IPSfQwQ0E4bznFchsP
T7N4P7OBAoGBAOhYIuNj41wSV6HW2akje2msxzAuzlGOFCm1eUCY88oNo0LBu9oF
9R4qDijhevuWUkP62OQ7A/MxSlhRSzSFjfMjjasrZ98qSAR8ipdxbvI+hPXPoje8
tbYom6mz3iVMdH1pfCwC5+iVaLmmh5Rq9sFiFtA5FLwoRa9eyO59RY/ZAoGBAOUC
sPAQW/dESl5tvVkKfKF058/RE+o6IaAn1W4t/4RV70Ux92CHkTmIc2Iql0H8c++Z
GdtAbj0BN1eCn2eySqY9+nPUsdi93DvPjV6s63mj8KXEU+sltgdXs6/7YpoIdfhj
gEh7c06BrwFJ/NM9MjPRuxN0j+lx2ZhVrD1k4qERAoGBAMxfUnjwETqYy8qIwTbd
Bh6DI0bHtSXZsvSpMznWEINHkbcT0JhLqzvYRFJDXDlXFY/EY+oF20icr8eV4nAV
ljIrsN7CtICBoY2IuyPRXITq52uNMySR8siDWcFhfOMUKFd0ZQwVlkZovhCnYhT0
LY8XJ/gKbanARuOmnVniiUCpAoGBALpkp1itJ/0oUxNqZEu9klTjTu3BcWEZ8VZm
NXvY6nhubTG3im3ByXy3R5plqfjmHgKsbPQcC92RSNbsFQwUfFe0aE2wlxQe68qu
kpS1T28Q9QQmuFrStcZiJnkctVNDgakqazYTbHVAbg0xiBryWxL8KDSckalipcUs
LeVGYILRAoGAMir/fhTqUdwm2UXMFcIXDEi/Iksg3l4zPA4emzYX73XDsT72DTyd
3phuV2jFr/yVQZ2+KzWk6ufPEaqg9NOa5lqU/mq89Xc1GtfLf/eg+mOPq/5Z5phU
8uuqHlaSDS2fYiT7t487pIOTGNR+6pBhiGmhY1AjwJbrRCMwX3VRTY4=
-----END RSA PRIVATE KEY-----


ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDP2Uh8J5cs6raf8Ut+w62WKeJmdq3hSag3Y5NYIxR+rLJy4r3k5sy/GnVhj5AjCyDC2nYYqu0ZKEVsVFt9ERKv5C8guBF0eRMqEJiVNbK6kmgayROc8jnda7z3L1zGAeDXKctRpucdQZ7bNsWNKjjFoKeWk3hoshKQVpjG4vkYBq+dBNb/88ZvnOsdwPeMw6ORhbc067KdDeiLjIsksBlmnriJSM7SjMsMowd0KttxbzH9urQBLqh1gSOzMOpOD4ljVUfaoCBgS8pYC27xU+itePJBTD4xDsO3P/GZPox5l70tYYdFk9KR5xvTPBiVn8HW5jRSTfYShv5pKu3SqAZp root@admin

Установка пакетов из файла
apt install pip
pip install -r requirements.txt

sh _deploy_cluster.sh gordey
sudo apt-get install mc
ansible-playbook -i inventory/dev/inventory.ini --become --become-user=root cluster.yml
--become --become-user=root
ansible-playbook -u root -i inventory/dev/inventory.ini cluster.yml -b --diff
ansible-playbook -i inventory/dev/inventory.ini cluster.yml
ssh -t gordey@$i "sudo apt-get install sshpass -y"
reboot
ansible-playbook -u "$1" -i inventory/s000000/inventory.ini cluster.yml -b --diff
usermod -aG sudo gordey
ansible-playbook -u gordey -v -i inventory/dev/inventory.ini cluster.yml -b --diff
ПРОБЛЕМЫ зависания решились УДАЛЕНИЕМ -tt из файла ansible.cfg ssh_args = -tt
Версия кластера 1.22.2
sudo -i
ansible-playbook -u root -i inventory/s000000/inventory.ini cluster.yml -b --diff

ssh-copy-id gordey@192.168.0.109
ssh-copy-id gordey@192.168.0.108
ssh-copy-id gordey@192.168.0.107

Cоздадим playbook для подготовки системы на всех нодах prerequisites.yml
ansible-playbook -u gordey -i inventory/dev/inventory.ini prerequisites.yml -b --ask-become-pass

Если вы хотите переопределить записи в /etc/sudoers
Новая запись должна выглядеть так
user ALL=(ALL) NOPASSWD: ALL - для одного пользователя или
%group ALL=(ALL) NOPASSWD: ALL - для группы.

Для одного пользователя добавьте эту строку в конец файла sudoers с помощью команды sudo visudo: 
gordey ALL=(ALL) NOPASSWD:ALL
Для группы 
%gordey  ALL=(ALL) NOPASSWD:ALL

#includedir /etc/sudoers.d
sudo visudo -f /etc/sudoers.d/file_to_edit

RUN \
  useradd -U foo -m -s /bin/bash -p foo -G sudo && passwd -d foo && passwd -d root && \
  sed -i /etc/sudoers -re 's/^%sudo.*/%sudo ALL=(ALL:ALL) NOPASSWD: ALL/g' && \
  sed -i /etc/sudoers -re 's/^root.*/root ALL=(ALL:ALL) NOPASSWD: ALL/g' && \
  sed -i /etc/sudoers -re 's/^#includedir.*/## Removed the #include directive! ##"/g' && \
  echo "Customized the sudoers file for passwordless access!" && \
  echo "foo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
  echo "root ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers && \
  echo "foo user:";  su foo -c 'whoami && id' && \
  echo "root user:"; su root -c 'whoami && id'

  Что происходит с приведенным выше кодом:

- Пользователь и группа foo созданы.
- Пользователь foo добавляется как в группу foo, так и в группу sudo.
- Домашний каталог установлен в /home/foo.
- Оболочка установлена ​​в /bin/bash.
- Команда sed вносит встроенные обновления в файл /etc/sudoers, чтоб- предоставить пользователям foo и root доступ без пароля к группе sudo.
- Команда sed отключает директиву #includedir, которая позволяет любы- файлам в подкаталогах переопределять эти встроенные обновления.

sudo visudo -f /etc/sudoers
```
# User privilege specification
root    ALL=(ALL:ALL) NOPASSWD: ALL

# Members of the admin group may gain root privileges
%admin ALL=(ALL) ALL

# Allow members of group sudo to execute any command
%sudo   ALL=(ALL:ALL) NOPASSWD: ALL

# See sudoers(5) for more information on "#include" directives:

#includedir /etc/sudoers.d

gordey ALL=(ALL) NOPASSWD: ALL
%gordey  ALL=(ALL) NOPASSWD: ALL
```
sudo systemctl stop ufw; sudo systemctl disable ufw

ansible-playbook --user=gordey -v -i inventory/dev/inventory.ini -k --become --become-user=root --become-method=su ~/kubespray/cluster.yml --diff

sudo apt-get install dbus -y
sudo systemctl status dbus

--ask-become-pass