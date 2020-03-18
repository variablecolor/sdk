#!/bin/sh

# Get zip of iOS SDK
git archive --remote=ssh://git@bitbucket.org/variablecolor/ios-variable-color-framework-examples.git --format=zip --output="downloads/variable-color-ios-latest.zip" basics-only

# Pull in docs
git archive --remote=ssh://git@bitbucket.org/variablecolor/ios-variable-color-framework-examples.git basics-only README.md | tar -xO > docs/ios-readme.md
git archive --remote=ssh://git@bitbucket.org/variablecolor/ios-variable-color-framework-examples.git basics-only quickstart.md | tar -xO > docs/ios-quickstart.md

