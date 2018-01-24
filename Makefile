-include Makefile.config

WGET    = wget -nv
RM      = rm -Rf
CMAKE   = $(SET_ENV) cmake
MAKE    = $(SET_ENV) make
SUDO    = sudo


# ---------------------------------------------------------------------------
# Main installation targets
all: sancus-core sancus-compiler sancus-support sancus-examples
install_deps: debian-deps pip-deps ti-mspgcc clang-sancus
install: install_deps core-install compiler-install support-install sancus-examples

# Convenience targets for developers
update: core-update compiler-update support-update examples-update
build: core-build compiler-build support-build

# ---------------------------------------------------------------------------
# apt-get prerequisites as provided by Ubuntu 16.04 LTS
debian-deps:
	$(info .. Installing system-wide Ubuntu/Debian packages)
	apt-get install -yqq \
        build-essential bzip2 wget curl git cmake vim-common expect-dev \
          python3 python3-pip flex bison \
        iverilog tk binutils-msp430 gcc-msp430 msp430-libc msp430mcu
	touch debian-deps

# ---------------------------------------------------------------------------
# Python3 PIP packages
pip-deps: debian-deps
	$(info .. Installing system-wide Python3 PIP packages)
	pip3 install pyelftools \
        && printf "import elftools\nprint(elftools)" | python3
	touch pip-deps

# ---------------------------------------------------------------------------
# Package genaration targets:
-include Makefile.pkgs

# ---------------------------------------------------------------------------
# TI's MSP430 GCC compiler port (needed for most recent MSP430 GNU binutils)
# check here: http://www.ti.com/tool/msp430-gcc-opensource
$(TI_MSPGCC_TAR):
	$(WGET) $(TI_MSPGCC_URL)/$(TI_MSPGCC_TAR)

ti-mspgcc: $(TI_MSPGCC_TAR)
	$(info .. Installing TI MSPGCC to $(TI_MSPGCC_INSTALL_PREFIX))
	tar -xjf $(TI_MSPGCC_TAR) -C $(TI_MSPGCC_INSTALL_PREFIX)
	$(SET_ENV) msp430-elf-gcc --version
	touch ti-mspgcc

# ---------------------------------------------------------------------------
# Patched LLVM/Clang package since annotation patch didn't get upstream yet
$(SANCUS_CLANG_DEB):
	$(WGET) $(SANCUS_CLANG_URL)/$(SANCUS_CLANG_DEB)

clang-deb-install: $(SANCUS_CLANG_DEB)
	$(info .. Installing $(SANCUS_CLANG) package to /usr/local)
	dpkg -i $(SANCUS_CLANG_DEB) && clang --version
	touch clang-deb-install

clang-sancus: $(SANCUS_CLANG)

# ---------------------------------------------------------------------------
# Sancus project GitHub repositories
REMOTE_IS_SSH = $(shell git config --get remote.origin.url | grep "git@github.com" >/dev/null; echo $$?)

sancus-%:
ifeq ($(REMOTE_IS_SSH), 1)
	git clone https://github.com/sancus-pma/$@.git
else
	git clone git@github.com:sancus-pma/$@.git
endif

%-update: sancus-%
	cd sancus-$*/ ; git pull

%-build: sancus-%
	mkdir -p sancus-$*/build && cd sancus-$*/build && \
	$(CMAKE) -DCMAKE_INSTALL_PREFIX=$(SANCUS_INSTALL_PREFIX) \
             -DSECURITY=$(SANCUS_SECURITY) -DMASTER_KEY=$(SANCUS_KEY) ..

%-install: %-build
	$(info .. Installing sancus-$* to $(SANCUS_INSTALL_PREFIX))
	cd sancus-$*/build && $(MAKE) install

# ---------------------------------------------------------------------------
.PHONY: docker
docker:
	$(MAKE) -C docker all

# ---------------------------------------------------------------------------
examples:
	$(MAKE) -C sancus-examples

examples-sim:
	$(MAKE) -C sancus-examples sim

examples-clean:
	$(MAKE) -C sancus-examples clean

# ---------------------------------------------------------------------------
clean:
	$(RM) ti-mspgcc sancus-clang debian-deps pip-deps clang-deb-install
	$(RM) sancus-*/build
	$(RM) $(SANCUS_CLANG_DEB) $(TI_MSPGCC_TAR)

distclean: clean
	$(RM) sancus-core sancus-compiler sancus-support sancus-examples

uninstall: distclean
	$(RM) $(SANCUS_INSTALL_PREFIX)/share/sancus*
	$(RM) $(SANCUS_INSTALL_PREFIX)/bin/sancus-*
	$(RM) $(SANCUS_INSTALL_PREFIX)/lib/SancusModuleCreator.so
	$(RM) $(TI_MSPGCC_INSTALL_PREFIX)/$(TI_MSPGCC)
