[![CI](https://github.com/AndriyKalashnykov/net-kafka-confluent-examples/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/AndriyKalashnykov/net-kafka-confluent-examples/actions/workflows/ci.yml)
[![Hits](https://hits.sh/github.com/AndriyKalashnykov/net-kafka-confluent-examples.svg?view=today-total&style=plastic)](https://hits.sh/github.com/AndriyKalashnykov/net-kafka-confluent-examples/)
[![License: MIT](https://img.shields.io/badge/License-MIT-brightgreen.svg)](https://opensource.org/licenses/MIT)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://app.renovatebot.com/dashboard#github/AndriyKalashnykov/net-kafka-confluent-examples)

# net-kafka-confluent-examples

C#/.NET 10 Kafka producer and consumer examples using [Confluent.Kafka](https://github.com/confluentinc/confluent-kafka-dotnet) client library, connecting to Confluent Cloud via SASL_SSL. Includes Docker containerization and Kubernetes deployment to a local KinD cluster.

## Quick Start

```bash
cp .env-sample .env     # configure SASL credentials
make build              # build producer and consumer
make producer-run       # send 10 messages to test-topic
make consumer-run       # subscribe to test-topic (Ctrl-C to stop)
```

## Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| [.NET SDK](https://dotnet.microsoft.com/download) | 10.0+ | Build and run C# applications |
| [Docker](https://www.docker.com/) | latest | Container image builds |
| [kubectl](https://kubernetes.io/docs/tasks/tools/) | latest | Kubernetes deployments (optional) |
| [KinD](https://kind.sigs.k8s.io/) | latest | Local Kubernetes cluster (optional) |

## Available Make Targets

Run `make help` to see all available targets.

### Build & Run

| Target | Description |
|--------|-------------|
| `make build` | Build producer and consumer |
| `make producer-run` | Run producer |
| `make consumer-run` | Run consumer |
| `make clean` | Cleanup build artifacts |

### Docker

| Target | Description |
|--------|-------------|
| `make image-build` | Build Consumer Docker image |
| `make image-run` | Run Consumer Docker image |
| `make image-stop` | Stop Consumer Docker image |

### CI

| Target | Description |
|--------|-------------|
| `make lint` | Lint Dockerfile with hadolint |
| `make ci` | Run full local CI pipeline |
| `make ci-run` | Run GitHub Actions workflow locally using [act](https://github.com/nektos/act) |

### Utilities

| Target | Description |
|--------|-------------|
| `make update` | Upgrade outdated packages |
| `make release` | Create and push a new tag |
| `make version` | Print current version(tag) |
| `make renovate-validate` | Validate Renovate configuration |

## CI/CD

GitHub Actions runs on every push to `main`, tags `v*`, and pull requests.

| Job | Triggers | Steps |
|-----|----------|-------|
| **static-check** | push, PR, tags | Lint (hadolint) |
| **build** | after static-check | .NET build, Docker image build |

[Renovate](https://docs.renovatebot.com/) keeps dependencies up to date with platform automerge enabled.

## References

- [Getting Started with Apache Kafka and .NET](https://developer.confluent.io/get-started/dotnet/#introduction)
- [Confluent's .NET Client for Apache Kafka](https://github.com/confluentinc/confluent-kafka-dotnet)
- [Kafka .NET Client](https://docs.confluent.io/kafka-clients/dotnet/current/overview.html)
