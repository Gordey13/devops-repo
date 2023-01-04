Установка пакетов из файла
pip install -r requirements.txt

Заполняем инвентарный файл host
	192.168.1.120 - K8S-Master-1
	192.168.1.121 - K8S-Master-2
	192.168.1.122 - K8S-Master-3
	192.168.1.123 - K8S-Worker-1
	192.168.1.124 - K8S-Worker-2

[kube-master]
	master1
	master2
	master3
[etc]
	master1
	master2
	master3
[kube-node]
	node4
	ingress1
[kube-ingress]
	ingress1
[k8s-cluster:children]
kube-node
kube-master