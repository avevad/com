#!/usr/bin/env bash
set -euox pipefail

cd "$(dirname "$0")"
ln -sf "$(realpath -s --relative-to="$HOME"/.config/ ./fish)" ~/.config/fish