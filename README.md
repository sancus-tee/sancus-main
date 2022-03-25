# sancus-main

[![Docker](https://github.com/sancus-tee/sancus-main/actions/workflows/docker.yml/badge.svg)](https://github.com/sancus-tee/sancus-main/actions/workflows/docker.yml)
[![Sancus examples](https://github.com/sancus-tee/sancus-examples/actions/workflows/run-examples.yml/badge.svg)](https://github.com/sancus-tee/sancus-examples/actions/workflows/run-examples.yml)

This repository contains a build script (Makefile) to create a working
[Sancus](https://distrinet.cs.kuleuven.be/software/sancus/) development
environment by resolving system dependencies, and installing the latest
sub-projects. The resulting Sancus distribution offers a complete development
environment, including simulator, compiler/toolchain, support libraries, and
example programs.

To get started quickly, we also provide a Docker script that uses the Makefile
to automatically build an Ubuntu 18.04-based 'sancus-devel' container. Simply
execute `make docker` to build and run the Docker container, or see the
[docker](docker) subdirectory for detailed instructions.

## Quickstart

If you do not care about modifying the Sancus code itself but just wish to work with the existing toolchain, using the Docker images may already be enough for you!

```bash
# Pull latest Sancus image for 128 bit security
$ docker pull ghcr.io/fritzalder/sancus-main/sancus-devel-128:latest
# Run Docker interactively
$ docker run -it ghcr.io/fritzalder/sancus-main/sancus-devel-128:latest
# Run Docker and attach directory ~/project into the Docker file system
$ docker run -it -v ~/project:/sancus/project ghcr.io/fritzalder/sancus-main/sancus-devel-128:latest
# Run Docker and attach above directory but also forward USB UART0 to the container
$ docker run -it -v ~/project:/sancus/project --device /dev/ttyUSB0 ghcr.io/fritzalder/sancus-main/sancus-devel-128:latest
```

Inside docker, you may then wish to first load the FPGA image on the board. Download the latest released flash files from [Sancus core](https://github.com/sancus-tee/sancus-core/releases/latest) and flash them on the board.
```bash
# Flash FPGA image file
$ xsload --flash <mcs file>
# !! Manually press the reset button on the board once to reset it

# Now in a terminal outside of the Docker container, open a screen session to see the future output on the UART 1:
$ screen /dev/ttyUSB1 115200

# Now you are ready to load the elf file from inside the docker via UART0:
# The docker image comes with sancus-examples pulled.
$ cd /sancus/sancus-examples
$ cd hello-world
$ make load SANCUS_SECURITY=128
# Or alternatively, to perform these steps manually:
$ make clean
$ make all SANCUS_SECURITY=128
$ sancus-loader -device /dev/ttyUSB0 main.elf
```

## Requirements and Dependencies

Note: The build script was developed to work on a fresh Ubuntu 18.04/20.04
LTS installation, but it should be fairly straightforward to port to other
GNU/Linux distribution.

The following dependencies are automatically installed when invoking `make
install_deps`:

- **cmake** >= 3.4.3
- **pyelftools** (Python 3+)
- **msp430-gcc** >= 4.6
- **msp430-elf-gcc** >= 6.0 provided by
        [Texas Instruments](http://www.ti.com/tool/msp430-gcc-opensource) (Debian package provided, see below)
- **iverilog** >= 0.9 (if you want to use the simulator)
- **Clang/LLVM** >= 3.4.3 (needs to be patched, Debian package provided; see below)
- **xstools** (see below)

While developing the Sancus compiler, we found a bug in **Clang** that has not yet
been merged upstream, and thus needs to be patched before being able to use our
compiler. The easiest way to do this is to install the provided [Debian
package](https://distrinet.cs.kuleuven.be/software/sancus/install.php) for AMD64 and ARMHF. This
package is called clang-sancus and will be installed in /usr/local/. If you
want to patch and build LLVM/Clang manually, use/check `make llvm-inst` (you need 35GB of free disk space, most of this is for temporary files created by LLVM/Clang during the build
process and can be cleaned up afterwards).

From **msp430-elf-gcc** we need the latest `binutils` for the MSP430. As for Cland, we provide these pre-packaged for Debian-based Linux distributions on AMD64 and ARMHF. Use or check `make ti-mspgcc-inst` to build msp430-elf-gcc from source.

## Building Instructions:

```bash
$ git clone https://github.com/sancus-tee/sancus-main.git
$ cd sancus-main

# 1. Install prerequisites
$ sudo make install_deps # default installation directory for Clang and \
                         # msp430-elf-gcc is /usr/local

# 2. Clone relevant Sancus project git repositories
$ make

# 3. Build and install Sancus toolchain
$ sudo make install      # to override default security level (64 bits), use \
                         # SANCUS_SECURITY=128                               \
                         # SANCUS_KEY=deadbeefcafebabec0defeeddefec8ed       \
                         # use SANCUS_INSTALL_PREFIX=dir to override default \
                         # installation directory /usr/local
```

## XSTOOLS Installation

```bash
$ sudo pip2 install PyPubSub==3.3.0
$ sudo pip2 install xstools
$ sudo xstest   # to test the connected FPGA boards
$ sudo xsload -b xula2-lx25 --flash path/to/image.mcs  # program the FPGA
```

## Example Programs

To test your newly installed Sancus distribution, run the example programs/test
suite in the simulator (might take a long time since the hardware design is
simulated at the gate-level).

```
$ make examples
$ make examples-sim
```

## Cleanup and Uninstall

To remove temporary files:

```bash
$ sudo make clean
```

To remove temporary files, including all source code and example programs:

```bash
$ sudo make distclean
```

To remove the Sancus installation directory system-wide:

```bash
$ sudo make uninstall
```
