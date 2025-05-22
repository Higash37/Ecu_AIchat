#!/bin/sh
# Flutter install & build for Vercel
set -e
curl -O https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.6-stable.tar.xz
tar xf flutter_linux_3.19.6-stable.tar.xz
export PATH="$PATH:$(pwd)/flutter/bin"
./flutter/bin/flutter --version
./flutter/bin/flutter pub get
./flutter/bin/flutter build web
