# Variable SDK Demo
This demo project shows basic usage of the VariableSDK framework.
The sdk is broken into to major parts:

##### *Bluetooth Functionality*
- Various means of Bluetooth connection to a ColorMuse (or other Variable Colorimeter device).
- Requesting color scans and calibration from a connected Colorimeter
- Using the ConnectionManager and Colorimeter classes

##### *Product Searching*
- Download "Products" with progress updates
- Checking for new product content
- Filter products by various key /value pairs (categories/brands/etc)
- Search products by color from a Color Muse device scan
- Search products by code/text
- Cross reference products
- Browsing products
- Using the ProductSearch class to construct searches


##### Installing
* Clone in this repository, download the source to a machine, or checkout using Android Studio 3.2 or later.
```
git clone git@bitbucket.org:variablecolor/android-sdk-examples.git
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
    implementation 'com.variable:variable-color-framework:0.4.5'
}
```


