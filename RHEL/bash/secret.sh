#!/bin/bash

NS=development

kubectl delete secret postgres-logopass --namespace "$NS"

kubectl create secret generic postgres-logopass \
  --from-literal secret-key-base=xxxxxxxxxxxxxxxxxxxxxxxxx \
  --from-literal db-user='postgres' \
  --from-literal db-password='postgres' \
  --namespace "$NS"