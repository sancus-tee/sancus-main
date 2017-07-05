# sancus-main

Requirements and Dependencies:

- **cmake**
- **pyelftools** (Python 3+)
- **msp430-gcc**
- **iverilog** (if you want to use the simulator)
- **35GB of free disk space** (most of this is for temporary files created
  by LLVM/Clang during the build process and can be cleaned up afterwards)



Building Instructions:

```
git clone git@github.com:sancus-pma/sancus-main.git
cd sancus main
git submodule init
git submodule update
make
make examples-build
make examples-sim
```

To remove temporary files:
```
make clean
```

To remove temporary files and the installation **directory**:
```
make distclean
```


