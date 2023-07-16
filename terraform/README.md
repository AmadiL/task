# GCP Terraform

## Required ENV variables

```bash
# .env
PROJECT_ID=GCP-project-id
REGION=GCP-region
```

## Contents
Terraform projects:
1. `terraform/base` - manages GCS bucket for GCS backend of all terraform projects
2. `terraform/infra` - manages infrastructure - network, service accounts, GKE clusters, registries, etc.
3. `terraform/apps` - manages apps deployments

> NOTE: Application deployment requires docker image in GCR - deploy `terraform/infra` and push app docker image before applying `terraform/apps`

## Manual bootstrap
Create bucket for terraform gcp backend using tf configuration from `base` dir
```
$ make base-bootstrap
```
The make target will:
1. Generate state bucket name from project_id and region: `$(PROJECT_ID)-$(REGION)-tfstate`
2. Terraform init with local backend
3. Create the state bucket
4. Add the state bucket name to backend configuration of `base`, `infra` and `apps` terraform projects
5. Migrate local state of `base` project to GCS backend

To remove the bucket and `base` project run:
```
$ make base-teardown
```

## Environments and Workspaces
> NOTE: only for `infra` and `apps`

Environments (default: `dev`, `prod`) are impemented using terraform workspaces with corresponding names.

To create an environment:
1. Add `terraform/$(ENV).tfvars` configuration file
2. Create a terraform workspace for each project
```bash
$ terraform -chdir=[infra|apps] workspace new $(ENV)
```

Workspaces are handled automatically by make:
```
$ make --dry-run infra-init
terraform -chdir=infra init -upgrade -backend-config=infra.gcs.tfbackend

$ make --dry-run infra-plan
terraform -chdir=infra workspace select dev || terraform -chdir=infra workspace new dev
terraform -chdir=infra plan -var-file=../dev.tfvars

$ make --dry-run infra-plan ENV=prod
terraform -chdir=infra workspace select prod || terraform -chdir=infra workspace new prod
terraform -chdir=infra plan -var-file=../prod.tfvars
```

## Terraform apply with Make
Following targets are supported:
```bash
$ make [infra|apps]-[init|plan|apply]
# Example
$ make infra-init infra-plan infra-apply # Init, plan and apply infrastructure
$ make apps-init apps-apply # Init and apply apps deployments
```

## First deployment steps [manual]
```bash
$ gcloud auth login
$ cd terraform
$ export PROJECT_ID=...
$ export REGION=...
$ make base-bootstrap
$ make infra-init
$ make apps-init
$ make infra-apply
$ cd ..
$ make docker-build
$ cd terraform
$ make apps-apply
```
