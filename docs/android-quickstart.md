# Variable Color SDK - Getting Start

### Initialization
Before any calls are made into the sdk, please initialize a `Variable` object.

The onErrorListener and OnVariableColorInitializeListener are references are not held onto by our sdk.

For more context, view InitializationActivity
```java

    // build the configuration object.
    Configuration config = new Configuration.Builder(getApplicationContext())

            // Api key is defined inside a variable.properties file.
            // This can be customized to however your application wants to pull the api key provided to you.
            .setDeveloperToken(BuildConfig.API_KEY)
            .create();

    Variable.initialize(config, Variable.OnVariableColorInitializeListener.this, variableException -> {
           // handle an exception on initialization. This can occur for a few reasons
           //  - no internet on first initialization
           //  - invalid api key
    });
```


### Downloading Products
Before products can be used (searched / browsed / search filters ), they must be downloaded and saved locally.

To download products, call this function and pass an instanceof `Products.DownloadListener`.

For more examples, view the ProductDownloadActivity
```java
@Override
public void onProgress(int percent) {
   ...
}

@Override
public void onComplete(boolean isSuccess) {
    ...
}


// Move this logic into a dialog or another activity for simplicity
((SampleApplication) getApplication()).getVariableSDK().getProductManager().download(
        ProductManager.DownloadListener.this,
        variableException -> {
            Toast.makeText(ProductDownloadActivity.this, "error while downloading", Toast.LENGTH_LONG).show();
        }
);
```


You can check if products need to be redownloaded (e.g. in the case they have been updated remotely) using:
```java
 boolean isDownloadRequired = (((SampleApplication) getApplication()).getVariableSDK().getProductManager().isDownloadRequired());
```

### Browsing & searching products
The following can fetch the first 25 products using `ProductSearch` with limit and skip:
```
 new ProductSearch()
    .setSkip(0)
    .setLimit(25)
    .execute( OnSearchCompleteListener.this, OnErrorListener.this )
```


#### Filtering
Product searches accept SearchFilters as means to filter product sets.
```

//Add a search filter
new ProductSearch()
    .setSkip(0)
    .setLimit(25)
    .addSearchFilter(new SearchFilter(...))
    .execute( OnSearchCompleteListener.this, OnErrorListener.this )

//Setting a collection of search filters from a SearchFilterSet reference...
new ProductSearch()
    .setSkip(0)
    .setLimit(25)
    .setSearchFilters(searchFilterSet.getSelectedFilters())
    .execute( OnSearchCompleteListener.this, OnErrorListener.this )
```
As seen in the above example, filters are key-value pairs typically created using the SearchFilter class.

This is typically done by fetching all available filters and then allowing the user to select some combination of these filters. This is shown in the demo app (see SearchFilterSelectionFragment.java).

Availble filters can be fetched using the SearchFilterSet class.

```java
OnSearchFilterFetchListener listener = new OnSearchFilterFetchListener() {

        @UiThread
        @Override
        public void onFilterFetch(@Nullable SearchFilterSet filters) {
            // demonstrates how to add a filter.
            listener.add("vendor", "Behr", listener);

            // demonstrates how to remove a filter.
            listener.remove("vendor", "Behr", listener);

            Collection<SearchFilter> availableFilters = filters.getAvailableFilters();
            Collection<SearchFilter> searchFilters = filters.getSelectedFilters();
        }
};

SearchFilterSet searchFilterSet = new SearchFilterSet()
searchFilterSet.initialize(listener);

```

#### Inspiration Filters
When available, the optional `isInspiration` flag can be set on SearchFilterSet.
```java
OnSearchFilterFetchListener listener = new OnSearchFilterFetchListener() {

        @UiThread
        @Override
        public void onFilterFetch(@Nullable SearchFilterSet filters) {
            // demonstrates how to add a filter.
            // listener.add("vendor", "Houzz", myAddListener);

            // demonstrates how to remove a filter.
            //listener.remove("vendor", "Houzz", onItemrRemovedAndUpdatedListener);

            Collection<SearchFilter> availableFilters = filters.getAvailableFilters();
            Collection<SearchFilter> searchFilters = filters.getSelectedFilters();
        }
};

SearchFilterSet searchFilterSet = new SearchFilterSet().isInspirationsFilterSet(true)
searchFilterSet.initialize(listener);
```


#### Sorting
All non color product searches can be sorted by a set of sortable keys. Valid keys are found at (ProductSearch.allSortKeys).
Sort keys have importance. This importance is placed on the insertion order while using a LinkedHashMap.
```
Map<String, Boolean> sorts = new LinkedHashMap<>();

// sort by name in ascending order first
sorts.add("name", true);

//on duplicates sort by code by descending order
sorts.add("code", false);


new ProductSearch()
    .setSkip(0)
    .setLimit(25)
    .setSortOrder(sorts)
    .execute(OnSearchFilterListener.this, null);
```



#### Search using Color
Searching by color, is as easy as setting the `setColorSearchTerm` on a ProductSearch. A ColorSearchTerm can be represented by one of the following: a color scan, a product, or your own implementation of the ColorSearchTerm interace.
The ManualEnteredColorSearchTerm implements the ColorSearchTerm interface and allows you to enter your own Lab values, or randomly generate your own.

For example:
```
//Randomly generates a LAB color.
ColorSearchTerm term = ManualEnteredColorSearchTerm.randomize();

new ProductSearch()
        .setColorSearchTerm(term)
        .execute(OnSearchCompleteListener, null);
```


### Connecting To Color Muse
In order to scan colors, you need to establish a BLE connection to a Color Muse device. A network is required to download device-specific information from our servers the first time you connect to a given Color Muse device.


#### Direct Connect
Direct connect establishes communication to a single Color Muse device. The device can be chosen from a list by the user after scanning, or could be a previously known, connected device.

Before connecting, you need to scan for BLE devices:
```
// This will cancel any existing connection attempt in progress. Accepts a onDiscoveryListener and a onErrorListener.
sdk.getConnectionManager().discoverBluetoothDevices(this, this);
```

This will set the onDiscoveryListener on connectionManager.
You would typically display the list of peripherals to the user and allow them to select a device to connect to.
Once the user has selected the device to connect to, we call:
```
 sdk.getConnectionManager().connect(device, this, this);

```
The connect method accepts the BluetoothDevice to connect to, an DeviceConnectionListener, and an onErrorListener.

Once this is completed, your DeviceConnectionListener will recieve the .Ready state change, and will be ready to scan colors.

### Calibration
Before scanning, the device needs to be calibrated:

```
Colorimeter peripheral = this.connectionManager.getConnectedPeripheral();
//Ensure peripheral is connected.
if(peripheral != null){
    peripheral.requestCalibration(ColorimeterFragment.this::onCalibrationResult);
}
```

### Scanning
In order to scan, you will need to implement an onColorCaptureListener and an onErrorListener. These are accepted by Colorimeter.requestColorScan.

To request a scan:

```
// Get the colorimeter... null is no connection... possibly remote disconnection if keep alive is off.
Colorimeter colorimeter = ((SampleApplication) getApplication()).getVariableSDK().getConnectionManager().getConnectedPeripheral();

colorimeter.requestColorScan(ColorScanningActivity.this, this);
```

The onColorCaptureListener is called when the scan is completed.

Using the onColorCaptureListener implementation, the device and the ColorScan is passed back. The adjustedLabColor should be used for display values.
```
@Override
public void onColorCapture(@NonNull Colorimeter colorimeter, @NonNull ColorScan scan) {
    // Use the ColorScan and get D50 2°
    LabColor color = scan.getAdjustedLabColor(Illuminants.D50, Observer.TWO_DEGREE);

    // Use the ColorScan and get D65 2°
    LabColor d65LabColor = scan.getAdjustedLabColor(Illuminants.D65, Observer.TWO_DEGREE);

    // Use the ColorScan and get D65 10°
    LabColor d65_10 = scan.getAdjustedLabColor(Illuminants.D65, Observer.TEN_DEGREE);

    // Use the ColorScan and get D50 10°
    LabColor d50_10 = scan.getAdjustedLabColor(Illuminants.D65, Observer.TEN_DEGREE);
}
```


### Scanning and Searching
Shown in the section above, implement the onColorCaptureListener to make a search using the ColorScan.
```
@Override
public void onColorCapture(@NonNull Colorimeter colorimeter, @NonNull ColorScan scan) {
    new ProductSearch()
        .setColorSearchTerm(scan)
        .setSkip(0)
        .setLimit(75)
        .execute(this, null);
}
```
