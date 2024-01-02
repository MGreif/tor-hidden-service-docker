IMAGE_NAME ?= tor-hidden-service
IMAGE_TAG ?= local
IMAGE = $(IMAGE_NAME):$(IMAGE_TAG)
CONTAINER_NAME ?= $(IMAGE_NAME)
RELEASED_IMAGE_VERSION = $(shell cat `pwd`/meta.json | jq -r '.version')
RELEASED_IMAGE = mgreif/tor-hidden-service-docker:$(RELEASED_IMAGE_VERSION)




SERVICE_NAME ?= hidden-service
TORRC_PATH ?= $(pwd)/torrc.sample

docker_bin = /usr/bin/docker
pwd = $(shell echo `pwd`)

# Variables from user:
# service_name - name of the tor hidden service directory

.PHONY: pull
pull:
	$(docker_bin) pull $(RELEASED_IMAGE)

.PHONY: build
build:
	$(docker_bin) build -t $(IMAGE) -f ./docker/Dockerfile .

.PHONY: start-docker
start-docker:
	@echo "env vars:"
	make check-torrc
	$(docker_bin) rm -f $(CONTAINER_NAME) && $(docker_bin) run --name $(CONTAINER_NAME) --network host --mount type=bind,source=$(TORRC_PATH),target=/torrc,readonly $(IMAGE)

.PHONY: pull-and-start
pull-and-start:
	@echo "env vars:"
	make check-torrc
	$(docker_bin) rm -f $(CONTAINER_NAME) &&  $(docker_bin) run --name $(CONTAINER_NAME) --network host --mount type=bind,source=$(TORRC_PATH),target=/torrc,readonly $(RELEASED_IMAGE)


.PHONY: mount-and-start
start-and-mount:
	@echo "env vars:"

	make check-torrc
	make check-hidden-service


	@echo Starting container ...

	$(docker_bin) rm -f $(CONTAINER_NAME) && $(docker_bin) run --name $(CONTAINER_NAME) --network host --mount type=bind,source=$(HIDDEN_SERVICE_DIR),target=/var/lib/tor/$(SERVICE_NAME) --mount type=bind,source=$(TORRC_PATH),target=/torrc,readonly $(RELEASED_IMAGE)

	


OUT_DIR ?= directory-files
.PHONY: get-files
get-files:	
	@echo "env vars:"
	@echo "OUT_DIR: $(OUT_DIR)"
	@echo "SERVICE_NAME: $(SERVICE_NAME)"
	@echo "CONTAINER_NAME: $(CONTAINER_NAME)"

	$(docker_bin) cp $(CONTAINER_NAME):/var/lib/tor/$(SERVICE_NAME) $(OUT_DIR)

.PHONY: get-hostname
get-hostname:	
	@echo "env vars:"
	@echo "SERVICE_NAME: $(SERVICE_NAME)"
	@echo "CONTAINER_NAME: $(CONTAINER_NAME)"
	$(docker_bin) exec $(CONTAINER_NAME) cat /var/lib/tor/$(SERVICE_NAME)/hostname


check-torrc:
	@echo "TORRC_PATH: $(TORRC_PATH)"

	@if test -f "$(TORRC_PATH)"; then \
	echo "$(TORRC_PATH) exists."; else \
	echo "torrc: $(TORRC_PATH) does not exist. Exiting ..." && exit 1 ; fi
	
	@if stat -c "%a" torrc.sample | grep -q 700; then \
	echo "correct torrc permissions"; \
	else \
	echo "wrong permissions. updating permissions to 700"; \
	sudo chmod 700 $(TORRC_PATH); \
	fi
	
	@if stat -c "%u:%g" torrc.sample | grep -q 100:65534; then \
	echo "correct torrc ownership"; \
	else \
	echo "wrong ownership. updating ownership to 100:65534"; \
	sudo chown 100:65534 $(TORRC_PATH); \
	fi

check-hidden-service:
	@echo "HIDDEN_SERVICE_DIR: $(HIDDEN_SERVICE_DIR)"

	@if [ -z "$(HIDDEN_SERVICE_DIR)" ]; then echo "HIDDEN_SERVICE_DIR not set. Exiting ..."; exit 1; fi

	@if [ -d "$(HIDDEN_SERVICE_DIR)" ]; then \
	echo "$(HIDDEN_SERVICE_DIR) exists."; else \
	echo "$(HIDDEN_SERVICE_DIR) does not exist. Exiting ..."; exit 1; \
	fi



	@if stat -c "%a" $(HIDDEN_SERVICE_DIR) | grep -q 700; then \
	echo "correct hidden-service dir permissions"; \
	else \
	echo "wrong permissions. updating permissions"; \
	sudo chmod -R 700 $(HIDDEN_SERVICE_DIR); \
	fi
	
	@if stat -c "%u:%g" $(HIDDEN_SERVICE_DIR) | grep -q 100:65534; then \
	echo "correct hidden-service dir ownership"; \
	else \
	echo "wrong ownership. updating ownership"; \
	sudo chown -R 100:65534 $(HIDDEN_SERVICE_DIR); \
	fi
