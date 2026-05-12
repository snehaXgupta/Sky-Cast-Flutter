#!/bin/bash

# Clone Flutter
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"

# Get dependencies and build
flutter pub get
flutter build web --release
