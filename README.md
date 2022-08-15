# Experimental: Google MLKit SwiftPM Wrapper

This is experimental project for building MLKit in Swift Package Manager.

## Requirements

- iOS 14 and later
- Xcode 13.2.1 and later
- Ruby
- bundler
- CocoaPods (install via bundler)

## Getting Started

```sh
git submodule update --remote
make run
```

## Limitation

- Since pre-built MLKit binary missing `arm64` for iphonesimulator, this project enables to build in `arm64` for iphoneos and `x86_64` for iphonesimulator only.
- Only supported `Face Detection` and `Barcode Scanning` right now.

## Example

Open `Example/Example.xcworkspace` and fixing code signing to yours.
