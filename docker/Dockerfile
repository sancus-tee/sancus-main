# Clean Ubuntu 16.04 container
FROM ubuntu:16.04
RUN apt-get update -yqq
RUN apt-get -yqq install build-essential git lsb-release

# Config parameters
ARG SANCUS_SECURITY=64
ARG SANCUS_KEY=deadbeefcafebabe
ARG TI_MSPGCC=msp430-gcc-6.4.0.32_linux64
WORKDIR sancus

# Build and install latest Sancus toolchain
RUN git clone https://github.com/sancus-pma/sancus-main.git .
RUN make install clean TI_MSPGCC=$TI_MSPGCC \
                       SANCUS_SECURITY=$SANCUS_SECURITY SANCUS_KEY=$SANCUS_KEY
ENV PATH=$PATH:/opt/$TI_MSPGCC/bin

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
