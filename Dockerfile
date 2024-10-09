# https://mcr.microsoft.com/en-us/product/dotnet/runtime/tags
FROM mcr.microsoft.com/dotnet/runtime:8.0-cbl-mariner2.0 AS base
WORKDIR /app

# https://mcr.microsoft.com/en-us/product/dotnet/sdk/tags
FROM mcr.microsoft.com/dotnet/sdk:8.0.403 AS build
WORKDIR /src
COPY ["consumer/consumer.csproj", "consumer/"]
RUN dotnet restore "consumer/consumer.csproj"
COPY . .
WORKDIR "/src/consumer"
RUN dotnet build "consumer.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "consumer.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
COPY --from=build /src/kafka.properties .
ENTRYPOINT ["dotnet", "consumer.dll", "kafka.properties"]
