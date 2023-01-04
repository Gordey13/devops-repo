$PATH - это системная переменная окружения  = /usr/bin/
etc/profile - прописана переменная PATH
which - где лежит программа
MY_FIRST_SCRIPT="abc" объявление переменной
echo $MY_FIRST_SCRIPT вызов и обращение к переменной
export MY_FIRST_SCRIPT содержимое этой переменной будет доступно и другим программам системы
./script.sh
chmod +x script.sh - прав на выполнение (буквы x)

Кавычки бывают трех типов
Двойные "" внутри двойных кавычек можно использовать переменные
Одинарные '' одинарные кавычки, то внутри них не подставляются переменные. Все внутри них считается текстом
Косые `` 

Фильтрация вывода
Отфильтруем вывод ls /etc/ и выведем на экран только то что содержит слово profile
ls -lh /etc/ | grep profile

Обработка вывода 
sed - поменять текст
sed -i 's/kak dela/how are you/' script.sh
awk - вывести столбец по счету

find - искать файлы в Linux 
по имени, по времени создания, изменения
find /var -name \*log 
* - любой символ

список загоним в переменную чтобы работать
FILE_LIST=`find /var -name \*log`

циклы for while 
#!/bin/bash
FILE_LIST='find /var -name \*log'
mkdir /home/logs
for FILE_NAME in $FILE_LIST ; do
cp $FILE_NAME /home/logs/
done

оператор if
#!/bin/bash
echo "Пожалуйста введите IP адрес сервера"
read IP_SERVER
if [ -z "$IP_SERVER" ]
then
    echo "$IP_SERVER введите еще раз"
else
    echo "$IP_SERVER спасибо, что ввели IP адрес"
fi

Функции - это куски кода, которые можно в скриптах использовать несколько раз. 
#!/bin/bash
hello_world () {
echo 'hello, world'
}
hello_world

