SANCUS_DOCKER = sancus-devel

all: build run

build:
	docker build -t $(SANCUS_DOCKER) ./

run:
	docker run -i -t $(SANCUS_DOCKER) /bin/bash
