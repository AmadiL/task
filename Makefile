ifneq ("$(wildcard .env)","")
	include .env
endif

SHELL = /bin/bash
.ONESHELL:
.SHELLFLAGS = -ec
.EXPORT_ALL_VARIABLES:

PROJECT_ID ?=
REGION     ?=
ZONE       ?=

ENV_NAME   ?= dev
APP        ?= kmeans

DOCKER_REGISTRY   ?= $(REGION)-docker.pkg.dev
DOCKER_REPOSITORY ?= $(DOCKER_REGISTRY)/$(PROJECT_ID)/$(APP)-$(ENV_NAME)
DOCKER_TAG        ?= latest
DOCKER_IMG_API    ?= $(DOCKER_REPOSITORY)/api:$(DOCKER_TAG)

auth:
	gcloud auth login

venv:
	python -m venv .venv
	source .venv/bin/activate

load-test:
	source .venv/bin/activate
	pip install -r requirements-test.txt
	locust -f ./example/load_test.py

docker-login:
	gcloud auth print-access-token | docker login -u oauth2accesstoken --password-stdin https://$(DOCKER_REGISTRY)

docker-build: docker-login
	docker build --push -t $(DOCKER_IMG_API) .
