#!/usr/bin/env bash

set -e

bundle install --quiet

pushd android
bundle exec fastlane deploy_play_store
# TODO: get signed (derived) APK, then use it for GitHub releases
popd

dev/bots/ci/github-releases-deploy.rb
