-include ../Makefile.config

SANCUS_DOCKER = sancus-devel

all: build run

build:
	docker build -t $(SANCUS_DOCKER) --build-arg SANCUS_SECURITY=$(SANCUS_SECURITY) --build-arg SANCUS_KEY=$(SANCUS_KEY) .

run:
	docker run -i -t $(SANCUS_DOCKER) /bin/bash
