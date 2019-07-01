# Variable Color Demo

This demo project demonstrates basic use of the Variable Color framework.

The demo shows how to:

- Connect to a `ColorInstrument` (ie: a ColorMuse or Spectro 1 device) to make color scans.
- Download "Products" ie various searchable color content like paint swatches accessable by the SDK key in use
- Filter products by various categories/brands/etc
- Search products by color from a `ColorInstrument` device scan
- Search products by code/text

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

SDK developer key is required to use any functionality in the Variable Color Framework.  
If you don't have an SDK key, contact Variable, Inc - or your company's account manager to Variable in to get this key.

### Installing

Download and extract the variable-color-demo project from bitbucket via the [iOS download link](https://bitbucket.org/variablecolor/sdk/raw/master/downloads/variable-color-ios-latest.zip) on the [Variable Color SDK site](https://bitbucket.org/variablecolor/sdk).


### Testing & Running the Demo App

In `MainViewController.swift` - update the init line with the SDK key received from Variable, Inc.  
(If you don't have a key, contact Variable, Inc - or your company's account manager to Variable in to get this key).

To verify your key works, run the project on the simulator.  
If the main screen loads and updates from  
`variable color framework demo (SDK key required to proceed)`  
to  
`variable color framework demo`  
then your key is functional.

### Simulator vs physical iOS Device

- Simulator - Can be used for testing product browsing / filtering / and searching by text
- Physical iOS Device - required for testing any color scanning and related product searching due to BLE requirements.

_As Apple stopped supporting simulator+Bluetooth Low Energy support, you must use a physical device for anything related to BLE._

## Built With

- [Realm](https://realm.io/docs/objc/latest/) - Required by Variable SDK for storing internal data.
- [ZipArchive](https://github.com/ZipArchive/ZipArchive) - Used for zip file manipulation
- [Kingfisher](https://github.com/onevcat/Kingfisher) - Used for image caching in the demo project (not required by SDK. Added to the demo using [Carthage](https://github.com/Carthage/Carthage)).
- [ScrollableGraphView](https://github.com/philackm/ScrollableGraphView) - Used for spectral graphs in the demo project (not required by SDK. Added to the demo using [Carthage](https://github.com/Carthage/Carthage)).

## Integrating with your own app

The VariableSDK framework and required Realm framework can be copied from the demo project into yoru own project

## Changelog

### v8.4.41

- direct connection manager callbacks have been removed; this class now uses the delegate pattern only


### v8.0.9

- versioning updated to line up with external apps
- requestColorScan callback reverted to single ColorScan response
- connection logic simplified to just direct connect
- Calibration for Color Muse requires 1 scan of the calibration cap. 
- Calibration for Spectro 1 requires scanning the 3 tiles provided with Spectro 1 (white, green, & blue)
- Calibration related SDK interface changed to be more flexible:
  - Use 
        ```
        dev.requestCalibrationScan { (calScan:VCFColorScan?, error:Error?) in })
        ```
to perform a calibration scan, and then 
  - Use
        ```
        dev.setCalibration(calScanArray, complete: { (error:Error?) in })
        ```  to set the calibration on the device.

### v2.1.1

- inspirations are now online only
- requestColorScan callback has changed (an additional parameter was added for spectro scans)

### v2.1.0

- inspirations are now online only
- requestColorScan callback has changed (an additional parameter was added for spectro scans)

### v2.0.2

- bug fixes for text search

### v2.0.0

- product download speed has been greatly reduced; as a side effect, the underlying database and product models have been slightly altered; product images are now represented using a class rather than just a list of URLs
- any existing product database

### v1.6.3

- added method on `VCFProductSearch` that allows checking for access to Inspirations

### v1.6.2

- product database fixed to support multiple subscriptions / themes

### v1.6.0

- load method on `VCFProductFilterSet` has been deprecated. Please use `fetchProductFilters` or `fetchInspirationFilters` from `VCFProductSearch`.

### v1.5.0

- Filter interface changed to support inspirations and products as two distinct filter sets.

### v1.4.0

- Product download code improved (reduced memory use)
- Improved filter set functionality

### v1.3.0

- `filterPredicate` property of `VCFProductSearch` removed. Replaced with `filters`.
  Typically, you should use the `selectedFilters` property of a `VCFProductFilterSet` to populate this.

### v1.2.0

- VCFProductSearch executeOfflineSearch function renamed to execute
- VCFOfflineProduct renamed to VCFVariableCloudProduct

### v1.1.2

- Adds color convenience methods on `VCFColorScan`

### v1.1.1

- Adds paging (skip, limit) to `VCFProductSearch`
- Adds `hasCalibration` property to `VCFColorimeter`

## Contributing

When contributing to this repository, please first discuss the change you wish to make via issue, email, or any other method with the owners of this repository before making a change.

## Authors

- **Andrew Temple** - _Initial work_
- **Wade Gasior** - _Initial work_

## License

This project is available for use only under signed agreement with Variable, Inc.
