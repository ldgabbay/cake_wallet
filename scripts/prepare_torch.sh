#!/bin/bash
set -x -e
cd "$(dirname "$0")/.."

# torch_dart is the submodule scripts/torch_dart, pinned to the commit Cake
# v6.5.0 pins. Don't move it back to the v1.0.17 tag: that tag's simplybs fails
# to build libevent for Android from source.
./scripts/fetch_submodule.sh scripts/torch_dart
