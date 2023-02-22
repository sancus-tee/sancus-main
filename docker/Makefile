-include ../Makefile.config

SANCUS_DOCKER = sancus-devel
SANCUS_BRANCH = $(shell git rev-parse --abbrev-ref HEAD)

all: build run

build:
	docker build -t $(SANCUS_DOCKER) --build-arg BUILD_BRANCH=$(SANCUS_BRANCH) --build-arg BUILD_SECURITY=$(SANCUS_SECURITY) --build-arg BUILD_KEY=$(SANCUS_KEY) --build-arg BUILD_ATOMICITY=$(ATOMICITY_MONITOR) .

run:
	docker run -i -t $(SANCUS_DOCKER) /bin/bash
