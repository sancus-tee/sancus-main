# Clean Ubuntu 20.04 container
FROM ubuntu:20.04
RUN apt-get update -yqq
RUN apt-get -yqq install build-essential git lsb-release sloccount sudo vim

# Non-interactive 
RUN echo "Europe/Brussels" > /etc/timezone
RUN DEBIAN_FRONTEND=noninteractive apt-get install -yqq tzdata

# Config parameters
ARG BUILD_SECURITY=64
ARG BUILD_KEY=deadbeefcafebabe
ARG BUILD_BRANCH=master
ARG BUILD_ATOMICITY=0
# Set ENV vars based on these arguments
ENV SANCUS_SECURITY=$BUILD_SECURITY
ENV SANCUS_KEY=$BUILD_KEY
ENV SANCUS_BRANCH=$BUILD_BRANCH
ENV ATOMICITY_MONITOR=$BUILD_ATOMICITY
WORKDIR sancus

# Build and install latest Sancus toolchain
RUN git clone --branch $BUILD_BRANCH https://github.com/sancus-tee/sancus-main.git .
RUN make install clean

# Display a welcome message for interactive sessions
RUN echo '[ ! -z "$TERM" -a -r /etc/motd ] && cat /etc/motd' \
	>> /etc/bash.bashrc ; echo "\
========================================================================\n\
= Sancus development Docker container                                  =\n\
========================================================================\n\
`lsb_release -d`\n\n\
To get started, see <https://distrinet.cs.kuleuven.be/software/sancus/>,\n\
or have a look at the example programs under </sancus/sancus-examples/>.\n\
\n"\
> /etc/motd

CMD /bin/bash
