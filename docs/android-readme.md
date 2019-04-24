# Variable SDK Demo
This demo project shows basic usage of the VariableSDK framework.
The sdk is broken into to major parts:

##### *Bluetooth Functionality*
- Various means of Bluetooth connection to a ColorInstrument (aka ColorMuse or other Variable color device).
- Requesting color scans and calibration from a connected ColorInstrument
- Using the ConnectionManager and ColorInstrument classes

##### *Product Searching*
- Download "Products" with progress updates
- Checking for new product content
- Filter products by various key /value pairs (categories/brands/etc)
- Search products by color from a ColorInstrument device scan
- Search products by code/text
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
        maven { url = "http://variable-android.s3-website-us-east-1.amazonaws.com/release" }
    }
```

Now, add the `variable-color-framework` dependency to your project.
```gradle
dependency {
    implementation 'com.variable:variable-color-framework:0.9.1'
}
```




#### Release Notes

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
