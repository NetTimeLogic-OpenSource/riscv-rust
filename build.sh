#!/usr/bin/env bash

set -euo pipefail

# Variables
RUST_VERSION=$1
RUST_TAG=rust-ntl-$RUST_VERSION
RUST_SRC=$PWD/rust

mkdir dist

git clone --filter='blob:none' https://github.com/nettimelogic-opensource/rust.git $RUST_SRC -b $RUST_TAG

cp bootstrap.toml $RUST_SRC/bootstrap.toml

pushd $RUST_SRC

# Only rustc, cargo and std are needed; skips docs and the other tools
./x dist rustc cargo rust-std --target $(uname -m)-unknown-linux-gnu,riscv32imac-unknown-linux-gnu

popd

cp $RUST_SRC/build/dist/rustc-$RUST_VERSION-$(uname -m)-unknown-linux-gnu.tar.gz dist/
cp $RUST_SRC/build/dist/cargo-$RUST_VERSION-$(uname -m)-unknown-linux-gnu.tar.gz dist/
cp $RUST_SRC/build/dist/rust-std-$RUST_VERSION-$(uname -m)-unknown-linux-gnu.tar.gz dist/
cp $RUST_SRC/build/dist/rust-std-$RUST_VERSION-riscv32imac-unknown-linux-gnu.tar.gz dist/

echo "Rust toolchain built successfully."

# Cleanup
rm -rf $RUST_SRC
echo "Temporary files cleaned up."
