#!/bin/bash

if [[ $TRAVIS_OS_NAME == 'osx' ]]; then
    xcodebuild $ACTION -project Polyline.xcodeproj -scheme "$SCHEME" -destination "$DESTINATION" ONLY_ACTIVE_ARCH=NO
    swift build
    swift test
fi

if [[ $TRAVIS_OS_NAME == 'linux' ]]; then
      eval "$(curl -sL https://swiftenv.fuller.li/install.sh)"
      swift build
fi
