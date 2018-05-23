#!/bin/sh

# Get zip of iOS SDK
git archive --remote=ssh://git@bitbucket.org/variablecolor/ios-variable-color-framework-examples.git --format=zip --output="downloads/variable-color-ios-latest.zip" master

# Get zip of Android SDK
git archive --remote=ssh://git@bitbucket.org/variablecolor/android-variable-color-sdk-examples.git --format=zip --output="downloads/variable-color-android-latest.zip" master

# Pull in docs
git archive --remote=ssh://git@bitbucket.org/variablecolor/android-variable-color-sdk-examples.git --output="docs/android-readme.md" master README.md
git archive --remote=ssh://git@bitbucket.org/variablecolor/ios-variable-color-framework-examples.git --output="docs/ios-readme.md" master README.md
git archive --remote=ssh://git@bitbucket.org/variablecolor/ios-variable-color-framework-examples.git --output="docs/ios-quickstart.md" master quickstart.md

