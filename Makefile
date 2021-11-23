# Set default shell to bash
SHELL := /bin/bash -o pipefail

ifndef NOCOLOR
	RED    := $(shell tput -Txterm setaf 1)
	GREEN  := $(shell tput -Txterm setaf 2)
	YELLOW := $(shell tput -Txterm setaf 3)
	BLUE   := $(shell tput -Txterm setaf 4)
	CYAN   := $(shell tput -Txterm setaf 6)
	WHITE  := $(shell tput -Txterm setaf 7)
	RESET  := $(shell tput -Txterm sgr0)
endif

DOCKER_BUILD_CMD = docker build
COMMAND_DCUP = docker-compose up

.PHONY: default
default: help

## Not exposed as a callable target by `make help`, since this is a one-time shot to simplify the development of this module.
.PHONY: template/adjust
template/adjust: FILTER = -path ./.git -prune -a -type f -o -type f -not -name Makefile
template/adjust:
	@find . $(FILTER) -exec sed -i -e "s,terraform-module-template,$${PWD##*/},g" {} \;

## Execução de todos os serviços do docker-compose via -d
.PHONY: devops/up
devops/up: COMMAND_DCUP += -d
devops/up:
	$(call docker-compose-up, ${COMMAND_DCUP} )

## Help para todos os Targets
.PHONY: help
help:
	@awk '/^.PHONY: / { \
		msg = match(lastLine, /^## /); \
			if (msg) { \
				cmd = substr($$0, 9, 100); \
				msg = substr(lastLine, 4, 1000); \
				printf "  ${GREEN}%-30s${RESET} %s\n", cmd, msg; \
			} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

# define helper functions
quiet-command = $(if ${V},${1},$(if ${2},@echo ${2} && ${1}, @${1}))
general-command = $(call quiet-command,${1} | cat,"${YELLOW}[COMMAND] ${GREEN}${1}${RESET}")
docker-build = $(call quiet-command,${DOCKER_BUILD_CMD} ${1} | cat,"${YELLOW}[BUILDING IMAGES] ${GREEN}${1}${RESET}")
docker-compose-up = $(call quiet-command,${COMMAND_DCUP} ${1} | cat,"${YELLOW}[COMPOSE UP SERVICES] ${GREEN}${1}${RESET}")