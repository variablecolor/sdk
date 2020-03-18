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

## Connecting to Color Muse / ColorMuse Pro / Spectro 1

In order to scan colors, you need to establish a BLE connection to a Color Muse, Muse Pro, or Spectro 1 device.
Color Muse, ColorMuse Pro, & Spectro 1 are all represented as instances of the `ColorInstrument` class.
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

## Scanning

Scan example

```swift
if let dev = VCFCentral.connectionManager.connectedDevice {
  dev.requestColorScan { scan, err in
    guard err == nil else {
      //handle error
      return
    }
  }
}
```
