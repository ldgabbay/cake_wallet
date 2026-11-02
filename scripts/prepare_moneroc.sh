#!/bin/bash

set -x -e

cd "$(dirname "$0")/.."

# NOTE: Make sure to update monero_c prebuilds link in workflow files
# https://github.com/MrCyjaneK/monero_c/releases/download/v0.18.4.6-RC2/release-bundle.zip
./scripts/fetch_submodule.sh scripts/monero_c --recursive

echo "monero_c source prepared".
