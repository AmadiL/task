ifneq ("$(wildcard .env)","")
	include .env
endif

SHELL = /bin/bash
.ONESHELL:
.SHELLFLAGS = -ec
.EXPORT_ALL_VARIABLES:

ENV ?= dev

TF_VAR_project_id := $(PROJECT_ID)
TF_VAR_region     := $(REGION)

TF_STATE_BUCKET_NAME ?= $(PROJECT_ID)-$(REGION)-tfstate

TF_BASE_DIR  := base
TF_INFRA_DIR := infra
TF_APPS_DIR  := apps

TF            ?= terraform
TF_PLAN_OPTS  ?= -var-file=../$(ENV).tfvars
TF_APPLY_OPTS ?= $(TF_PLAN_OPTS)

TF_BASE               := terraform -chdir=$(TF_BASE_DIR)
TF_BASE_BACKEND_TMPLT := $(TF_BASE_DIR)/backend.tf.tmplt
TF_BASE_BACKEND_FILE  := $(TF_BASE_DIR)/backend.tf

TF_INFRA_BACKEND_FILE := $(TF_INFRA_DIR)/infra.gcs.tfbackend
TF_APPS_BACKEND_FILE  := $(TF_APPS_DIR)/apps.gcs.tfbackend

TF_INFRA := terraform -chdir=$(TF_INFRA_DIR)
TF_APPS  := terraform -chdir=$(TF_APPS_DIR)

## Show info

info:
	@echo "PROJECT_ID=$(PROJECT_ID)"
	@echo "REGION=$(REGION)"
	@echo "TF_STATE_BUCKET_NAME=$(TF_STATE_BUCKET_NAME)"

## Run terraform fmt

fmt:
	terraform fmt -recursive


## Bootstrap base state bucket

base-bootstrap: info
	export TF_VAR_bucket_name=$(TF_STATE_BUCKET_NAME)
	$(TF_BASE) init -input=false
	$(TF_BASE) apply -input=false -auto-approve
	sed "s/BUCKET_NAME/$(TF_STATE_BUCKET_NAME)/" $(TF_BASE_BACKEND_TMPLT) > $(TF_BASE_BACKEND_FILE)
	sed -i.tmplt "s/BUCKET_NAME/$(TF_STATE_BUCKET_NAME)/" $(TF_INFRA_BACKEND_FILE)
	sed -i.tmplt "s/BUCKET_NAME/$(TF_STATE_BUCKET_NAME)/" $(TF_APPS_BACKEND_FILE)
	$(TF_BASE) init -migrate-state -force-copy

## Teardown base state bucket

base-teardown: info
	export TF_VAR_bucket_name=$(TF_STATE_BUCKET_NAME)
	rm $(TF_BASE_BACKEND_FILE)
	$(TF_BASE) init -migrate-state -force-copy
	$(TF_BASE) apply -input=false -auto-approve -var="tfstate_force_destroy=true"
	$(TF_BASE) destroy -input=false -auto-approve

## terraform init [infra|apps]

_init:
	$(TF) init -upgrade -backend-config=$(TYPE).gcs.tfbackend

infra-init: TF = $(TF_INFRA)
infra-init: TYPE = infra
infra-init: _init

apps-init: TF = $(TF_APPS)
apps-init: TYPE = apps
apps-init: _init

## terraform workspace [select|new] [infra|apps]

_workspace-select:
	$(TF) workspace select $(ENV) || $(TF) workspace new $(ENV)

## terraform plan [infra|apps]

_plan:
	$(TF) plan $(TF_PLAN_OPTS)

infra-plan: TF = $(TF_INFRA)
infra-plan: _workspace-select _plan

apps-plan: TF = $(TF_APPS)
apps-plan: _workspace-select _plan

## terraform apply [infra|apps]

_apply:
	$(TF) apply $(TF_APPLY_OPTS)

infra-apply: TF = $(TF_INFRA)
infra-apply: _workspace-select _apply

apps-apply: TF = $(TF_APPS)
apps-apply: _workspace-select _apply
