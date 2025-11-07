ARG RUST_VERSION=1.91.0

FROM ghcr.io/nettimelogic-opensource/riscv-toolchain:main AS builder

ARG RUST_VERSION

# Update & install essentials
RUN sudo apt-get update \
    && sudo apt-get install -y \
    autoconf \
    automake \
    autotools-dev \
    curl \
    python3 \
    python3-pip \
    python3-tomli \
    libmpc-dev \
    libmpfr-dev \
    libgmp-dev \
    gawk \
    build-essential \
    bison \
    flex \
    texinfo \
    gperf \
    libtool \
    patchutils \
    bc \
    zlib1g-dev \
    libexpat-dev \
    ninja-build \
    git \
    cmake \
    libglib2.0-dev \
    libslirp-dev \
    pkgconf \
    libssl-dev \
    && sudo apt-get clean \
    && sudo rm -rf /var/lib/apt/lists/*

COPY --chown=ntl bootstrap.toml bootstrap.toml
COPY --chown=ntl build.sh build.sh
RUN chmod +x build.sh \
    && ./build.sh ${RUST_VERSION} \
    && rm -rf build.sh 

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs/ | sh -s -- --default-toolchain=${RUST_VERSION} -y
ENV PATH="$HOME/.cargo/bin:${PATH}"

# Install toolchain to support target `riscv32imac-unknown-linux-gnu`
RUN cd dist \
    && tar -xzvf rust-${RUST_VERSION}-$(uname -m)-unknown-linux-gnu.tar.gz \
    && ./rust-${RUST_VERSION}-$(uname -m)-unknown-linux-gnu/install.sh --prefix=$HOME/.rustup/toolchains/ntl \
    && rm -rf rust-${RUST_VERSION}-$(uname -m)-unknown-linux-gnu* \
    && tar -xzvf rust-std-${RUST_VERSION}-riscv32imac-unknown-linux-gnu.tar.gz \
    && ./rust-std-${RUST_VERSION}-riscv32imac-unknown-linux-gnu/install.sh --prefix=$HOME/.rustup/toolchains/ntl \
    && rm -rf rust-std-${RUST_VERSION}-riscv32imac-unknown-linux-gnu*

FROM ghcr.io/nettimelogic-opensource/riscv-toolchain:main

ARG RUST_VERSION

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs/ | sh -s -- --default-toolchain=${RUST_VERSION} -y
ENV PATH="$HOME/.cargo/bin:${PATH}"

RUN mkdir -p $HOME/.rustup/toolchains

COPY --chown=ntl --from=builder /home/ntl/.rustup/toolchains/ntl /home/ntl/.rustup/toolchains/ntl

ENTRYPOINT ["/bin/bash"]
