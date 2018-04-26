#!/usr/bin/env bash

# Install Flutter version specified in pubspec

git clone https://github.com/flutter/flutter.git -b beta
export FLUTTER_HOME=`pwd`/flutter
export PATH=`pwd`/flutter/bin:$PATH
FLUTTER_VERSION=$(dart dev/bots/ci/get-flutter-version.dart)
pushd $FLUTTER_HOME
git checkout v$FLUTTER_VERSION
popd
flutter doctor
