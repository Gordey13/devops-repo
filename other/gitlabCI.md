Создаем GitLab pipline
Залить на registry
Изменить 
Использовать SHA коммита для версионирования

```yaml
image: docker

services:
	- docker:dind

before_script:
	- export
	- docker login -u ${CI_REGISTRY_USER} -p ${CI_REGISTRY_PASSWORD} registry.gitlab.com

build:
	script:
		- docker pull registry.gitlab.com/sion2k/skillbox:latest 
		- docker build -t registry.gitlab.com/sion2k/skillbox:${CI_COMMIT_SHORT_SHA} .
		- docker push registry.gitlab.com/sion2k/skillbox:${CI_COMMIT_SHORT_SHA}
		- docker push registry.gitlab.com/sion2k/skillbox:latest
```