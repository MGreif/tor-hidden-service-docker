# Tor Hidden Service Docker

This is a simple Docker wrapper for Tor hidden services. Learn more about the [tor project](https://www.torproject.org/)

For details about the `torrc` file, visit the [documentation](https://github.com/torproject/tor/blob/main/src/config/torrc.sample.in)



## Deployed Version

Docker image -> https://hub.docker.com/r/mgreif/tor-hidden-service-docker

`docker pull mgreif/tor-hidden-service-docker:0.1.1`

Deployed hidden service -> http://g7sfnt5r36qf3i5hfneplkicbxnmzwlz2koulobyhpee7dw7pr4r5oqd.onion (Proxying to [anonchat](https://anonchat.greif.me) service)

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




### Simplified usage with Make

#### VARIABLES

|Key|Description|Example|default|
|-----|-----|------|-----|
|IMAGE_NAME|Specifies the name of the image|tor-hidden-service|tor-hidden-service|
|IMAGE_TAG|Specifies the tag of the image|local|local|
|CONTAINER_NAME|Specifies the name of the container|tor-service-container|\<image-name\>|
|SERVICE_NAME|Specifies the name of the hidden-tor-service|my-custom-hidden-service|hidden-service|
|TORRC_PATH|Specifies the **absolute** path to the `torrc` file|/home/me/torrc|$(pwd)/torrc.sample|
|OUT_DIR|Specifies the output directory for the `make get-files` command|./hidden-service|output-files|
|HIDDEN_SERVICE_DIR|Specifies the location to the to-be-mounted hidden-service-dir|./my-hidden-service|



- `make pull`
    - pulls the latest docker image from the mgreif repo, based on this repo's version (meta.json)
- `make build`
    - build local docker image based on this repo
- `make start-docker`
    - starts the docker container with a **LOCAL** image (build before).
    - Mounts torrc file
- `make pull-and-start`
    - pulls and starts the docker container from the mgreif repo.
    - Mounts torrc file
- `make start-and-mount`
    - pulls, mounts and starts the docker container.
    - Mounts torrc file
    - Mounts a specified hidden service directory (Can be used to make a hidden service persistent)
    - Hidden service directory is specified by the `HIDDEN_SERVICE_DIR` ENV var
- `make get-files`
    - Copies the hidden-service files to a specified location
    - Location specified via the `OUT_DIR` ENV var
- `make get-hostname`
    - Prints the hostname of the hidden-service to the console
    - Uses the `SERVICE_NAME` ENV var



## Usage TLDR;

Run `HIDDEN_SERVICE_DIR=$(pwd)/my-hidden-service make start-and-mount`

This automatically starts a hidden service and mounts its files into the specified directory ($(pwd)/my-hidden-service)

If you want to use the created files, change the permissions back to your user, as the scripts will change the permissions to be handable by tor.


## Networking

`network_mode: host` is required to proxy your local services through the tor network. It is not required if you want to proxy services
- inside the same docker network (adjust the network with `--network <network-name>`)
- Inside the same kubernetes cluster, as the kubedns will take care of the resolving and routing of the traffic



## Todo

- Improve permission and ownership handling
- Improve torrc service handling to be capable of handling multiple hidden services
## Maintainer
- @mgreif - mika@greif.me
