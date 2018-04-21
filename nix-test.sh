#!/bin/bash

set -ex

branch=`git describe --all`
branch=${branch#*/}

machine=${1:-portal}

action=${2:-run}

binary_caches=${BINARY_CACHES:-true}
attribute=""

if [ ${action} = "driver" ]; then
    attribute="-A driver"
fi

mkdir -p outputs

#nixStable=`nix-build --no-out-link nixpkgs/default.nix -A pkgs.nixStable`
nixStable='/home/arnold/.nix-profile'

time ${nixStable}/bin/nix-build --show-trace --keep-going --max-jobs 3 --out-link outputs/${machine}-${branch} ${machine}/test.nix ${attribute}

if [ ${action} = "driver" ]; then
    ./outputs/${machine}-${branch}/bin/nixos-run-vms
fi
