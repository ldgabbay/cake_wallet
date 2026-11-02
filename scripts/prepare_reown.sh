#!/bin/bash
set -x -e
cd "$(dirname "$0")/.."

# reown_flutter is the submodule scripts/reown_flutter, pinned to the v0.0.4 tag
# that upstream's CI tarball (reown_flutter-v0.0.4.tar.gz) was built from.
./scripts/fetch_submodule.sh scripts/reown_flutter

cd scripts/reown_flutter
./scripts/generate_all.sh
