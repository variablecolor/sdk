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
```java
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
```java
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


### Connecting To A Color Instrument (Color Muse or Spectro 1)
In order to scan colors, you need to establish a BLE connection to a Color Instrument. A network connection is required to download device-specific information from our servers the first time you connect to a given instrument (aka Color Muse or Spectro1 device).

The connection logic is broken down into: 
-  Settings up listeners
-  Bluetooth discovery
-  Connection
-  Calibration

#### Using Connection Listeners
In order to have feedback during the connection flow, implement the methods for the `OnDiscoveryListener`,  `DeviceConnectionListener` and the `onErrorListener`:

```java
//Implements OnDiscoveryListener
    public void onDiscoveryComplete(@NonNull List<BluetoothDevice> devices) {
        if (devices.size() == 0) {
            txtStatus.setText("No Devices Found");
        }
    }

//Implements DeviceConnectionListener

@Override
public void onStateChange(int previousState, int newState) {
    switch (newState) {
        case States.DISCONNECTED:
            txtStatus.setText("Scanning");
            break;

        case States.DEVICE_CONNECTION:
            txtStatus.setText("Connecting to discovered devices");
            txtAction.setText("-");
            break;

        case States.AWAITING_CONFIRMATION:
            txtStatus.setText("Device connected");
            txtAction.setText("press button on color sensor for confirmation");
            break;

        case States.DEVICE_DISCOVERY:
            txtStatus.setText("Discovering nearby devices");
            txtAction.setText("Press button on color sensor");
            break;

        case States.FETCHING_CALIBRATION:
            txtStatus.setText("Fetching device calibration...\nPlease wait");
            txtAction.setText("-");
            break;
    }
}

//Implements onErrorListener
@Override
public void onError(@NonNull VariableException ex) {
    if(ex instanceof NetworkException){
        new AlertDialog.Builder(this)
                .setTitle("Internet Connectivity")
                .setMessage("Failed to download device information on first time connection")
                .setPositiveButton(android.R.string.ok, null)
                .show();
        txtStatus.setText("Failed downloading device information on first time connections");
    } else if(ex instanceof BluetoothDiscoveryException) {
        int androidBluetoothDiscoveryError = ((BluetoothDiscoveryException) ex).getScanError();
        Toast.makeText(this, "Bluetooth Scan Error Code: " + androidBluetoothDiscoveryError, Toast.LENGTH_LONG).show();

    } else if(ex instanceof ZeroColorimetersDiscoveredException){
        new AlertDialog.Builder(this)
                .setTitle("Missing Bluetooth Devices")
                .setMessage("Failed to find color sensors in discovery scan")
                .setPositiveButton(android.R.string.ok, null)
                .show();

    } else if(ex instanceof ButtonPressTimeoutException){
        new AlertDialog.Builder(this)
                .setTitle("Error during connection")
                .setMessage("Failed to detect a second button press for confirmation")
                .setPositiveButton(android.R.string.ok, null)
                .show();

    } else if(ex instanceof DeviceBatchException){
        new AlertDialog.Builder(this)
                .setTitle("Error during connection")
                .setMessage("Please contact manufacturer about defective hardware. Serial Number: " + ((DeviceBatchException) ex).getSerial())
                .setPositiveButton(android.R.string.ok, null)
                .show();

    } else if(ex instanceof CalibrationException){
        new AlertDialog.Builder(this)
                .setTitle("Error during connection")
                .setMessage("Please contact manufacturer about defective hardware. Serial Number: " + ((CalibrationException) ex).getSerial())
                .setPositiveButton(android.R.string.ok, null)
                .show();
    }

    btnControl.setEnabled(true);
}
```
Your implementation should update the UI as it receives these events. See the demo project for more details.

Once the connection manager reaches the `.DeviceReady` state, the device can be calibrated and then can be used to scan colors.



#### Bluetooth Discovery

Before connecting, you need to scan for BLE devices and decide what to connect to. To scan for advertising devices, implement the `OnDiscoveryListener` listener as noted above, and then start discovery using:
```java
// This will cancel any existing connection attempt in progress. Accepts a onDiscoveryListener and a onErrorListener.
sdk.getConnectionManager().discoverBluetoothDevices(this, this);
```

In the `OnDiscoveryListener`'s `onDiscoveryComplete` callback, you will get a list of devices you can sort through and display to the user. 

Devices advertise in one of two modes ( **Single Click** or **Double Click** Advertising).

- Color Muse only has regular (**Single Click**) advertising mode: click the button on the Color Muse device and it will advertise for 45 seconds. 
- The Spectro 1 device has (in addition to regular) a "double click" advertising mode, so during discovery we can scan for just devices that have been double clicked to avoid discovering extra devices.

To check for devices with **Double Click** Advertising: 
```java
@Override
    public void onDiscoveryComplete(@NonNull List<BluetoothDevice> devices) {
        for (BluetoothDevice d : devices) {
            boolean isDoubleClick;
            boolean isSingleClick;
            BlueGeckoController controller = Variable.instance().getConnectionManager().getBluetoothLEService().getBleDevice(d);
            if(controller.getAdvertisingData() != null) {
                isDoubleClick = controller.getAdvertisingData().isDoubleButtonPressAdvertising()
                isSingleClick = controller.getAdvertisingData().isSingleButtonPressAdvertising()
            }
    }
```

This will set the `onDiscoveryListener` on `connectionManager`.
You would typically display the list of peripherals to the user and allow them to select a device to connect to.



#### Bluetooth Connection
Once the user has selected the device to connect to, we call:
```
 sdk.getConnectionManager().connect(device, this, this);

```
The connect method accepts the `BluetoothDevice` to connect to, an `DeviceConnectionListener`, and an `onErrorListener`.
Once this is completed, your `DeviceConnectionListener` will recieve the `.Ready` state change, and will be ready to scan colors.


### Calibration
Color Muse and Spectro 1 have different calibration flows. 

Color Muse requires calibration before scanning, but the Spectro 1 device only needs to be calibrated once every 500~100 scans. 

```java
ColorInstrument peripheral = this.connectionManager.getConnectedPeripheral();
//Ensure peripheral is connected.
if(peripheral != null){
    peripheral.requestCalibration(ColorimeterFragment.this::onCalibrationResult);
}
```

In the case that a Spectro 1 requires calibration, calibration can be performed by scanning the white, green, and blue tiles shipped with the Spectro using the standard color scan methods (described below) and then storing those to the device using the `setCalibration` method:
```java
    getColorInstrument().setCalibrationScans(
        Arrays.asList(this.whiteTileScan, this.greenTileScan, this.blueTileScan),
        (peripheral, isSuccess) -> {
            Toast.makeText(CalibrationActivity.this, "Calibration Success", Toast.LENGTH_SHORT).show();
            clearTileScans();

        }, this::handleScanError);

```
See the demo app for further details. 

### Scanning
In order to scan, you will need to implement an `onColorCaptureListener` and an `onErrorListener`. These are accepted by `ColorInstrument.requestColorScan`.

To request a scan:
```java
// Get the colorimeter... null is no connection... possibly remote disconnection if keep alive is off.
ColorInstrument device = ((SampleApplication) getApplication()).getVariableSDK().getConnectionManager().getConnectedPeripheral();

device.requestColorScan(ColorScanningActivity.this, this);
```

The `onColorCaptureListener` is called when the scan is completed with the appropriate method: `onColorCapture` (from Color Muse) or `onSpectrumCapture` (from Spectro 1).

Using the `onColorCaptureListener` implementation, the device and the ColorScan is passed back. The adjustedLabColor should be used for display values.
```java
@Override
public void onColorCapture(@NonNull ColorInstrument colorInstrument, @NonNull ColorScan scan) {
    // Use the ColorScan and get D50 2°
    LabColor color = scan.getAdjustedLabColor(Illuminants.D50, Observer.TWO_DEGREE);

    // Use the ColorScan and get D65 2°
    LabColor d65LabColor = scan.getAdjustedLabColor(Illuminants.D65, Observer.TWO_DEGREE);

    // Use the ColorScan and get D65 10°
    LabColor d65_10 = scan.getAdjustedLabColor(Illuminants.D65, Observer.TEN_DEGREE);

    // Use the ColorScan and get D50 10°
    LabColor d50_10 = scan.getAdjustedLabColor(Illuminants.D65, Observer.TEN_DEGREE);
}

@Override
public void onSpectrumCapture(@NonNull ColorInstrument colorInstrument, @NonNull ColorScan scan) {
    LabColor color = scan.getAdjustedLabColor(mSelectedIlluminant, mSelectedObserver);
    List<SpectralPoint> intensities = scan.getSpectralCurve();
}
```


### Scanning and Searching
Shown in the section above, implement the onColorCaptureListener to make a search using the ColorScan.
```java
@Override
public void onColorCapture(@NonNull ColorInstrument colorInstrument, @NonNull ColorScan scan) {
    new ProductSearch()
        .setColorSearchTerm(scan)
        .setSkip(0)
        .setLimit(75)
        .execute(this, null);
}
```
