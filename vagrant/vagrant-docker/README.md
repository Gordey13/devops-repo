vagrant up -- поднять вирутальную машину
docker rm -f nginx -- удалить контейнер
docker exec -it apache bash -- подключиться к консоли в контейнере
vagrant docker-exec nginx -it -- /bin/bash -- подключиться к контейнеру