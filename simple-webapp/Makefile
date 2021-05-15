APP_NAME=$(shell basename ${PWD})

# Include the config variables
include variables.txt

# DOCKER TASKS
# Build the container
build:
	docker build -t $(APP_NAME) .

build-nc:
	docker build --build-arg APP_PORT=${APP_PORT} --no-cache -t $(APP_NAME) .

run:
	docker run -i -t --env-file=variables.txt --rm -p=$(APP_PORT):$(APP_PORT) --name="$(APP_NAME)" $(APP_NAME)


up: build run

stop:
	docker stop $(APP_NAME); docker rm $(APP_NAME)

release: build-nc publish 

# Docker publish
publish: repo-login publish-latest publish-version

publish-latest: tag-latest
	@echo 'publish latest to $(DOCKER_REPO)'
	docker push $(DOCKER_REPO)/$(APP_NAME):latest

publish-version: tag-version 
	@echo 'publish $(VERSION) to $(DOCKER_REPO)'
	docker push $(DOCKER_REPO)/$(APP_NAME):$(VERSION)

# Docker tagging
tag: tag-latest tag-version

tag-latest: 
	@echo 'create tag latest'
	docker tag $(APP_NAME) $(DOCKER_REPO)/$(APP_NAME):latest

tag-version:
	@echo 'create tag $(VERSION)'
	docker tag $(APP_NAME) $(DOCKER_REPO)/$(APP_NAME):$(VERSION)

# Login to DockerHub
repo-login:
	docker login

# Build and publish
all: build publish
