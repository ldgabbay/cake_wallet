#!/bin/bash
set -x -e
cd "$(dirname "$0")/.."

# torch_dart is the submodule scripts/torch_dart, pinned to the v1.0.17 tag
# that upstream's CI tarball (torch_dart-v1.0.17.tar.gz) was built from.
./scripts/fetch_submodule.sh scripts/torch_dart
