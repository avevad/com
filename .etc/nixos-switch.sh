#!/usr/bin/env bash
set -euox pipefail

cd "$(dirname "$0")"/..
cp -rf nixos/* /etc/nixos/
nixos-rebuild switch
