# Tor Hidden Service Docker

This is a simple Docker wrapper for Tor hidden services. Learn more about the [tor project](https://www.torproject.org/)

## Prerequisites
- Obviously docker
- [Optionally] Docker compose

## Usage
As tor is currently not supporting a `torrc.d` directory, the entire configuration has to be mounted at once. You can find a sample torrc file in this project.

Mount your torrc file into the container with:

Docker

`docker run --name tor-hidden-service --network host -v <your-torrc>:/torrc tor-hidden-service:latest`

Docker compose

`docker compose -f docker-compose.yaml up -d`


## Networking

`network_mode: host` is required to proxy your local services through the tor network. It is not required if you want to proxy services
- inside the same docker network (adjust the network with `--network <network-name>`)
- Inside the same kubernetes cluster, as the kubedns will take care of the resolving and routing of the traffic
