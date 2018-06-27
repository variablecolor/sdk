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

You can check if products need to be redownloaded (e.g. in the case they have been updated remotely) using:

```swift
VCFCentral.productManager.checkIfProductDownloadRequired { isRequired, err in
  if err != nil {
    //handle error
  } else {
    if isRequired {
      //products need to be redownloaded
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

Availble filters can be fetched using the `VCFProductFilterSet` class.

For example:

```swift
VCFProductFilterSet.filterSet() { filterSet, err in
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

## Connecting to Color Muse

In order to scan colors, you need to establish a BLE connection to a Color Muse device.
A network is required to download device-specific information from our servers the first
time you connect to a given Color Muse device.

There are two primary ways to connect: multi connect and direct connect.

**Multi connect** scans for Color Muses in the vicinity, connects to each one, then
waits for the user to confirm their device via hardware button press (on the Color Muse).

**Direct connect** connects to a single Color Muse device.
The device can be chosen from a list by the user after scanning, or could be a
previously known, connected device.

### Using multi connect

Multi connect is the preferred way to get a user connected to their Color Muse.

Start multi connect by calling `multiConnectStart` and passing it a delegate that implements the `VCFConnectionManagerDelegate` protocol.

```swift
VCFCentral.connectionManager.multiConnectStart(self)
```

Your delegate needs to implement three methods:

```swift
func onStateChanged(_ state: VConnectState, discoveredPeripherals _: UInt) {
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

func onWarning(_ error: Error) {
  // handle warning
}

func onError(_ error: Error) {
  // handle error
}
```

Your delegate should update the UI as it receives these events. See the demo
project for more details.

Once the connection manager reaches the `.DeviceReady` state, the device can be
calibrated and then can be used to scan colors.

## Using direct connect

Before connecting, you need to scan for BLE devices:

```swift
VCFCentral.connectionManager.discoverBluetoothDevices { (peripherals: [CBPeripheral]?, error: Error?) in
  guard err == nil else {
    //handle error
    return
  }

  self.discoveredPeripherals = ps
}
```

You would typically display the list of peripherals to the user and allow them to select a device
to connect to.

Before attempting a connection, set a connectionListener on connectionManager:

```swift
VCFCentral.connectionManager.connectionListener = self
```

The same delegate protocol is used for both multi connect and direct connect.

To connect to a given device, call `connect` like so:

```swift
VCFCentral.connectionManager.connect(to: p) { error in
  guard err == nil else {
    //handle error
    return
  }

  //VCFCentral.connectionManager.connectedDevice will now be set
}
```

Once this succeeds (or your delegate receives the `.DeviceReady` state change),
the device can be calibrated and then can be used to scan colors.

## Calibration

Before scanning, the device needs to be calibrated:

```swift
if let dev = VCFCentral.connectionManager.connectedDevice {
  dev.requestCalibration { _, error in
    guard err == nil else {
      //handle error
      return
    }

    //device is calibrated and ready to scan
  }
}
```

## Scanning

```swift
dev.requestColorScan { scan, err in
    guard err == nil else {
        return self.showScanError(err!)
    }

    if let scan = scan {
        self.view.backgroundColor = scan.displayColor

        let labColor = scan.adjustedLab
        let rgbColor = scan.rgbColor
        let lchColor = scan.lchColor
        let hex = scan.hex

        // do something with colors...
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
