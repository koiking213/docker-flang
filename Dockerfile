FROM ubuntu:18.04
MAINTAINER Fujii
# gawk is needed to build libpgmath
RUN apt-get update -y \
 && apt-get install -y build-essential cmake vim git python ninja-build gawk

RUN git clone https://github.com/flang-compiler/llvm.git \
 && cd llvm \
 && git checkout release_60 \
 && mkdir build && cd build \
 && cmake -DCMAKE_BUILD_TYPE=Release -G Ninja .. \
 && ninja \
 && ninja install

RUN git clone https://github.com/flang-compiler/flang-driver.git \
 && cd flang-driver \
 && git checkout release_60 \
 && mkdir build && cd build \
 && cmake -DCMAKE_BUILD_TYPE=Release -G Ninja .. \
 && ninja \
 && ninja install

RUN git clone https://github.com/llvm-mirror/openmp.git \
 && cd openmp/runtime \
 && git checkout release_60 \
 && mkdir build && cd build \
 && cmake -DCMAKE_BUILD_TYPE=Release -G Ninja ../.. \
 && ninja \
 && ninja install

RUN git clone https://github.com/flang-compiler/flang.git \
 && cd flang/runtime/libpgmath \
 && mkdir build && cd build \
 && cmake -DCMAKE_CXX_COMPILER=/usr/local/bin/clang++ -DCMAKE_C_COMPILER=/usr/local/bin/clang -DCMAKE_BUILD_TYPE=Release -G Ninja .. \
 && ninja \
 && ninja install

RUN cd flang \
 && mkdir build && cd build \
 && cmake -DCMAKE_CXX_COMPILER=/usr/local/bin/clang++ -DCMAKE_C_COMPILER=/usr/local/bin/clang -DCMAKE_Fortran_COMPILER=flang -DCMAKE_BUILD_TYPE=Release .. \
 && make \
 && make install

RUN export LD_LIBRARY_PATH=/usr/local/lib
