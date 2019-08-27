VERSION=1.0.0
IMAGE=amerlescucodez/docker-faye-ruby

.PHONY: all

all:

build:
	docker build -t $(IMAGE):$(VERSION) .

run:
	docker-compose up

boot:
	docker-compose up -d

logs:
	docker-compose logs -f

ps:
	docker-compose ps

publish: build
	docker push $(IMAGE):$(VERSION)
	docker build -t $(IMAGE):latest .
	docker push $(IMAGE):latest