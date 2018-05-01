#!/usr/bin/env bash

# install Android SDK & related dependencies

wget https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip -nv
mkdir android-sdk
unzip -qq sdk-tools-linux-3859397.zip -d android-sdk
export ANDROID_HOME=`pwd`/android-sdk
export PATH=`pwd`/android-sdk/tools/bin:$PATH
# silence sdkmanager warning
mkdir -p ~/.android
echo 'count=0' > ~/.android/repositories.cfg
# suppressing output of sdkmanager to keep log under 4MB (travis limit)
echo y | sdkmanager "tools" >/dev/null
echo y | sdkmanager "platform-tools" >/dev/null
echo y | sdkmanager "build-tools;27.0.3" >/dev/null
echo y | sdkmanager "platforms;android-27" >/dev/null
echo y | sdkmanager "extras;android;m2repository" >/dev/null
echo y | sdkmanager "extras;google;m2repository" >/dev/null
echo y | sdkmanager "patcher;v4" >/dev/null
sdkmanager --list
# accept Android SDK licenses
yes | sdkmanager --licenses > /dev/null
# install gradle
wget https://services.gradle.org/distributions/gradle-4.6-bin.zip -nv
unzip -qq gradle-4.6-bin.zip
export GRADLE_HOME=$PWD/gradle-4.6
export PATH=$GRADLE_HOME/bin:$PATH
gradle -v
