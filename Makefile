-include Makefile.config

WGET    = wget -nv
RM      = rm -Rf
CMAKE   = $(SET_ENV) cmake
MAKE    = $(SET_ENV) make

ifeq ($(UNAME_M),armv7l)
# Default checkinstall is buggy:
# https://github.com/giuliomoro/checkinstall/commit/57ad1473bdfc5aadd2c921d6990e069809f442d4
CHECKINSTALL = /usr/local/sbin/checkinstall
else
CHECKINSTALL = checkinstall
endif


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
TI_MSPGCC_VER     = 6.4.0.32
TI_MSPGCC_SRC_DIR = msp430-gcc-$(TI_MSPGCC_VER)_source-full
TI_MSPGCC_SRC_TBZ = $(TI_MSPGCC_SRC_DIR).tar.bz2

$(TI_MSPGCC_SRC_TBZ):
	$(WGET) http://software-dl.ti.com/msp430/msp430_public_sw/mcu/msp430/MSPGCC/latest/exports/$(TI_MSPGCC_SRC_TBZ)

ti-mspgcc_src: $(TI_MSPGCC_SRC_TBZ)
	bunzip2 -c $(TI_MSPGCC_SRC_TBZ) | tar -x

ti-mspgcc_build:
	cd $(TI_MSPGCC_SRC_DIR)/binutils && \
	  ./configure --target=msp430-elf \
	    --enable-languages=c,c++ --disable-nls \
	    --prefix=/usr/local --disable-sim --disable-gdb --disable-werror
	cd $(TI_MSPGCC_SRC_DIR)/binutils && \
	  $(MAKE)

ti-mspgcc_pkg:
	sudo mkdir -p /usr/local/msp430-elf/lib
	cd $(TI_MSPGCC_SRC_DIR)/binutils && \
	  echo "TI MSP430-GCC binutils for Sancus." >description-pak && \
	  sudo $(CHECKINSTALL) -y -D --install=no --backup=no \
	  --pkgname=ti-mspgcc-binutils-sancus --pkgversion=$(TI_MSPGCC_VER) \
	  --pkgrelease=1 \
	  --pkgsource="http://www.ti.com/tool/msp430-gcc-opensource" \
	  --pakdir=../../ --provides=ti-mspgcc-binutils-sancus \
	  --maintainer='Jan Tobias Muehlberg <jantobias.muehlberg@cs.kuleuven.be>' \
	  --deldoc --deldesc --delspec

# ---------------------------------------------------------------------------
# Patched LLVM/Clang package since annotation patch didn't get upstream yet
$(SANCUS_CLANG_DEB):
	$(WGET) $(SANCUS_CLANG_URL)/$(SANCUS_CLANG_DEB)

clang-deb-install: $(SANCUS_CLANG_DEB)
	$(info .. Installing $(SANCUS_CLANG) package to /usr/local)
	dpkg -i $(SANCUS_CLANG_DEB) && clang --version
	touch clang-deb-install

# ---------------------------------------------------------------------------
# Optionally patch LLVM/Clang from source
clang_patch: clang.patch
	git submodule init
	git submodule update
	cd clang ; \
	patch -p1 < ../clang.patch

clang_unpatch:
	cd clang ; \
	patch -p1 -R < ../clang.patch

LLVM_BUILD_FLAGS = -DLLVM_TARGETS_TO_BUILD=MSP430 \
                   -DCMAKE_INSTALL_PREFIX=$(SANCUS_INSTALL_PREFIX)

ifeq ($(UNAME_M),armv7l)
# This is meant to work for raspbian/debian Stretch
LLVM_BUILD_FLAGS += -DCMAKE_BUILD_TYPE=Release
endif


llvm: clang_patch
	$(info .. Building and installing patched LLVM/Clang to $(SANCUS_INSTALL_PREFIX))
ifeq ($(UNAME_M),armv7l)
	$(info .. Building LLVM/Clang on/for $(UNAME_M): use 2GiB swap and ld.gold)
endif
	mkdir -p $@/build
	cd $@/tools && ln -sf ../../clang clang
	cd $@/build && cmake $(LLVM_BUILD_FLAGS) ..
	cd $@/build && $(MAKE) -j 2

llvm-install-deb: llvm
	$(info .. Building .deb of patched LLVM/Clang to $(SANCUS_INSTALL_PREFIX))
	cd llvm/build/ && \
	  echo "Clang with Sancus patches." >description-pak && \
	  $(CHECKINSTALL) -y -D --install=no --backup=no \
	  --pkgname=clang-sancus --pkgversion=4.0.1 --pkgrelease=2 \
	  --pkgsource="https://distrinet.cs.kuleuven.be/software/sancus/" \
	  --pakdir=../../ --provides=clang-sancus \
	  --maintainer='Jan Tobias Muehlberg <jantobias.muehlberg@cs.kuleuven.be>' \
	  --deldoc --deldesc --delspec

llvm-install:
	$(info .. Installing patched LLVM/Clang to $(SANCUS_INSTALL_PREFIX))
	cd llvm/build && $(MAKE) install

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
