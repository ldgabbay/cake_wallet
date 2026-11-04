# Building the monero.com APK

From a fresh clone:

```sh
git clone https://github.com/ldgabbay/cake_wallet.git
cd cake_wallet
make
```

The APKs, one per ABI, end up in `build/app/outputs/flutter-apk/`:

```
app-arm64-v8a-release.apk     most phones
app-armeabi-v7a-release.apk   older 32-bit phones
app-x86_64-release.apk        emulators
```

## What the system needs

Everything else runs inside Docker, in the image Cake's own builds use.

- Linux on x86_64. The images are `linux/amd64`, so other hosts would run
  them under emulation; only Linux x86_64 has been tried.
- [Docker Engine](https://docs.docker.com/engine/install/), with your user
  allowed to run `docker` (the `docker` group).
- `git`, `make`, `rsync`, `bash`, `sed`, GNU coreutils and findutils. On
  Debian or Ubuntu, `sudo apt install git make rsync` covers the ones a base
  install lacks.
- Disk: about 150 GB free. A first build used about 110 GB: 31 GB of images,
  45 GB of Docker build cache, 24 GB in the cache volumes and 7 GB of tree.
- Time: the first build compiles every native library (Monero, Wownero, Zano,
  Tor, Zcash and the rest) and fetches every Dart package. On a 20-thread
  machine with an encrypted disk it took about 7.5 hours: 40 minutes for the
  small stages, 3.5 hours for Monero, 2 hours for Tor, and an hour for the
  APK itself. Later builds skip every native stage whose inputs haven't
  changed.

You don't need Flutter, the Android SDK, the NDK, Rust or Go on the host.

## What `make` does

1. `make native` runs `scripts/android/docker/build.sh`. It builds the native
   libraries in Docker stages, one image per component, tagged by a hash of
   their inputs, and copies the results into the tree. An unchanged stage is
   skipped next time.
2. `make apk` (the default) runs `scripts/android/build_apk_in_docker.sh` in
   Cake's build image. It configures the monero.com flavor, writes the
   secrets, runs codegen and `flutter build apk --release --split-per-abi`.
   The Dart and Gradle caches stay in the Docker volumes `cake-pub-cache` and
   `cake-gradle`.

The build downloads a lot, and a failed fetch (an HTTP 504 from GitHub, say)
stops it. Run `make` again: it resumes from the first stage that hadn't
finished.

## Signing key and secrets

On the first build `make` creates:

- `android/app/key.jks` and `android/key.properties`: a new signing key with a
  random password.
- `tool/.secrets-config.json` and `tool/.*-secrets-config.json`: random salts
  and keys, written to the `.secrets.g.dart` files.

These files are ignored by git, and `make` never replaces them. Back them up.
Android only installs an update signed with the same key, and the salts
encrypt the app's PIN and wallet passwords, so a build with new ones can't
open what an older build stored.

To build an update for an app that's already installed, put the old files
back before running `make`.

## Options

- `CW_DOCKER_NETWORK=host make` runs the builds on the host's network. Use it
  when containers can't resolve names on the default bridge network.
- `CW_DOCKER_REGISTRY=ghcr.io/ldgabbay/cake_wallet CW_DOCKER_USE_CLOUD=true make`
  pulls the native library stages this fork's CI built instead of compiling
  them, which saves the hours. It only helps while those images match the
  commit you're on, and with `CW_DOCKER_USE_CLOUD=true` a stage that does need
  building is then pushed, which fails unless you're logged in to that
  registry.

## Other builds

`docs/builds/` covers Cake's own instructions for the other platforms and for
the cakewallet flavor.
