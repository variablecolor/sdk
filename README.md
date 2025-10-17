# Variable Color SDK

The Variable Color SDK for Android & iOS allows you to:

- connect to color muse devices
- scan colors (data available in Lab, HSB, RGB, etc)
- sync products from Variable Cloud (including your own custom products w/ custom color definitions)
- perform color searching and matching

# Download

The downloads include the SDK along with source code demonstrating basic use.

- [Download for Android](https://github.com/variablecolor/sdk/raw/master/downloads/variable-color-android-latest.zip)
- [Download for iOS](https://github.com/variablecolor/sdk/raw/master/downloads/variable-color-ios-latest.zip)

# Documentation

Documentation can be found in the source code of the SDKs.

## Android

The android sdk comes with a complete public repository for the demo app.

- [View Android Source Code & Changes](https://bitbucket.org/variablecolor/android-variable-color-sdk-examples)
- [Android readme](docs/android-readme.md)
- [Android quickstart](docs/android-quickstart.md)

### 16 KB Page Size Requirement

On May 8th, 2025, Google announced a new requirement:

> Starting November 1st, 2025, all new apps and updates to existing apps submitted to Google Play and targeting Android 15+ devices must support 16 KB page sizes.

You can read the full announcement here: [https://android-developers.googleblog.com/2025/05/prepare-play-apps-for-devices-with-16kb-page-size.html](https://android-developers.googleblog.com/2025/05/prepare-play-apps-for-devices-with-16kb-page-size.html)

As of version 12.2.4, the Variable Color Android SDK supports this 16 KB page size requirement.

Any apps submitted to the Google Play Store starting Nov 1, 2025 must use at least version 12.2.4 of the Variable Color Android SDK.

Please note that the minimum Android SDK version has been increased from 21 to 24 in version 12.2.4 of the Variable Color Android SDK.

NOTE: Google has an option to request an extension for 16 KB page size compliance. If granted, you will not need to comply with the 16 KB page size requirement until May 31, 2026. This extension can be requested through the Google Play Store Console.

If you have any questions or implementation concerns, please do not hesitate to reach out.
You can contact our dev team directly via [dev@variableinc.com](mailto:dev@variableinc.com).

## iOS

To see some code examples and learn how to use the SDK, see the [iOS quickstart](docs/ios-quickstart.md) guide.

To view the changelog, see the [README](docs/ios-readme.md).

### Swift Package Manager

Our iOS SDK is also available to install using SPM and is available as both a full-featured version or as a core version that only offers device connectivity and related utilities.

- Full version: [https://github.com/variablecolor/variablecolor-swift](https://github.com/variablecolor/variablecolor-swift). Includes device connectivity, color utilities, and product matching.

- For the core version of our iOS SDK, which does not include any product-related functionality, use [https://github.com/variablecolor/variablecolor-swift-core](https://github.com/variablecolor/variablecolor-swift-core). Does not include product matching.
