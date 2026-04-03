.DEFAULT_GOAL := help

CONSUMER_IMG ?= kafka-confluent-net-consumer:latest
CURRENTTAG   := $(shell git describe --tags --abbrev=0 2>/dev/null || echo "dev")
NEWTAG       ?= $(shell bash -c 'read -p "Please provide a new tag (current tag - $${CURRENTTAG}): " newtag; echo $$newtag')

# === Tool Versions (pinned) ===
ACT_VERSION      := 0.2.87
HADOLINT_VERSION := 2.14.0
NVM_VERSION      := 0.40.4

ifneq (,$(wildcard .env))
$(eval include .env)
$(eval export $(shell sed -ne 's/ *\#.*$$//; /./ s/=.*$$// p' .env))
endif

#help: @ List available tasks
help:
	@echo "Usage: make COMMAND"
	@echo "Commands :"
	@grep -E '[a-zA-Z\.\-]+:.*?@ .*$$' $(firstword $(MAKEFILE_LIST))| tr -d '#' | awk 'BEGIN {FS = ":.*?@ "}; {printf "\033[32m%-20s\033[0m - %s\n", $$1, $$2}'

#deps: @ Check required dependencies
deps:
	@command -v dotnet >/dev/null 2>&1 || { echo "Error: .NET SDK required. Install from https://dotnet.microsoft.com/download"; exit 1; }

#deps-act: @ Install act for local CI
deps-act: deps
	@command -v act >/dev/null 2>&1 || { echo "Installing act $(ACT_VERSION)..."; \
		curl -sSfL https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash -s -- -b /usr/local/bin v$(ACT_VERSION); \
	}

#deps-hadolint: @ Install hadolint for Dockerfile linting
deps-hadolint:
	@command -v hadolint >/dev/null 2>&1 || { echo "Installing hadolint $(HADOLINT_VERSION)..."; \
		curl -sSfL -o /tmp/hadolint https://github.com/hadolint/hadolint/releases/download/v$(HADOLINT_VERSION)/hadolint-Linux-x86_64 && \
		install -m 755 /tmp/hadolint /usr/local/bin/hadolint && \
		rm -f /tmp/hadolint; \
	}

#renovate-bootstrap: @ Install nvm and npm for Renovate
renovate-bootstrap:
	@command -v node >/dev/null 2>&1 || { \
		echo "Installing nvm $(NVM_VERSION)..."; \
		curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v$(NVM_VERSION)/install.sh | bash; \
		export NVM_DIR="$$HOME/.nvm"; \
		[ -s "$$NVM_DIR/nvm.sh" ] && . "$$NVM_DIR/nvm.sh"; \
		nvm install --lts; \
	}

#renovate-validate: @ Validate Renovate configuration
renovate-validate: renovate-bootstrap
	@npx --yes renovate --platform=local

#clean: @ Cleanup
clean:
	@rm -rf ./consumer/bin/ ./producer/bin/

#build: @ Build producer and consumer
build: deps
	@cd producer && dotnet build producer.csproj && cd ..
	@cd consumer && dotnet build consumer.csproj && cd ..

#lint: @ Lint Dockerfile with hadolint
lint: deps-hadolint
	@hadolint Dockerfile

#producer-run: @ Run producer
producer-run: build
	@dotnet run --project producer/producer.csproj $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))/kafka.properties

#consumer-run: @ Run consumer
consumer-run: build
	@dotnet run --project consumer/consumer.csproj $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))/kafka.properties

#image-build: @ Build Consumer Docker image
image-build: build
	@docker buildx build --load --network=host -t $(CONSUMER_IMG) -f Dockerfile .

#image-run: @ Run Consumer Docker image
image-run: image-stop image-build
	@docker compose -f "docker-compose.yml" up

#image-stop: @ Stop Consumer Docker image
image-stop:
	@docker compose -f "docker-compose.yml" down

#ci: @ Run full local CI pipeline
ci: deps lint build image-build
	@echo "Local CI pipeline passed."

#ci-run: @ Run GitHub Actions workflow locally using act
ci-run: deps-act
	@act push --container-architecture linux/amd64 \
		--artifact-server-path /tmp/act-artifacts

#update: @ Upgrade outdated packages
update:
	@cd consumer && dotnet list package --outdated | grep -o '> \S*' | grep '[^> ]*' -o | xargs --no-run-if-empty -L 1 dotnet add package
	@cd producer && dotnet list package --outdated | grep -o '> \S*' | grep '[^> ]*' -o | xargs --no-run-if-empty -L 1 dotnet add package

#release: @ Create and push a new tag
release:
	$(eval NT=$(NEWTAG))
	@echo -n "Are you sure to create and push ${NT} tag? [y/N] " && read ans && [ $${ans:-N} = y ]
	@echo ${NT} > ./version.txt
	@git add -A
	@git commit -a -s -m "Cut ${NT} release"
	@git tag ${NT}
	@git push origin ${NT}
	@git push
	@echo "Done."

#version: @ Print current version(tag)
version:
	@echo $(shell git describe --tags --abbrev=0)

.PHONY: help deps deps-act deps-hadolint renovate-bootstrap renovate-validate \
	clean build lint producer-run consumer-run \
	image-build image-run image-stop \
	ci ci-run update release version
