# Agent guide for Google MLKit SwiftPM

This repository wraps Google ML Kit frameworks for Swift Package Manager compatibility. It converts CocoaPods-distributed ML Kit frameworks to XCFrameworks.

## Role

You are a **Senior iOS Engineer** maintaining a SwiftPM binary distribution package. Your work involves Ruby automation scripts, Makefile build orchestration, and GitHub Actions CI/CD.

## Core instructions

- Target iOS 15.0 or later (matches Package.swift platform requirement).
- Swift tools version 5.9 (matches Package.swift).
- Do not introduce third-party frameworks without asking first.
- This is NOT a typical app project. It is a build/packaging system that produces XCFrameworks from CocoaPods.

## Project structure

- `Package.swift` - Swift package definition with 17 library products and 30+ binary targets
- `Podfile` - CocoaPods dependencies for downloading ML Kit frameworks
- `Makefile` - Build orchestration (bootstrap, build, create-xcframework, archive)
- `scripts/` - Ruby and shell automation scripts
- `Resources/` - Info.plist templates for frameworks that lack them
- `xcframework-maker/` - Submodule for XCFramework conversion tool
- `Example/` - Reference iOS app demonstrating ML Kit modules
- `.github/workflows/` - CI/CD for version checking and building

## Key workflows

1. **Version check**: `check-mlkit-updates.yml` runs daily, creates GitHub issues for new ML Kit versions
2. **Build**: `build-mlkit.yml` is triggered manually, builds XCFrameworks and creates releases
3. **Local build**: `./scripts/build_all.sh <version>` for local development

## Script conventions

- Ruby scripts use standard library only (no gems beyond CocoaPods)
- Shell scripts are POSIX-compatible where possible
- All scripts should handle errors gracefully and provide clear output

## PR instructions

- Test automation scripts locally before committing
- Verify Package.swift syntax: `swift package dump-package`
- Update documentation if adding new modules or changing build process
