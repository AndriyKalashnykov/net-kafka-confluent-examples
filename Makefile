.DEFAULT_GOAL := help

CONSUMER_IMG ?= confluent-kafka-consumer-net:latest
CURRENTTAG:=$(shell git describe --tags --abbrev=0)
NEWTAG ?= $(shell bash -c 'read -p "Please provide a new tag (currnet tag - ${CURRENTTAG}): " newtag; echo $$newtag')
GOFLAGS=-mod=mod
GOPRIVATE=github.com/AndriyKalashnykov/go-kafka-confluent-examples

#help: @ List available tasks
help:
	@clear
	@echo "Usage: make COMMAND"
	@echo "Commands :"
	@grep -E '[a-zA-Z\.\-]+:.*?@ .*$$' $(MAKEFILE_LIST)| tr -d '#' | awk 'BEGIN {FS = ":.*?@ "}; {printf "\033[32m%-20s\033[0m - %s\n", $$1, $$2}'

#clean: @ Cleanup
clean:
	@sudo rm -rf .bin/

#build: @ Build
build: clean
	cd producer && dotnet build producer.csproj && cd ..
	cd consumer && dotnet build consumer.csproj && cd ..

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

#consumer-image-build: @ Build Consumer Docker image
consumer-image-build: build
	@docker build -f consumer/Dockerfile -t ${CONSUMER_IMG} .

#consumer-image-run: @ Run a Docker image
consumer-image-run: consumer-image-stop consumer-image-build
	@docker-compose -f "consumer/docker-compose.yml" up

#consumer-image-stop: @ Run a Docker image
consumer-image-stop:
	@docker-compose -f "consumer/docker-compose.yml" down

#runp: @ Run producer
runp: build
	dotnet run --project producer/producer.csproj $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))/kafka.properties

#runc: @ Run consumer
runc: build
	dotnet run --project consumer/consumer.csproj $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))/kafka.properties

#k8s-deploy: @ Deploy to a local KinD cluster
k8s-deploy:
	@cat ./k8s/ns.yaml | kubectl apply -f - && \
	cat ./k8s/deployment.yaml | kubectl apply --namespace=kafka-confluent-examples -f - && \
	cat ./k8s/service.yaml | kubectl apply --namespace=kafka-confluent-examples -f -

#k8s-undeploy: @ Undeploy from a local KinD cluster
k8s-undeploy:
	@kubectl delete -f ./k8s/deployment.yaml --namespace=kafka-confluent-examples --ignore-not-found=true && \
	kubectl delete -f ./k8s/service.yaml --namespace=kafka-confluent-examples --ignore-not-found=true && \
	kubectl delete -f ./k8s/ns.yaml --ignore-not-found=true

# ssh into pod
# kubectl exec --stdin --tty -n kafka-confluent-examples kafka-confluent-go-56686b9958-ft2bh -- /bin/sh

# pod logs
# kubectl logs -n kafka-confluent-examples kafka-confluent-go-56686b9958-ft2bh --follow --timestamps
