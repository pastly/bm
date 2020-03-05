#!/usr/bin/env bash
set -eu
REPO="https://github.com/github/cmark-gfm.git"
REPO_DIR="cmark-gfm"
BRANCH="0.29.0.gfm.0"
BUILD_DIR="build"

cat <<HEREDOC
==================================================================
Downloading cmark-gfm from $REPO
Using branch/version $BRANCH
==================================================================
HEREDOC

sleep 3

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

cat <<HEREDOC
========================================================================
We seem to have been successful!
Now manually copy $REPO_DIR/$BUILD_DIR/src/cmark-gfm to internal/cmark-gfm
                      WE DIDN'T DO IT FOR YOU
========================================================================
HEREDOC
