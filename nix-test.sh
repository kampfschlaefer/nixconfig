#!/bin/sh

set -ex

branch=`git describe --all`
branch=${branch#*/}

machine=${1:-portal}
if [ $machine = "homeassistant" ]; then
    machine=lib/software/homeassistant
fi

action=${2:-run}

binary_caches=${BINARY_CACHES:-true}
attribute=""

if [ ${action} = "driver" ]; then
    attribute="driver"
fi

mkdir -p outputs

nixStable=`nix-build --no-out-link nixpkgs/default.nix -A pkgs.nixStable`

out=`nix-instantiate ${machine}/test.nix`

time ${nixStable}/bin/nix -v build --show-trace --out-link outputs/${machine}-${branch} -f ${machine}/test.nix ${attribute} || ( nix log $out; exit 1 )

if [ ${action} = "driver" ]; then
    ./outputs/${machine}-${branch}/bin/nixos-run-vms
fi
