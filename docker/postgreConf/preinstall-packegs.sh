install #!/bin/bash
apt-get install gnupg -y
echo "deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main" >> /etc/apt/sources.list
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
apt-get update
apt-get install postgresql-9.6 python3-pip python3-dev libpq-dev -y
systemctl stop postgresql
pip3 install --upgrade pip
pip install psycopg2
pip install patroni[etcd]
echo "\
[Unit]
Description=Runners to orchestrate a high-availability PostgreSQL
After=syslog.target network.target

[Service]
Type=simple

User=postgres
Group=postgres

ExecStart=/usr/local/bin/patroni /etc/patroni.yml

KillMode=process

TimeoutSec=30

Restart=no

[Install]
WantedBy=multi-user.targ\
" > /etc/systemd/system/patroni.service
mkdir -p /data/patroni
chown postgres:postgres /data/patroni
chmod 700 /data/patroniпо
touch /etc/patroni.yml