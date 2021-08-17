APP_NAME=vim-devops

# Include the config variables
include variables.txt

# DOCKER TASKS
# Build the container
build:
	docker build -t $(APP_NAME) -f vim.Dockerfile .

build-nc:
	docker build --no-cache -t $(APP_NAME) -f vim.Dockerfile .

run:
	docker run -i -t --env-file=variables.txt -e COLUMNS=`tput cols` -e LINES=`tput lines` -v ${HOME_DIR}:/mnt/ --rm --name="$(APP_NAME)" $(APP_NAME)

up: build run

stop:
	docker stop $(APP_NAME); docker rm $(APP_NAME)

release: build publish

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
