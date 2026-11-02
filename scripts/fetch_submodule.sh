#!/bin/bash
# Usage: fetch_submodule.sh <path> [--recursive]
#
# In a checkout this is `git submodule update`. The stages in
# scripts/android/docker/build.sh have no parent repo, so there it clones
# SUBMODULE_URL at SUBMODULE_REF, which build.sh reads from the parent.
set -x -e
cd "$(dirname "$0")/.."

path="$1"
shift

if git rev-parse --git-dir >/dev/null 2>&1; then
    git submodule update --init "$@" "$path"
    exit 0
fi

git clone "${SUBMODULE_URL:?}" "$path"
git -C "$path" checkout "${SUBMODULE_REF:?}"
if [[ "${1:-}" == "--recursive" ]]; then
    git -C "$path" submodule update --init --recursive
fi
