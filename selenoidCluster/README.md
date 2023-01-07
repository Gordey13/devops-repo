1 Selenoid == 2Gb Memory
- Создаем сеть для контейнеров с сессиями браузеров:
`docker network create selenoid_1`
- Запускаем контейнер с Selenoid:
`docker run -d --name selenoid_1 -p 4445:4444 --net=selenoid_1 -v /var/run/docker.sock:/var/run/docker.sock -v /home/$USER/.aerokube/selenoid:/etc/selenoid:ro aerokube/selenoid -limit=12 -capture-driver-logs -max-timeout=0h30m0s -container-network=selenoid_1`

- Создаем сеть для контейнеров с сессиями браузеров:
`docker network create selenoid_2`
- Запускаем контейнер с Selenoid:
`docker run -d --name selenoid_2 -p 4446:4444 --net=selenoid_2 -v /var/run/docker.sock:/var/run/docker.sock -v /home/$USER/.aerokube/selenoid:/etc/selenoid:ro aerokube/selenoid -limit=12 -capture-driver-logs -max-timeout=0h30m0s -container-network=selenoid_2`

- Создаем конфигурационный файл selenoid:
\devops-repo\selenoidCluster\.aerokube\selenoid\browsers.json

- Создаем папку с квотами балансировщика:
`mkdir -p /etc/grid-router/quota`
- Устанавливаем htpasswd командой: `sudo apt install apache2-utils`
- Создаем пользователя через htpasswd для base auth:
`htpasswd -bc /etc/grid-router/users.htpasswd test test-password`

- Создаем конфигурационный файл балансировщика:
`cat /etc/grid-router/quota/test.xml`
\devops-repo\selenoidCluster\grid-router\quota\test.xml

- Запускаем Docker контейнер с балансировщиком:
`docker run -d --name ggr -v /etc/grid-router/:/etc/grid-router:ro --net host aerokube/ggr:latest-release -guests-allowed -guests-quota "test" -verbose -quotaDir /etc/grid-router/quota`

GGR UI - небольшой плагин для балансировщика, который собирает общие квоты для selenoid ui с балансировщика нагрузки ggr
`docker run -d --name ggr-ui -p 8888:8888 -v /etc/grid-router/:/etc/grid-router/quota:ro aerokube/ggr-ui:latest-release`
- Проверка, что ggr-ui работает:
`curl -s http://localhost:8888/status`

`docker run -d --name selenoid-ui --net host aerokube/selenoid-ui --selenoid-uri http://127.0.0.1:8888`

`docker run -d --name nginx -v $HOME/nginx/:/etc/nginx/conf.d/-v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /etc/localtime:/etc/localtime:ro --restart always --privileged --net host nginx:latest`

