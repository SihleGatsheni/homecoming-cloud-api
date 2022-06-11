FROM mcr.microsoft.com/dotnet/aspnet:5.0-focal AS base
WORKDIR /app

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
# For more info, please refer to https://aka.ms/vscode-docker-dotnet-configure-containers
RUN adduser -u 5678 --disabled-password --gecos "" appuser && chown -R appuser /app
USER appuser

FROM mcr.microsoft.com/dotnet/sdk:5.0-focal AS build
WORKDIR /src
COPY ["homecoming.api.csproj", "./"]
RUN dotnet restore "homecoming.api.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "homecoming.api.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "homecoming.api.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
CMD ASPNETCORE_URLS=http://*:$PORT dotnet homecoming.api.dll
