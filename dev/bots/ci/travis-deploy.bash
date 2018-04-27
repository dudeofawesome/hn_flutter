#!/usr/bin/env bash

set -e

bundle install
pushd android
bundle exec fastlane deploy_play_store
popd
