digital-worker 	digital-worker 	в файле /egov/tomcat/conf/app/digital.properties 	добавить запись в параметр

digital.kafka.topics={...'GIBDD_DRIVER_LICENSE_COPY':3}

В кафке РП выполнить
bin/kafka-topics.sh --create --zookeeper {{ join "," .Values.jms.kafka.rp.hosts }} --replication-factor 3 --partitions 3 --topic getGibddDriverLicense_result

В кафке ЦП
bin/kafka-topics.sh --create --zookeeper 10.81.5.20:9092,10.81.5.24:9092,10.81.5.30:9092 --replication-factor 3 --partitions 3 --topic GIBDD_DRIVER_LICENSE_COPY 

digital.kafka.bootstrap.servers=10.81.5.20:9092,10.81.5.24:9092,10.81.5.30:9092