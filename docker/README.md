# sancus-mail/docker

The scripts in this directory allow you to build a docker image that
contains the sancus toolchain, ready to run the example programs and to
start your own experiments.


## Install docker

Quick installation guide (Debian Linux and Ubuntu), loosely based on
https://docs.docker.com/get-started/

### 1. Install prerequisites
```bash
# apt-get install \
     apt-transport-https \
     ca-certificates \
     curl \
     gnupg2 \
     software-properties-common
```

### 2. Setup docker repository 
```bash
# curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg | apt-key add -
# add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
   $(lsb_release -cs) \
   stable"
```

### 3. Install docker
```bash
# apt-get update
# apt-get install docker-ce
```

### 4. Configure user access
```bash
# vi /etc/group ; add relevant users to docker group, then re-login.
```

### 5. Check your docker installation
```bash
$ docker run hello-world
[...]
This message shows that your installation appears to be working correctly.
[...]
```

### 6. Build and run the 'sancus' image
```bash
$ make build
$ make run
```

### 7. Play sancus

You are now running the 'sancus' container. Try running one of the
examples:

```bash
# cd /tmp/sancus-main/sancus-examples/hello-world/
# make sim
sancus-sim --ram 16K --rom 41K  main.elf
=== Spongent parameters ===
Rate:        18
State size: 176
===========================
=== SpongeWrap parameters ===
Rate:           16
Security:       64
Blocks in key:   4
=============================
=== File I/O ===
Input:  'sim-input.bin'
Output: 'sim-output.bin'
================
FST info: dumpfile sancus_sim.fst opened for output.
******************************
* Sancus simulation started  *
* ROM: 41984B                *
* RAM: 16384B                *
******************************
[...]
```

Have fun!

