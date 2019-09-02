FAYE_VERSION=1.0.2
FAYE_IMAGE=amerlescucodez/docker-faye-ruby
NGINX_VERSION=1.0.0
NGINX_IMAGE=amerlescucodez/docker-faye-nginx

.PHONY: all

all:

build:
	docker build -f faye.Dockerfile -t $(FAYE_IMAGE):$(FAYE_VERSION) .
	docker build -f nginx.Dockerfile -t $(NGINX_IMAGE):$(NGINX_VERSION) .

run:
	docker-compose up --force-recreate --build

boot:
	docker-compose up -d --force-recreate --build

logs:
	docker-compose logs -f

ps:
	docker-compose ps

publish: build
	docker push $(FAYE_IMAGE):$(FAYE_VERSION)
	docker push $(NGINX_IMAGE):$(NGINX_VERSION)
	docker build -f faye.Dockerfile -t $(FAYE_IMAGE):latest .
	docker build -f nginx.Dockerfile -t $(NGINX_IMAGE):latest .
	docker push $(FAYE_IMAGE):latest
	docker push $(NGINX_IMAGE):latest
