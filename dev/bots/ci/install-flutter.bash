#!/usr/bin/env bash

# Install Flutter version specified in pubspec

git clone https://github.com/flutter/flutter.git -b beta
export FLUTTER_HOME=`pwd`/flutter
export PATH=`pwd`/flutter/bin:$PATH
pushd flutter
FLUTTER_VERSION=$(dart get-flutter-version.dart)
git checkout $FLUTTER_VERSION
popd
flutter doctor
