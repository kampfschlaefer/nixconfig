#!/bin/bash

set -ex

branch=`git describe --all`
branch=${branch#*/}

machine=${1:-portal}

binary_caches=${BINARY_CACHES:-true}

mkdir -p outputs

time nix-build --show-trace --option use-binary-caches ${binary_caches} --keep-going --max-jobs 3 --out-link outputs/${machine}-${branch} ${machine}/test.nix
