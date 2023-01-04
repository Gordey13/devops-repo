Firewall == Internet (WAN) --- Firewall --- LAN
Network --- Kernel space --- User space
Сетевые интерфейсы eth1
Сетевые интерфейсы eth0
Маршрутизатор router
natfilter
	PREROUTING
	POSTROUTING
	FORWARD
	INPUT :: Входящий канал служб
	OUTPUT :: Исходящий канал служб
iptable Process Flow
	Нас интересует только таблица INPUT filter
	![[Pasted image 20221229142549.png]]

Отображение таблиц маршрутизации INPUT, OUTPUT, FORWARD
`sudo iptables -L -nv` :: Вывод таблицы filter 
`sudo iptables -L -t filter -nv` :: Вывести таблицу filter
`sudo iptables -L -t nat -nv` :: Вывести таблицу nat
	policy ACCEPT :: Политика фильтрации пакетов
	iptables :: Таблица для отображения по умолчанию filter

sudo ss -ntulp :: Отображение сетевых подключений UDP
sudo ss -ntlp :: Отображение сетевых подключений TCP
	1.  Netid :: отображает типы сокетов
	2.  State: отображает состояние сокета
	3.  Recv-Q: отображает количество принятых пакетов
	4.  Send-Q: отображает количество отправленных пакетов
	5.  Local address:port: отображает ip:port локальной машины
	6.  Peer address:port: отображает ip:port удаленной машины

iptables
	-A INPUT :: Добавить правило в конец списка (APPEND)
	-p tcp :: Протокол
	--dport=22 :: Порт
	-j ACCEPT :: Разрешение
`iptables -L -nv` :: Отобразить таблицу filter
	![[Pasted image 20221229145126.png]]
`iptables -A INPUT -i lo -j ACCEPT` :: Разрешить пакеты на Loopback интерфейс
`iptables -A INPUT -p icmp -j ACCEPT` :: Разрешить пакеты протокола icmp
`iptables -A INPUT -p tcp --dport=80 -j ACCEPT` :: Разрешить tcp пакеты на 80 порт
`iptables -A INPUT -p tcp --dport=443 -j ACCEPT` :: Разрешить tcp пакеты на 443 порт
	![[Pasted image 20221229150736.png]]
	- iptables правила читаются сверху вниз
`iptables -A INPUT -m state --state ESTABLISHED, RELATED -j ACCEPT`
`iptables -P INPUT DROP` :: Меняет политику фильтрации пакетов на policy: DROP. Уничтожение пакета
`iptables -P INPUT REJECT` :: Меняет политику фильтрации пакетов на policy: REJECT. Оповещение о блокировке пакета
`iptables -P INPUT ACCEPT` :: Меняет политику фильтрации пакетов на policy: ACCEPT. Разрешить любые пакеты
`iptables-save > ./iptables.rules` :: Сохранить настройки правил iptables в файл
![[Pasted image 20221229151958.png]]
`iptables-restore < ./iptables.rules` :: Восстановить правила для iptables из файла
`iptables -I INPUT -s 10.10.10.10 -j DROP` :: Удалять пакеты от ip 16.12312.10 на всех портах и протоколах

Автоматизация загрузки правил для firewall: 
`sudo  yum install iptables-persistent netfilter-persistent` :: Установить утилиту для загрузки правил firewall
При установки можно сохранить правила для ipv4 ipv6 в директорию `/etc/iptables`
`netfilter-persistent save` :: Сохранить правила для таблиц ipv4 ipv6
`netfilter-persistent start` :: Установить правила для таблиц IPv4 IPv6
`iptables -A INPUT -i enp0s3 -p TCP --dport 22 -j ACCEPT` :: Разрешить пакеты на  интерфейс enp0s3 и порт 22