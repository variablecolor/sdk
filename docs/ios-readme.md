# Variable Color Demo

This demo project demonstrates basic use of the Variable Color framework.

The demo shows how to:

* Connect to a ColorMuse (or other Variable Colorimeter device) to make color scans.
* Download "Products" ie various searchable color content like paint swatches accessable by the SDK key in use
* Filter products by various categories/brands/etc
* Search products by color from a Color Muse device scan
* Search products by code/text

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

SDK developer key is required to use any functionality in the Variable Color Framework.  
If you don't have an SDK key, contact Variable, Inc - or your company's account manager to Variable in to get this key.

### Installing

Clone the variable-color-demo project from bitbucket via:  
`git clone git@bitbucket.org:variablecolor/variable-color-framework-demo.git`

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

* Simulator - Can be used for testing product browsing / filtering / and searching by text
* Physical iOS Device - required for testing any color scanning and related product searching due to BLE requirements.

_As Apple stopped supporting simulator+Bluetooth Low Energy support, you must use a physical device for anything related to BLE._

## Built With

* [Realm](https://realm.io/docs/objc/latest/) - Required by Variable SDK for storing internal data.
* [Kingfisher](https://github.com/onevcat/Kingfisher) - Used for image caching in the demo project (not required by SDK).

## Integrating with your own app

The VariableSDK framework and required Realm framework can be copied from the demo project into yoru own project

## Changelog

### v1.1.2
* Adds color convenience methods on `VCFColorScan`

### v1.1.1
* Adds paging (skip, limit) to `VCFProductSearch`
* Adds `hasCalibration` property to `VCFColorimeter`


## Contributing

When contributing to this repository, please first discuss the change you wish to make via issue, email, or any other method with the owners of this repository before making a change.

## Authors

* **Andrew Temple** - _Initial work_
* **Wade Gasior** - _Initial work_

## License

This project is available for use only under signed agreement with Variable, Inc.
