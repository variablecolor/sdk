# Variable Color SDK - Getting Started

## Initializing the SDK

The SDK must be initialized before using.

```swift
VCFCentral.initWith("YOUR_SDK_KEY", delegate: self)
```

The `VCFCentralDelegate` has a single function that is called once the SDK is ready to use.

```swift
func onInit(_ err: Error?) {
      guard err == nil else {
          //SDK init failed
      }

      //SDK init success
  }
```

## Downloading Products

Before products can be used (searched / browsed), they must be downloaded and saved locally.
NOTE: Inspirations are not included in the products download. Inspirations will only operate online.
If you ONLY want to use inspirations, you can skip downloading the products.

To download products, call this function and pass an instance of `VCFProductDownloaderDelegate`.

```swift
VCFCentral.productManager.downloadProducts(with: self)
```

The delegate has three functions that must be implemented:

```swift
func productDownloaderDidUpdateProgress(_ progress: Float) {
  //called with progress of download (0-1)
}

func productDownloaderDidComplete() {
  //called when download has finished
}

func productDownloaderDidFailWithError(_ error: Error!) {
  //called when downloader fails
}
```

You can check if products need to be downloaded again (e.g. in the case they have been updated remotely) using:

```swift
VCFCentral.productManager.checkIfProductDownloadRequired { isRequired, err in
  if err != nil {
    //handle error
  } else {
    if isRequired {
      //products need to be fetched
    } else {
      //products are up to date
    }
  }
}
```

## Browsing & searching products

Products can be fetched using the `VCFProductSearch` class.

The following fetches all products:

```swift
let search = VCFProductSearch()

// skip and limit are used for paging
search.skip = 0
search.limit = 1000

search.execute { results, err in
  if err != nil {
    //handle error
  }

  //use search results
}
```

Results are returned as an array of `VCFProductSearchResult` objects, which has two members: `deltaE` which will contain the ∆E between the target color and the matched product when performing a color search, and `product` which will be a pointer to the matched product.

### Filtering

Products can be filtered by populating the `filters` property of a `VCFProductSearch` object.

For example:

```swift
let search = VCFProductSearch()
let filterset = VCFProductFilterSet(selectedFilters: [
  VCFProductKV(key: "vendor", val: "Behr"),
  VCFProductKV(key: "vendor", val: "Sherwin-Williams"),
])

search.filters = filterset.selectedFilters

//execute search
```

As seen in the above example, filters are key-value pairs typically created using the `VCFProductKV` class.

This is typically done by fetching all available filters and then allowing the user to select some combination of these filters. This is shown in the demo app (see `FiltersViewController.swift`).

Available filters can be fetched using the `VCFProductSearch` class.

For example:

```swift
VCFProductSearch.fetchProductFilters { filters, _ in
   guard err == nil else {
    //handle error
    return
  }

  // work with filter set
}
```

The `VCFProductFilterSet` class provides several convenience methods for selecting & deselecting filters.
Available filters are automatically updated when selecting / deselecting filters.

```swift
let filterKV = filters.availableFilter(at: indexPath)

filters.selectFilter(filterKV) { _, _ in
  self.filtersTableView.reloadData()
}

filters.deselectFilter(filterKV) { _, _ in
  self.filtersTableView.reloadData()
}

filters.toggleFilter(filterKV) { _, _ in
  self.filtersTableView.reloadData()
}
```

### Sorting

Search results (when not searching using a color search term) can be sorted by various terms. To get the list of possible sort keys, call

```swift
let sortKeys = VCFProductSearch.validSortKeys()
//Returns ["sortOrder", "name", "code", "hue", ...]
```

The sort order on a search can be set using:

```swift
search.sortKey = "hue"
search.sortAscending = true
```

### Searching using color

To search using color, set the `colorTerm` property on an instance of `VCFProductSearch`.

For example:

```swift
let myColor = VCFRGBColor(r: 0.3, withG: 0.75, withB: 0.5, in: .sRGB)
search.colorTerm = myColor

//execute search
```

### Using search results

Search results come back as arrays of objects w/ a `product` member that implements the `VCFProduct` interface.

When displaying products in a UI, you will usually want to show a color / image and
a few product details.

The `VCFProduct` interface gives you access to the product's colors, images, attributes, and filters.

Here is an example that configures a UITableViewCell to display a product:

```swift
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "basic-product-cell", for: indexPath) as! ProductTableViewCell

    let sr = searchResults[indexPath.row]
    if let product = sr.product {
        cell.label1.text = product.code
        cell.label2.text = product.name
        cell.label3.text = String(format: "%@ - %@", product.vendor, product.collection)
        cell.previewView.backgroundColor = product.displayColor

        if let imageURL = product.images.first {
            cell.previewView.kf.setImage(with: imageURL)
        } else {
            cell.previewView.image = nil
        }
    }

    if let deltaE = sr.deltaE {
        cell.label4.text = String(format: "%0.2f ∆E", deltaE.floatValue)
    } else {
        cell.label4.text = ""
    }

    return cell
}
```

## Inspirations

**NOTE**: all inspiration searches are performed online and thus a network connection is required.

Browsing & searching inspirations is nearly identical to browsing & searching with products.
The only differences are how you instantiate the search class and how you fetch the initial filter set.

To do an inspirations search, use `VCFProductSearch.inspirations()` to instantiate the
VCFProductSearch class (rather than `VCFProductSearch()` as you would for products).

For example:

```swift
let search = VCFProductSearch.inspirations()
search.execute { results, err in
  guard err == nil else {
    return
  }

  self.searchResults = results
  self.productsTable.reloadData()
}
```

If you want to filter inspirations (e.g. by room) do it the same way you would for products,
but load the initial filter set using
`VCFProductSearch.fetchInspirationFilters()`

For example:

```swift
VCFProductSearch.fetchInspirationFilters { filters, _ in
  self.filters = filters
  self.filtersTableView.reloadData()
}
```



## Connecting to Color Muse / ColorMuse Pro / Spectro 1

In order to scan colors, you need to establish a BLE connection to a Color Muse, Muse Pro, or Spectro 1 device.
Color Muse, ColorMuse Pro,  & Spectro 1 are all represented as instances of the `ColorInstrument` class. 
A network is required to download device-specific information from our servers the first
time you connect to a given `ColorInstrument`.

### General Connection Flow
Connecting to a `ColorInstrument` is invoked via the SDK's connection manager.

The (Direct) Connection Manager provides methods for performing Bluetooth discovery, connection, etc. 
The demo app uses the Connection Manager to scan for bluetooth devices, provide the user a list of visible devices to select from, and connect to the device selected by the user.


### Status & Feedback from the Connection Manager

To monitor the connection state / check for errors - your code should implement the `VCFConnectionManagerDelegate` methods:

The listener will provide feedback via three delegate methods:

```swift
func connectionManagerDidUpdate(_ state: VConnectState) {
  switch state {
    case .Disconnected:
      break
    case .ScanningForDevices:
      break
    case .ConnectingToDevices:
      break
    case .AwaitingConfirmation:
      break
    case .GettingCalibration:
      break
    case .DeviceReady:
      break
  }
}

func connectionManagerDidDiscoverPeripherals(_ peripherals: [VPeripheralWRSSI]!) {
  // called every time the connection manager discovers a new peripheral
  // NOTE: all discovered peripherals are returned
}

func connectionManagerDidError(_ error: Error) {
  // handle error
}
```


## Implementing the connection flow

Before doing anything, set a delegate on the ConnectionManager:

```swift
VCFCentral.connectionManager.delegate = self
```

Before connecting, you need to scan for BLE devices.

The `startDiscovery` method allows you to scan for a Color Muse / Muse Pro / Spectro 1. 
Spectro 1 & ColorMuse Pro have a special "double click" advertising mode. In order to scan for just Spectro 1 & Muse Pro devices that have been double clicked, pass a `VCFDiscoveryOptions` instance to this method with `ignoreSingleClickAdvertising` set to `true`.

```swift
VCFCentral.connectionManager.startDiscovery(with: VCFDiscoveryOptions.default())
```

As devices are discovered, the `connectionManagerDidDiscoverPeripherals(_ peripherals: [VPeripheralWRSSI]!)` 
delegate function will be invoked.

`VPeripheralWRSSI` is a container class, instances containing a CBPeripheral & RSSI level (typically ranging from -90 up to -50).

You would typically display the list of peripherals to the user and allow them to select a device
to connect to (refer to the demo project's `DirectConnectViewController.swift`).

To connect to a given device, call stop discovery and connect like so:

```swift
VCFCentral.connectionManager.stopDiscovery()

// p is a CBPeripheral instance
VCFCentral.connectionManager.connectToPeripheral(with: p.identifier)
}
```

You will be notified of connection progress via the `connectionManagerDidUpdate(_ state: VConnectState)` delegate method.

Once the `DeviceReady` state has been reached, the device can be calibrated and be used to scan colors.

If you already know the UUID of the peripheral to which you wish to connect (e.g. from a previous connection), you can skip the discovery process.

## Calibration

Calibration for Spectro 1, ColorMuse Pro, & Colro Muse is all different. 
Color Muse requires setting calibration on every connection, whereas Spectro 1 and ColorMuse Pro will require calibration every 500~1000 scans. 

You can check if calibration is required using the `ColorInstrument.isCalibrated()` method. 

If the device needs to be calibrated, you need to perform a calibration scan and then send that scan to the SDK. 

The basic flow is as follows (note that `setCalibration` accepts an array, since the Spectro 1 requires 3 tiles to be scanned to calibrate (whereas MusePro and Muse only require on scan). See the demo code for more details):

```swift
dev.requestCalibrationScan { (calScan:VCFColorScan?, error:Error?) in
    guard let cs = calScan, error == nil else {
      //handle error
      return
    }
    dev.setCalibration([cs], complete: { (setCalError:Error?) in
      if let err = setCalError{
        //handle error
        return
      }
      //device is calibrated and ready to scan
    })
  }
```  


## Scanning

Call `requestColorScan` on the `VCFColorInstrument` class to request a color scan.
Values can be retrieved in a variety of formats.

```swift
 dev.requestColorScan { scan, _, err in
  guard err == nil else {
      return self.showScanError(err!)
  }

  if let scan = scan {
    self.view.backgroundColor = scan.displayColor

    // Lab color - 10 deg. observer, D50 illuminant
    let d50Lab10Deg = scan.lab(.tenDeg, illum: .D50)

    // Lab color - 10 deg. observer, D65 illuminant
    let d65Lab10Deg = scan.lab(.tenDeg, illum: .D65)

    // Lab color - 2 deg. observer, D50 illuminant
    let d50Lab2Deg = scan.lab(.twoDeg, illum: .D50)

    // Lab color - 2 deg. observer, D65 illuminant
    let d65Lab2Deg = scan.lab(.twoDeg, illum: .D65)

    // RGB color
    let rgbColor = scan.rgbColor

    // hex color
    let hex = scan.hex

    // LCH color
    let lchColor = scan.lchColor

    // Spectrum (if hardware is a Spectro 1, etc)
    if let curve = scan.spectralCurve{
      //display spectral curve on graph
    }
  }
}
```

## Scanning and searching

Usually, you will want to scan and then perform a color search:

```swift
if let dev = VCFCentral.connectionManager.connectedDevice {
  dev.requestColorScan { scan, err in
    guard err == nil else {
      //handle error
      return
    }

    let search = VCFProductSearch()
    search.colorTerm = scan!

    search.execute { results, err in
      guard err == nil else {
        //handle error
        return
      }

      //do something with results...
    }
  }
}
```
