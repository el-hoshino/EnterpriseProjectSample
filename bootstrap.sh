#!/bin/sh

# setup Gems, Brews and Mints
echo "Install Gems and Brews"
bundle install
brew bundle
mint bootstrap

# install dependencies via CocoaPods
echo "Install dependencies via CocoaPods"
pod install

# install dependencies via Carthage
echo "Install dependencies via Carthage"
carthage bootstrap --no-use-binaries --cache-builds --platform ios

echo "Enjoy!"

open EnterpriseProjectSample.xcworkspace
