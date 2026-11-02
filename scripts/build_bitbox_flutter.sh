#!/bin/bash
set -x -e
cd "$(dirname "$0")/.."

# bitbox_flutter is the submodule scripts/bitbox_flutter.
./scripts/fetch_submodule.sh scripts/bitbox_flutter

cd scripts/bitbox_flutter
bash ./build_bindings.sh --dont-install

FILE=api.aar
if [ -f "$FILE" ]; then
    echo "$FILE exists."
fi
