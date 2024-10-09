# net-kafka-confluent-examples

## Requirements

- Linux
- [.Net](https://learn.microsoft.com/en-us/dotnet/core/install/) .Net 8.0.x
Download  [.Net 8.0.x](https://dotnet.microsoft.com/en-us/download/dotnet/8.0)
```bash
DOTNET_FILE=~/Downloads/dotnet-sdk-8.0.403-linux-x64.tar.gz
export DOTNET_ROOT=/home/andriy/.dotnet
mkdir -p "$DOTNET_ROOT" && tar zxf "$DOTNET_FILE" -C "$DOTNET_ROOT"
export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools
```

or install .Net 8.0 and update [global.json](./global.json) to `"version": "8.0.0"`

  ```bash
  sudo apt-get update && sudo apt-get install -y dotnet-sdk-8.0
  sudo apt-get install -y dotnet-runtime-8.0
  sudo apt-get update && sudo apt-get install -y aspnetcore-runtime-8.0
  ```
- [Confluent's .NET Client for Apache Kafka](https://github.com/confluentinc/confluent-kafka-dotnet)
  ```bash
  dotnet add package -v 2.5.0 Confluent.Kafka
  ```
- [docker](https://docs.docker.com/engine/install/)
- [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl)

## Help

```bash
$ make
Usage: make COMMAND
Commands :
help                 - List available tasks
clean                - Cleanup
build                - Build
release              - Create and push a new tag
version              - Print current version(tag)
consumer-image-build - Build Consumer Docker image
consumer-image-run   - Run a Docker image
consumer-image-stop  - Run a Docker image
runp                 - Run producer
runc                 - Run consumer
k8s-deploy           - Deploy to a local KinD cluster
k8s-undeploy         - Undeploy from a local KinD cluster
upgrade              - Upgrade outdated packages
```

## Install [Docker Scout](https://www.docker.com/products/docker-scout/)

```bash
curl -sSfL https://raw.githubusercontent.com/docker/scout-cli/main/install.sh | sh -s --
```

## Advanced image analysis with [Docker Scout CLI](https://github.com/docker/scout-cli)

```bash
docker scout quickview
```

## References

- [Getting Started with Apache Kafka and .NET](https://developer.confluent.io/get-started/dotnet/#introduction)
- [Confluent's .NET Client for Apache Kafka](https://github.com/confluentinc/confluent-kafka-dotnet)
- [Kafka .NET Client](https://docs.confluent.io/kafka-clients/dotnet/current/overview.html)
