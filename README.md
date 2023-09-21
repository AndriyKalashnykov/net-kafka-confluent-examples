# net-kafka-confluent-examples

## Producer

```bash
cd producer
dotnet build producer.csproj
cd producer
dotnet run $(pwd)/../kafka.properties
```

## Consumer

```bash
cd consumer
dotnet build consumer.csproj
dotnet run $(pwd)/../kafka.properties
```