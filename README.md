# Google MLKit SwiftPM Wrapper

This is experimental project for building MLKit in Swift Package Manager.

## IMPORTANT about Donation

I need GitHub sponsor to maintain this repo due to be used git lfs with paid plan.
When I reach to the maximum quota, I'll remove artifacts from this repo.

https://github.com/d-date

## Requirements

- iOS 14 and later
- Xcode 13.2.1 and later
- Ruby
- bundler
- CocoaPods (install via bundler)
- Git-lfs

## Getting Started

```sh
git submodule update --remote
make run
```

## Note: How to install to your project
Since built binaries are very large for GitHub repo and not available in Swift PM directly, please clone this repo as submodule as your project.

```
git submodule add https://github.com/d-date/google-mlkit-swiftpm
cd google-mlkit-swiftpm && make run
```

## Limitation

- Since pre-built MLKit binary missing `arm64` for iphonesimulator, this project enables to build in `arm64` for iphoneos and `x86_64` for iphonesimulator only.
- Only supported `Face Detection` and `Barcode Scanning` right now.

## Example

Open `Example/Example.xcworkspace` and fixing code signing to yours.

