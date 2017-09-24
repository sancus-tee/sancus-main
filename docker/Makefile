
COREIMG = ubuntu-xenial-core-cloudimg-amd64-root.tar.gz

all:

build: ${COREIMG}
	docker build -t sancus ./

run:
	docker run -i -t sancus /bin/bash


${COREIMG}:
	wget https://github.com/tianon/docker-brew-ubuntu-core/raw/31ebd22e9e83185d69d50b3492911aedf519dd4a/xenial/${COREIMG}


clean:
	rm -f ${COREIMG}

distclean: clean



