#
# !! THIS FILE IS FOR DEVELOPMENT USAGE ONLY !!
#
# Usage: make [...]
#

SHELL := /bin/bash
CWD := $(shell pwd)
-include .env
export

DOCKER_IMAGE_APACHE ?= 7.4.27-apache
APACHE_PORT_80 ?= 8080

default: help
.PHONY: default

## Build the docker image for apache/demo (use the `PHP_VERS` variable to select the PHP version)
docker-build:
	docker build \
		-f $$(pwd)/Dockerfile \
		-t mde_demo:${DOCKER_IMAGE_APACHE} \
		--build-arg IMAGE_VERSION=${DOCKER_IMAGE_APACHE} \
		$$(pwd)/
.PHONY: docker-build

## Start the apache docker container for demo (use the `PHP_VERS` variable to select the PHP version)
docker-start: docker-build
	docker run -ti -d --rm \
		-v $$(pwd):/var/www/ \
		-p ${APACHE_PORT_80}:80 \
		-w /var/www/ \
		--name mde_demo_app_${DOCKER_IMAGE_APACHE} \
		mde_demo:${DOCKER_IMAGE_APACHE}
.PHONY: docker-start

## Stop the apache/demo docker container (use the `PHP_VERS` variable to select the PHP version)
docker-stop:
	docker stop mde_demo_app_${DOCKER_IMAGE_APACHE}
.PHONY: docker-stop

# largely inspired by <https://docs.cloudposse.com/reference/best-practices/make-best-practices/>
help:
	@printf "#############################################\n!! THIS FILE IS FOR DEVELOPMENT USAGE ONLY !!\n#############################################\n"
	@printf "\n"
	@printf "To use this file, run: make <target>\n"
	@printf "\n"
	@printf "Available targets:\n"
	@printf "\n"
	@awk '/^[a-zA-Z\-\_0-9%:\\]+/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = $$1; \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			gsub("\\\\", "", helpCommand); \
			gsub(":+$$", "", helpCommand); \
			printf "  \x1b[32;01m%-35s\x1b[0m %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST) | sort -u
	@printf "\n"
	@printf "To override a variable used in the Makefile, you can run: 'make <target> VAR_NAME=my-value'.\n"
	@printf "You can also declare it in a '.env' local file which is loaded at each run.\n"
	@printf "\n"
	@printf "Available variables and default values:\n"
	@printf "\n"
	@awk '/^[a-zA-Z\_0-9]+[ ]\?=/ { \
		var=val=$$0; \
		sub(/\?=.*/,"",var); \
		sub(/[^=]+=/,"",val); \
		printf "  \x1b[32;01m%-25s\x1b[0m %s\n", var, val; \
	}' $(MAKEFILE_LIST) | sort -u
	@printf "\n"
.PHONY: help
