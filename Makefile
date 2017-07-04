
INSTALL_PREFIX = $(shell pwd)
INSTALL_DIR = ${INSTALL_PREFIX}/sancus

all:
	mkdir -p ${INSTALL_DIR}
	${MAKE} llvm

patch: clang.patch
	cd clang ; \
	patch -p1 < ../clang.patch

unpatch:
	cd clang ; \
	patch -p1 -R < ../clang.patch

llvm: patch
	mkdir -p llvm/build
	cd llvm/tools ; ln -s ../../clang clang
	cd llvm/build ; cmake \
          -DLLVM_TARGETS_TO_BUILD=MSP430 \
          -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
          ..
	cd llvm/build ; make -j 2


clean: unpatch
	rm -rf llvm/build

distclean: clean
	rm -rf ${INSTALL_DIR}


