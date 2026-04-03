# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

.NET Kafka producer/consumer examples using the Confluent.Kafka client library, connecting to Confluent Cloud. The solution contains two independent console applications (`producer/` and `consumer/`) that share a common `kafka.properties` configuration file.

## Tech Stack

- **Language**: C# on .NET 10.0 (SDK 10.0.201, pinned in `global.json`)
- **Kafka client**: `Confluent.Kafka` with SASL_SSL to Confluent Cloud
- **Configuration**: `Microsoft.Extensions.Configuration` reading INI-format `kafka.properties`
- **Container**: Multi-stage Docker build (Azure Linux 3.0 runtime base)
- **Warnings as errors**: `TreatWarningsAsErrors` enabled in both `.csproj` files

## Build & Run Commands

```bash
make build           # Build both producer and consumer
make producer-run    # Build and run producer (sends 10 messages to test-topic)
make consumer-run    # Build and run consumer (subscribes to test-topic, Ctrl-C to stop)
make image-build     # Build consumer Docker image
make image-run       # Docker Compose up (builds image first)
make image-stop      # Docker Compose down
make lint            # Lint Dockerfile with hadolint
make ci              # Full local CI pipeline (deps, lint, build, image-build)
make ci-run          # Run GitHub Actions workflow locally via act
make update          # Upgrade outdated NuGet packages in both projects
make clean           # Remove build output
```

Building individual projects directly:
```bash
cd producer && dotnet build producer.csproj
cd consumer && dotnet build consumer.csproj
```

## Configuration

- `kafka.properties` — Kafka broker connection settings (bootstrap servers, security protocol, `acks=all`). Does **not** contain credentials.
- `.env` — SASL credentials and runtime settings (SASL_USERNAME, SASL_PASSWORD, KAFKA_CONFIG_FILE, KAFKA_TOPIC). This is the single source of truth for credentials. Copy from `.env-sample` when setting up.
- `global.json` — Pins .NET SDK version with `latestFeature` roll-forward

Both applications take the path to `kafka.properties` as their single CLI argument. SASL credentials are read from `SASL_USERNAME` and `SASL_PASSWORD` environment variables (exported by the Makefile from `.env`, or passed via Docker Compose).

## CI

GitHub Actions workflow (`.github/workflows/ci.yml`) with two jobs:
- **static-check**: Lints Dockerfile with hadolint (`make lint`)
- **build**: .NET build + Docker image build (`make build`, `make image-build`), depends on static-check

Triggers on push to `main`, PRs, version tags (`v*`), and `workflow_call`.

Uses .NET SDK version from `global.json` automatically. No test step (there are no tests in this project).

## Architecture Notes

- The producer sends 10 randomized key-value messages (user/item pairs) and flushes
- The consumer runs in an infinite loop with `CancellationToken` for graceful Ctrl-C shutdown
- Docker Compose mounts `kafka.properties` into the container and passes credentials via environment variables
- The Dockerfile only containerizes the consumer; the producer runs locally via `make producer-run`
- `netskope/` contains CA certificates for corporate proxy environments (commented out in Dockerfile, enable if behind Netskope)

## Upgrade Backlog

Last reviewed: 2026-04-03

No outstanding items.

## Skills

Use the following skills when working on related files:

| File(s) | Skill |
|---------|-------|
| `Makefile` | `/makefile` |
| `renovate.json` | `/renovate` |
| `README.md` | `/readme` |
| `.github/workflows/*.yml` | `/ci-workflow` |

When spawning subagents, always pass conventions from the respective skill into the agent's prompt.
