ARG RUST_VERSION=1.99.0

FROM ghcr.io/nettimelogic-opensource/riscv-toolchain:main AS builder

ARG RUST_VERSION

# Update & install essentials
RUN sudo apt-get update \
    && sudo apt-get install -y \
    build-essential \
    curl \
    python3 \
    ninja-build \
    git \
    cmake \
    pkgconf \
    libssl-dev \
    && sudo apt-get clean \
    && sudo rm -rf /var/lib/apt/lists/*

COPY --chown=ntl bootstrap.toml bootstrap.toml
COPY --chown=ntl build.sh build.sh
RUN chmod +x build.sh \
    && ./build.sh ${RUST_VERSION} \
    && rm -rf build.sh

# Install toolchain to support target `riscv32imac-unknown-linux-gnu`
RUN cd dist \
    && for component in \
        rustc-${RUST_VERSION}-$(uname -m)-unknown-linux-gnu \
        cargo-${RUST_VERSION}-$(uname -m)-unknown-linux-gnu \
        rust-std-${RUST_VERSION}-$(uname -m)-unknown-linux-gnu \
        rust-std-${RUST_VERSION}-riscv32imac-unknown-linux-gnu; \
    do \
        tar -xzf $component.tar.gz \
        && ./$component/install.sh --prefix=$HOME/.rustup/toolchains/ntl \
        && rm -rf $component* \
        || exit 1; \
    done

FROM ghcr.io/nettimelogic-opensource/riscv-toolchain:main

ARG RUST_VERSION

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs/ | sh -s -- --default-toolchain=${RUST_VERSION} --profile minimal -c clippy -c rustfmt -y
ENV PATH="$HOME/.cargo/bin:${PATH}"

RUN mkdir -p $HOME/.rustup/toolchains

COPY --chown=ntl --from=builder /home/ntl/.rustup/toolchains/ntl /home/ntl/.rustup/toolchains/ntl

ENTRYPOINT ["/bin/bash"]
