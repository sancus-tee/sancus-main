
INSTALL_PREFIX = $(shell pwd)
INSTALL_DIR = ${INSTALL_PREFIX}/sancus

SET_ENV      = export PATH=${INSTALL_DIR}/bin:$$PATH; \
               export LD_LIBRARY_PATH=${INSTALL_DIR}/lib:$$LD_LIBRARY_PATH;
SANCUSMAKE   = ${SET_ENV} ${MAKE}


# ---------------------------------------------------------------------------
all:
	mkdir -p ${INSTALL_DIR}
	${MAKE} llvm sancus-core sancus-compiler sancus-support


# ---------------------------------------------------------------------------
.PHONY: llvm sancus-core sancus-compiler sancus-support

patch: clang.patch
	cd clang ; \
	patch -p1 < ../clang.patch

unpatch:
	cd clang ; \
	patch -p1 -R < ../clang.patch

sancus-core:
	mkdir -p sancus-core/build
	cd sancus-core/build && \
         ${SET_ENV} cmake -DLLVM_DIR=${INSTALL_DIR}/share/llvm/cmake/ \
         -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
         ..
	cd sancus-core/build && ${MAKE} install

sancus-compiler:
	mkdir -p sancus-compiler/build
	cd sancus-compiler/build && \
         ${SET_ENV} cmake -DLLVM_DIR=${INSTALL_DIR}/share/llvm/cmake/ \
         -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
         ..
	cd sancus-compiler/build && ${SANCUSMAKE} install

sancus-support:
	mkdir -p sancus-support/build
	cd sancus-support/build && \
         ${SET_ENV} cmake -DLLVM_DIR=${INSTALL_DIR}/share/llvm/cmake/ \
         -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
         -DCMAKE_BUILD_TYPE=Release \
         ..
	cd sancus-support/build && ${SANCUSMAKE} install

llvm: patch
	mkdir -p llvm/build
	cd llvm/tools && ln -s ../../clang clang
	cd llvm/build && cmake \
          -DLLVM_TARGETS_TO_BUILD=MSP430 \
          -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
          ..
	cd llvm/build && ${MAKE} -j 2
	cd llvm/build && ${MAKE} install


# ---------------------------------------------------------------------------
clean: unpatch
	rm -rf llvm/build
	rm -rf llvm/tools/clang
	rm -rf sancus-core/build
	rm -rf sancus-compiler/build
	rm -rf sancus-support/build

distclean: clean
	rm -rf ${INSTALL_DIR}


