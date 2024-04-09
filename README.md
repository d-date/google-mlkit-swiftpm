# Google MLKit SwiftPM Wrapper

This is experimental project for building MLKit in Swift Package Manager.

## Requirements

- iOS 14 and later
- Xcode 13.2.1 and later

## Installation

```swift
    .package(url: "https://github.com/d-date/google-mlkit-swiftpm", from: "3.2.1")
```

## Limitation

- Since pre-built MLKit binary missing `arm64` for iphonesimulator, this project enables to build in `arm64` for iphoneos and `x86_64` for iphonesimulator only.
- Only supported `Face Detection` and `Barcode Scanning` right now.

## Example

Open `Example/Example.xcworkspace` and fixing code signing to yours.
