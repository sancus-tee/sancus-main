

TI_MSPGCC_URL  = http://software-dl.ti.com/msp430/msp430_public_sw/mcu/msp430/MSPGCC/latest/exports/
TI_MSPGCC_VERS = msp430-gcc-6.2.1.16_linux64
TI_MSPGCC_FILE = ${TI_MSPGCC_VERS}.tar.bz2

SANCUS_MAIN    = $(shell pwd)
INSTALL_PREFIX = $(shell pwd)
INSTALL_DIR    = ${INSTALL_PREFIX}/sancus

SET_ENV        = export PATH=${INSTALL_DIR}/bin:$$PATH; \
                 export LD_LIBRARY_PATH=${INSTALL_DIR}/lib:$$LD_LIBRARY_PATH; 
SANCUSMAKE     = ${SET_ENV} ${MAKE} SANCUS_DIR=${INSTALL_DIR}


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

examples-clean:
	${SANCUSMAKE} -C sancus-examples clean

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

${TI_MSPGCC_FILE}:
	wget ${TI_MSPGCC_URL}${TI_MSPGCC_FILE}

ti-msp-gcc: ${TI_MSPGCC_FILE}
	cd ${INSTALL_DIR}/ && bunzip2 -c ${SANCUS_MAIN}/${TI_MSPGCC_FILE} \
          | tar --strip-components=1 -xv

sancus-compiler: ti-msp-gcc
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


