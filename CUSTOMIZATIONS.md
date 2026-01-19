# ECUAD OpenTabletDriver Customizations

## Overview

This is a customized build of OpenTabletDriver from the [ECUAD fork](https://github.com/example-org/OpenTabletDriver) (tracking [upstream](https://github.com/OpenTabletDriver/OpenTabletDriver)) configured for Example Organisation.

## Repository Structure

This directory contains:
- **Submodule**: The official OpenTabletDriver source code (git submodule)
- **build.sh**: Custom build script for ECUAD
- **build-info.yaml**: munkipkg configuration for packaging
- **scripts/**: Pre/post-install scripts
- **payload/**: Staging area for the built application
- **OpenTabletDriver.mobileconfig**: Privacy permissions configuration profile

## Customizations

### 1. Code Signing & Notarization
- Signed with ECUAD's Developer ID Application certificate
- Notarized for distribution
- Uses ECUAD Team ID: TEAMID0000

### 2. Privacy Permissions
The app requires the following permissions on macOS:
- **Accessibility**: To move the cursor
- **Input Monitoring**: To read cursor position and send relative movements

These are automatically granted when the included mobileconfig profile is deployed.

### 3. Bundle Identifier
- **Main App**: `ca.ecuad.macadmin.OpenTabletDriver`

## Building

```bash
cd /Users/rod/DevOps/Munki/packages/OpenTabletDriver
./build.sh [version]
```

Example:
```bash
./build.sh 0.6.4.0
```

This will:
1. Pull the latest source code from the submodule
2. Build the .NET application for macOS
3. Code sign the binaries with hardened runtime
4. Create a munkipkg package
5. Sign the installer package
6. Notarize the package

## Installation

```bash
sudo installer -pkg build/OpenTabletDriver-<version>.pkg -target /
```

Or import into Munki:
```bash
munkiimport build/OpenTabletDriver-<version>.pkg
```

## Privacy Profile Deployment

Deploy the `OpenTabletDriver.mobileconfig` profile to grant required permissions:
- Via MDM (MicroMDM, Jamf, etc.)
- Via Profiles command: `profiles install -path=OpenTabletDriver.mobileconfig`

## Support & Issues

- **ECUAD Fork**: https://github.com/example-org/OpenTabletDriver
- **Upstream Issues**: https://github.com/OpenTabletDriver/OpenTabletDriver/issues
- **ECUAD Customization Issues**: Contact Mac Admin team

## License

OpenTabletDriver is licensed under the GNU Lesser General Public License v3.0.
See [LICENSE](LICENSE) in the submodule directory for details.
