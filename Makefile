
INSTALL_PREFIX = $(shell pwd)
INSTALL_DIR    = ${INSTALL_PREFIX}/sancus

SET_ENV        = export PATH=${INSTALL_DIR}/bin:$$PATH; \
                 export LD_LIBRARY_PATH=${INSTALL_DIR}/lib:$$LD_LIBRARY_PATH; \
                 export SANCUS_DIR=${INSTALL_DIR};
SANCUSMAKE     = ${SET_ENV} ${MAKE} \
                 SANCUS_SUPPORT_DIR=${INSTALL_DIR}/share/sancus-support


# ---------------------------------------------------------------------------
all:
	mkdir -p ${INSTALL_DIR}
	${MAKE} llvm sancus-core sancus-compiler sancus-support


# ---------------------------------------------------------------------------
examples: examples-build examples-sim

examples-build:
	${SANCUSMAKE} -C sancus-examples MODE=all

examples-sim:
	${SANCUSMAKE} -C sancus-examples MODE=sim

examples-load:
	${SANCUSMAKE} -C sancus-examples MODE=load


# ---------------------------------------------------------------------------
.PHONY: llvm sancus-core sancus-compiler sancus-support

patch: clang.patch
	cd clang ; \
	patch -p1 < ../clang.patch

unpatch:
	cd clang ; \
	patch -p1 -R < ../clang.patch

sancus-core:
	mkdir -p $@/build
	cd $@/build && \
         ${SET_ENV} cmake -DLLVM_DIR=${INSTALL_DIR}/share/llvm/cmake/ \
         -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
         ..
	cd $@/build && ${MAKE} install

sancus-compiler:
	mkdir -p $@/build
	cd $@/build && \
         ${SET_ENV} cmake -DLLVM_DIR=${INSTALL_DIR}/share/llvm/cmake/ \
         -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
         ..
	cd $@/build && ${SANCUSMAKE} install

sancus-support:
	mkdir -p $@/build
	cd $@/build && \
         ${SET_ENV} cmake -DLLVM_DIR=${INSTALL_DIR}/share/llvm/cmake/ \
         -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
         -DCMAKE_BUILD_TYPE=Release \
         ..
	cd $@/build && ${SANCUSMAKE} install

llvm: patch
	mkdir -p $@/build
	cd $@/tools && ln -s ../../clang clang
	cd $@/build && cmake \
          -DLLVM_TARGETS_TO_BUILD=MSP430 \
          -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR} \
          ..
	cd $@/build && ${MAKE} -j 2
	cd $@/build && ${MAKE} install


# ---------------------------------------------------------------------------
clean: unpatch
	rm -rf llvm/build
	rm -rf llvm/tools/clang
	rm -rf sancus-core/build
	rm -rf sancus-compiler/build
	rm -rf sancus-support/build
	${SANCUSMAKE} -C sancus-examples clean

distclean: clean
	rm -rf ${INSTALL_DIR}
	${SANCUSMAKE} -C sancus-examples distclean


