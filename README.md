# Tor Hidden Service Docker

This is a simple Docker wrapper for Tor hidden services. Learn more about the [tor project](https://www.torproject.org/)

For details about the `torrc` file, visit the [documentation](https://github.com/torproject/tor/blob/main/src/config/torrc.sample.in)

## Prerequisites
- Docker (Obviously)
- [Optionally] Docker compose

## Usage
As tor is currently not supporting a `torrc.d` directory, the entire configuration has to be mounted at once. You can find a sample torrc file in this project.

Mount your torrc file into the container with:

Docker

`docker run --name tor --network host --mount type=bind,source="$(pwd)"/torrc.sample,target=/torrc,readonly tor-hidden-service:latest`

Docker compose

TBD!


### Get created Tor files

Run `docker cp tor:/var/lib/tor/<name-of-service> <local-dir>` to copy the created fils


### Mounting Tor directories

To successfully mount the /var/lib/tor/xxx directories, the permissions have to match.

Before mounting, set the permissions of the folder to:
- userid: `100`
- group: `nogroup`
- permissions: `700`

> `sudo chown 100:nogroup -R <directory> && sudo chmod 700 -R <directory>`

## Networking

`network_mode: host` is required to proxy your local services through the tor network. It is not required if you want to proxy services
- inside the same docker network (adjust the network with `--network <network-name>`)
- Inside the same kubernetes cluster, as the kubedns will take care of the resolving and routing of the traffic


## Maintainer
- @mgreif - mika@greif.me
