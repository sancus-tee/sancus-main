-include Makefile.config

WGET    = wget
RM      = rm -Rf
CMAKE   = $(SET_ENV) cmake
MAKE    = $(SET_ENV) make

ifeq ($(NO_SUDO),0)
    SUDO    = sudo
else
    SUDO    =
endif

# ---------------------------------------------------------------------------
# Main installation targets
all: sancus-core sancus-compiler sancus-support sancus-examples
install_deps: debian-deps pip-deps ti-mspgcc clang-sancus
install: install_deps core-install compiler-install support-install sancus-examples
test: examples-sim

# Convenience targets for developers
update: core-update compiler-update support-update examples-update
build: core-build compiler-build support-build

# ---------------------------------------------------------------------------
# apt-get prerequisites as provided by Ubuntu 16.04 LTS
debian-deps:
	$(info .. Installing system-wide Ubuntu/Debian packages)
	$(SUDO) apt-get install -yqq \
          build-essential bzip2 wget curl git cmake vim-common expect-dev \
          python3 python3-pip flex bison libstdc++6 \
          iverilog tk binutils-msp430 gcc-msp430 msp430-libc msp430mcu
	touch debian-deps

# ---------------------------------------------------------------------------
# Python3 PIP packages
pip-deps: debian-deps
	$(info .. Installing system-wide Python3 PIP packages)
	python3 -m pip install pyelftools \
          && printf "import elftools\nprint(elftools)" | python3
	touch pip-deps

# ---------------------------------------------------------------------------
# Package generation targets:
-include Makefile.pkgs

# ---------------------------------------------------------------------------
# TI's MSP430 GCC compiler port (needed for most recent MSP430 GNU binutils)
# check here: http://www.ti.com/tool/msp430-gcc-opensource
# 'make ti-mspgcc-deb' to build this locally.
$(TI_MSPGCC_PKG_DEB):
	$(WGET) $(SUPPORT_PKGS_URL)/$(TI_MSPGCC_PKG_DEB)

ti-mspgcc: $(TI_MSPGCC_PKG_DEB)
	$(info .. Installing TI MSPGCC binutils: $(TI_MSPGCC_PKG_DEB))
	$(SUDO) dpkg -i $(TI_MSPGCC_PKG_DEB)
	$(SET_ENV) msp430-elf-objcopy --version
	touch ti-mspgcc

# ---------------------------------------------------------------------------
# Patched LLVM/Clang package since annotation patch didn't get upstream yet
# 'make llvm-deb' to build this locally.
$(LLVM_PKG_DEB):
	$(WGET) $(SUPPORT_PKGS_URL)/$(LLVM_PKG_DEB)

clang-sancus: $(LLVM_PKG_DEB)
	$(info .. Installing LLVM/Clang for Sancus: $(LLVM_PKG_DEB))
	$(SUDO) dpkg -i $(LLVM_PKG_DEB)
	$(SET_ENV) clang --version
	touch clang-sancus

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
	cd sancus-$*/build && $(SUDO) bash -c "$(MAKE) install"

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
clean: ti-mspgcc-clean llvm-clean
	$(RM) ti-mspgcc sancus-clang debian-deps pip-deps clang-deb-install
	$(RM) sancus-*/build
	$(RM) $(LLVM_PKG_DEB) $(TI_MSPGCC_PKG_DEB)

distclean: clean ti-mspgcc-distclean llvm-distclean
	$(RM) sancus-core sancus-compiler sancus-support sancus-examples

uninstall: distclean
	$(RM) $(SANCUS_INSTALL_PREFIX)/share/sancus*
	$(RM) $(SANCUS_INSTALL_PREFIX)/bin/sancus-*
	$(RM) $(SANCUS_INSTALL_PREFIX)/lib/SancusModuleCreator.so
	$(SUDO) dpkg -r $(LLVM_PKG)
	$(SUDO) dpkg -r $(TI_MSPGCC_PKG)

