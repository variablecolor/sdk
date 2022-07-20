# Variable SDK Demo
This demo project shows basic usage of the VariableSDK framework.
The sdk is broken down into 2 major parts:

##### *Bluetooth Functionality*
- Various means of Bluetooth connection to a ColorInstrument (aka ColorMuse, Spectro 1, Spectro 1 Pro, Color Muse Pro, Color Muse Gen2 etc).
- Requesting color scans and calibration from a connected ColorInstrument
- Using the ConnectionManager and ColorInstrument classes

##### *Product Searching*
- Download "Products" with progress updates
- Checking for new product content
- Filter products by various key / value pairs (e.g. categories: paint, and tile)
- Search products by color from a ColorInstrument device scan
- Search products by code or text
- Cross reference products
- Browsing products
- Using the ProductSearch class to construct searches


##### Installing
* Clone in this repository, download the source to a machine, or checkout using Android Studio 3.2 or later.
```
git clone git@bitbucket.org:variablecolor/android-variable-color-sdk-examples.git
```

* When importing into android studio, ensure that you 'Import project from external model` is selected with `Gradle`.

* Before building, create a file called `variable.properties` in the project's root directory. Add
```
api_key= _your_variable_sdk_key_without_quotes
```


##### Integrating with your application

Inside of your project, add our public repository to your build's repositories.
```gradle
    repositories{
           maven{ url = "https://d31vfp4cw413ot.cloudfront.net/release" }
    }
```

Now, add the `variable-color-framework` dependency to your project.
```gradle
dependency {
    implementation 'com.variable:variable-color-framework:3.1.1'
}
```




#### Release Notes
#### 3.1.1
 - Updates the build.gradle repository url to use SSL.
 - Adds full support for Color Muse Gen 2 and Color Muse Pro devices
 - Fixes issue when filter sets could return different results when the input was the same.
 - enhances and optimizes offline searches to provide better color matching results
 - Adds matching batch to response when using online searching
 - [BREAKING CHANGE] alters onCalibrationResultListener to not pass the boolean as a result, but rather passes a nullable VariableException as the second argument to the callback. When this is null the calibration is successful.
 - Adds more serialized fields to ColorScan's serialized format
 - Upgrades retrofit2 from 2.3.0 to 2.9.0


#### 2.3.9
 - Fixes logic for requiring an auth call during initialization.

#### 2.3.8
 - Bug Fix with button click not dispatching to listeners
 - [ Critical Bug Fix ] Disconnect peripheral when error occurs during connection and initialization
 - [ Enhancement ] Searching with a text term now uses 'contains' functionality

#### 2.3.6
 - Replaces protobuf with protobuf-javalite, to avoid conflicts with firebase.
 - Upgrades realm to v10.x.y
 - Major reliability and connection bluetooth improvements
 - Adds requesting signal strength to ColorInstrument.
 - Bug fix for incorrect battery voltage and level calculation for  spectro based devices.
 - fixes pom issue, and build scripts no longer require to add implementations of t-muse to there project.

#### 2.0.1
 - Major support for Spectro One, Spectro One SCI, Color Muse Pro, and Color Muse Pro SCI.
 - Critical bug causing initialization failure without cause.
 
 
#### 1.1.0 
 - Critical bug fixed with color muse calibration failing.
 

if upgrading to 0.4.6 --> a reinstallation may be required when experiencing errors from realm.


##### Upgrading to 0.5.0
* Speed and memory improvements to the download process. (it is preferred to clear out app data, but sdk supports upgrade).
* Speed improvements to the filter selection / deselection

##### Upgrading to 0.9.1
 ***This is a minimum version to work with variable's product search***

* Deprecated import / export of product database in favor of performance increases with structure changes.
* Adds new features to search engine
   * Target Illuminant and Observer for new hardware only ( Defaults to D50 / 2° )
   * set the type of ∆E to perform (Defaults to CIE ∆E 200)
   * set the maximum acceptable ∆E between color results. (Defaults to 12.5)

  BREAKING CHANGES
  * Reinstallation is required, but is now stable and will be continously supported moving forward.
  * Colorimeter renamed to ColorInstrument
  * onSpectrumCapture method is added to OnColorCaptureListener for new hardware
  * Altered `getBatchedLabColors` to accept target illuminant and observer that are specified in ProductSearch
