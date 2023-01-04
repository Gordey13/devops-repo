# Cистема сбора логов с асинхронной очередью
Необходимо сделать процесс добавление логов в elastic асинхронным

Задача: 
1. Настроить Kafka
2. Настроить сборщик логов fluentbit на передачу логов в Kafka
3. Настроить vector https://vector.dev/docs забирать логи из kafka и сохранять их в ElasticSearch

За основу берём чарты от Bitnami:
- Kafka: https://github.com/bitnami/charts/tree/master/bitnami/kafka
- ElasticSearch: https://github.com/bitnami/charts/tree/master/bitnami/elasticsearch
- Vector: https://helm.vector.dev
- Fluentbit: https://fluent.github.io/helm-charts
- WEB интерфейс: https://github.com/obsidiandynamics/kafdrop для kafka. Модифицировал charts/kafdrop

Вместо ElasticSearch можно использовать клон Opensearch (https://opensearch.org/docs/latest). 
Я сделал чарт  обертку charts/opensearch, в котором сразу и opensearch и opensearch dashboards (клон kibana).
