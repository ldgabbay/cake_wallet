#!/bin/bash
# Builds the monero.com APKs. `make` runs this inside Cake's build image,
# after scripts/android/docker/build.sh has put the native libraries in place.
set -euo pipefail
cd "$(dirname "$0")/../.."

# The container runs as root; hand what it wrote back to the host user.
trap 'find . -xdev -user 0 -exec chown -h "$HOST_UID:$HOST_GID" {} +' EXIT

git config --global --add safe.directory '*'

pushd scripts/android
  source ./app_env.sh monero.com
  ./app_config.sh
popd

# Never replaces an existing key: an APK signed with another key won't
# install over the one already on a device.
if [[ ! -f android/key.properties ]]; then
  pass="$(openssl rand -hex 16)"
  keytool -genkey -keystore android/app/key.jks -keyalg RSA -keysize 2048 \
    -validity 10000 -alias key -dname "CN=Monero.com" -noprompt \
    -storepass "$pass" -keypass "$pass"
  dart run tool/generate_android_key_properties.dart \
    keyAlias=key storeFile=key.jks storePassword="$pass" keyPassword="$pass"
fi

# Creates tool/.secrets-config.json on first run, otherwise keeps it, then
# writes the .secrets.g.dart files from it.
dart run tool/generate_new_secrets.dart

flutter pub get
./model_generator.sh
dart run tool/generate_localization.dart
./compile_graphics.sh

flutter build apk --release --split-per-abi
