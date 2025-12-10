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

### update_checksums.rb

Calculates SHA256 checksums for built XCFrameworks and updates Package.swift.

**Usage:**
```bash
ruby scripts/update_checksums.rb <version>
```

**Example:**
```bash
ruby scripts/update_checksums.rb 5.1.0
```

**Prerequisites:**
- XCFramework zip files must exist in `GoogleMLKit/` directory
- Run after `make archive`

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
