#!/usr/bin/env bash
set -eu
REPO="https://github.com/github/cmark-gfm.git"
REPO_DIR="cmark-gfm"
BRANCH="0.29.0.gfm.0"
BUILD_DIR="build"

rm -rf "$REPO_DIR"
git clone "$REPO" "$REPO_DIR"
cd "$REPO_DIR"
git checkout "$BRANCH"

rm -rf "$BUILD_DIR"
mkdir "$BUILD_DIR"
cd "$BUILD_DIR"
cmake .. -DCMARK_SHARED=off
make -j$(nproc)
ldd src/cmark-gfm
