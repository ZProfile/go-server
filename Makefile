REALM_NAME := zprofile

###############
# TARGETS
###############

.PHONY: help
help:  ## help target to show available commands with information
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) |  awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: all services run
all: services run

run: ## Run the rest api app
	go run main.go

services: ## Run keycloak locally
	devenv up -d

stop: ## Stop keycloak
	process-compose down

.PHONY: keycloak-attach
keycloak-attach:
	process-compose attach

.PHONY: decrypt
decrypt: ## Decrypt the exported realm file
	sops -d ./keycloak/realms/zprofile.enc.json > ./keycloak/realms/zprofile.json 
