# Automation Scripts

This directory contains automation scripts for managing MLKit version updates.

## Scripts

### check_mlkit_version.rb

Checks for new MLKit versions available on CocoaPods.

**Usage:**
```bash
ruby scripts/check_mlkit_version.rb
```

**Output:**
- Current version from Podfile
- Latest version from CocoaPods
- Whether an update is available

### update_version.rb

Updates the Podfile with a new MLKit version.

**Usage:**
```bash
ruby scripts/update_version.rb <version>
```

**Example:**
```bash
ruby scripts/update_version.rb 5.1.0
```

### update_package_dependencies.rb

Updates Package.swift dependency versions to match those in Podfile.lock.

**Usage:**
```bash
ruby scripts/update_package_dependencies.rb
```

**What it does:**
- Reads dependency versions from Podfile.lock
- Updates the following dependencies in Package.swift:
  - GoogleDataTransport
  - GoogleUtilities
  - GTMSessionFetcher (gtm-session-fetcher)
  - PromisesObjC (promises)
  - nanopb (with special handling - see below)
- Verifies that nanopb tags exist before updating
- Provides clear output showing which dependencies were updated

**Special nanopb handling:**
- CocoaPods uses version `3.30910.0` for nanopb
- firebase/nanopb SwiftPM repository only has `2.30910.0` tags
- The script checks if the CocoaPods version exists in SwiftPM
- If not found, it keeps the current working version
- This is expected behavior due to different versioning schemes

**When to use:**
- After running `pod update` or `pod install`
- To ensure Package.swift dependencies match Podfile.lock
- As part of version update workflow

### update_checksums.rb

Calculates SHA256 checksums for built XCFrameworks and updates Package.swift with new checksums, release URLs, and dependency versions.

**Usage:**
```bash
ruby scripts/update_checksums.rb <version>
```

**Example:**
```bash
ruby scripts/update_checksums.rb 5.1.0
```

**What it does:**
- Calculates SHA256 checksums for all XCFramework zip files
- Updates Package.swift binary target URLs to point to the new version
- Updates Package.swift binary target checksums
- Updates dependency versions from Podfile.lock (including nanopb handling)

**Prerequisites:**
- XCFramework zip files must exist in `GoogleMLKit/` directory
- Podfile.lock must exist and be up-to-date
- Run after `make archive`

### postprocess_xcframeworks.rb

Post-processes `GoogleMLKit/*.xcframework` after `create-xcframework`. Run by
`make postprocess`; takes the directory as an optional argument.

Per XCFramework it does two things, in this order:

1. **Injects an arm64 simulator architecture** derived from the device arm64
   slice by rewriting the Mach-O platform to `PLATFORM_IOSSIMULATOR`. ML Kit
   ships no arm64 simulator code and Xcode 26 dropped Rosetta simulators, so
   without this the package cannot run in the Simulator on Apple Silicon.
   Slices that already contain arm64 are left alone.
2. **Converts bare Mach-O object binaries into `ar` archives.** Xcode treats a
   framework whose binary is an object file as dynamic, relinks it and
   dead-strips unreferenced data -- which is how `MLKitTextRecognitionCommon`
   lost its ~58MB OCR model.

### patch_macho_platform.rb

`patch_macho_platform.rb <file> <platform-number>` rewrites the `platform`
field of every `LC_BUILD_VERSION` in a thin Mach-O file or `ar` archive, in
place. Used by `postprocess_xcframeworks.rb`.

Patching in place matters: ML Kit's archives contain duplicate member names
(three `globals.o` in MLKitCommon), which cannot survive an extract/repack
round trip without turning into duplicate symbols at link time.

### test_patch_macho_platform.rb

Self-check for the hand-written `ar`/Mach-O parser above. Compiles throwaway
object files with clang, including an archive with duplicate member names, and
asserts the patch rewrites every member without changing the file layout. Run
by CI.

### check_product_closure.rb

Asserts that every `.library` product in `Package.swift` links the full
transitive framework set that pod needs according to `Podfile.lock`.

A SwiftPM product links only the targets it lists, and the Example app depends
on every product at once -- so a framework missing from one product still gets
pulled in by another and the build passes, while a consumer adopting that
single product gets undefined symbols. Run by CI, and after any product edit.

### use_local_binaries.rb

Rewrites every `.binaryTarget` in `Package.swift` to point at
`GoogleMLKit/*.xcframework` instead of a release asset, so the package can be
built before anything is published. Undo with `git checkout Package.swift`.

### verify_local_archive.sh

The pre-release gate. Repoints `Package.swift` at the local XCFrameworks,
builds the Example app for the arm64 Simulator, archives it for device, and
fails if an SDK on Apple's commonly-used list is embedded (ITMS-91065), if
anything is linked dynamically, or if the app binary is too small to still
contain the ML Kit model data. Restores `Package.swift` on exit.

### verify_build.rb

Validates that all required files and build outputs are present and correct.

**Usage:**
```bash
ruby scripts/verify_build.rb
```

**What it checks:**

- Info.plist files exist in Resources/
- xcframework-maker tool is built and executable
- XCFramework zip files exist (after build)
- Package.swift has valid syntax

**When to use:**

- Before starting a build (pre-flight check)
- After building (validation)
- When troubleshooting build issues

### verify_runtime.sh

Performs static analysis on built XCFrameworks to catch potential runtime issues.

**Usage:**
```bash
./scripts/verify_runtime.sh <version>
```

**Example:**
```bash
./scripts/verify_runtime.sh 7.0.0
```

**What it checks:**

- XCFramework architectures (arm64, x86_64)
- Info.plist presence in each framework binary
- Symbol table validity
- Package.swift target completeness

**When to use:**

- After building XCFrameworks
- Before manual device testing
- To catch obvious runtime issues early

**Note:** This does NOT replace manual testing on a real device!

### build_all.sh

Orchestrates the complete build process with validation.

**Usage:**
```bash
./scripts/build_all.sh <version>
```

**Example:**
```bash
./scripts/build_all.sh 5.1.0
```

**What it does:**

1. Runs pre-flight checks (verify_build.rb)
2. Updates Podfile and Info.plist files with the new version
3. Runs `make run` to build XCFrameworks
4. Verifies build output
5. Calculates checksums and updates Package.swift
6. Performs final verification

### batch_build.sh

Builds multiple MLKit versions sequentially with automatic git commits and tags.

**Usage:**
```bash
./scripts/batch_build.sh <version1> [version2] [version3] ...
```

**Example:**
```bash
./scripts/batch_build.sh 7.0.0 8.0.0 9.0.0
```

**What it does:**

1. Builds each version using build_all.sh
2. Creates a git commit for each successful build
3. Creates a git tag for each version
4. Reports success/failure summary at the end
5. Asks if you want to continue on failure

**When to use:**

- Building multiple versions at once
- Catching up with missed releases
- Batch processing version updates

## Testing Scripts Locally

### Test Version Check

```bash
# Should show current and latest versions
ruby scripts/check_mlkit_version.rb
```

### Test Build Process (Dry Run)

To test without actually building:

```bash
# Test Podfile update only
ruby scripts/update_version.rb 5.0.0

# Review changes
git diff Podfile

# Revert if needed
git checkout Podfile
```

### Full Local Build Test

```bash
# This will take some time and requires Xcode
./scripts/build_all.sh 5.0.0
```

## Requirements

- Ruby 3.1 or later
- Bundler
- Xcode with command line tools
- CocoaPods

## Error Handling

All scripts include error handling and will:
- Exit with status 1 on errors
- Print error messages to stdout
- Validate inputs before processing
