# sancus-main/docker

The scripts in this directory allow you to build a docker image that
contains the Sancus toolchain, ready to run the example programs and to
start your own experiments.

## Install docker

Quick installation guide (Debian GNU/Linux and Ubuntu), loosely based on
https://docs.docker.com/get-started/

### 1. Install docker

```bash
# apt-get install docker.io
```

### 2. Configure user access

```bash
# usermod -aG docker $(whoami) # add users to docker group, then re-login.
```

### 3. Check your docker installation

```bash
$ docker run hello-world
[...]
This message shows that your installation appears to be working correctly.
[...]
```

### 4. Build and run the 'sancus-devel' image

```bash
$ make build
$ make run
```

### 7. Play Sancus

You are now running the 'sancus-devel' container. Try running one of the
examples:

```bash
# cd /sancus/sancus-examples/hello-world/
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

