# https://mcr.microsoft.com/en-us/product/dotnet/runtime/tags
FROM mcr.microsoft.com/dotnet/runtime:10.0-azurelinux3.0 AS base
WORKDIR /app

# https://mcr.microsoft.com/en-us/product/dotnet/sdk/tags
FROM mcr.microsoft.com/dotnet/sdk:10.0.201 AS build

# workaround for environments where Netskope prevents nuget to use https
#WORKDIR /netskope
#COPY . .
#RUN cp ./netskope/*.pem /usr/local/share/ca-certificates/
#RUN update-ca-certificates

WORKDIR /src
COPY ./consumer ./consumer
COPY kafka.properties .
RUN dotnet restore "consumer/consumer.csproj"

WORKDIR /src/consumer
RUN dotnet build "consumer.csproj" --no-restore -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "consumer.csproj" --no-restore -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final

WORKDIR /app
COPY --from=publish /app/publish .
COPY --from=build /src/kafka.properties .

USER app

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD dotnet --info || exit 1

ENTRYPOINT ["dotnet", "consumer.dll", "kafka.properties"]
