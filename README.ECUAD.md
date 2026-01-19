# ECUAD OpenTabletDriver Package

Custom build and packaging of [OpenTabletDriver](https://github.com/OpenTabletDriver/OpenTabletDriver) for Example Organisation.

**ECUAD Fork**: https://github.com/example-org/OpenTabletDriver

## Quick Start

```bash
# Build and package
./build.sh 0.6.4.0

# Install locally for testing
sudo installer -pkg build/OpenTabletDriver-0.6.4.0.pkg -target /

# Deploy privacy profile
profiles install -path=OpenTabletDriver.mobileconfig

# Import to Munki
munkiimport build/OpenTabletDriver-0.6.4.0.pkg
```

## What is OpenTabletDriver?

OpenTabletDriver is an open source, cross-platform, user-mode tablet driver that provides:
- Absolute and relative cursor positioning
- Pen pressure sensitivity and bindings
- Configurable screen/tablet area mapping
- Plugin support for filters and output modes
- Support for a wide range of drawing tablets

## ECUAD Customizations

### 1. Bundle Identifier
- Changed to: `ca.ecuad.macadmin.OpenTabletDriver`
- Signed with ECUAD Developer ID certificate
- Notarized for distribution

### 2. Privacy Permissions Profile
The included `OpenTabletDriver.mobileconfig` grants required permissions:
- **Accessibility**: Required to move the cursor
- **Input Monitoring**: Required to read cursor position and send relative movements

Deploy this profile via MDM before or after application installation.

### 3. Submodule Structure
This package uses the official OpenTabletDriver repository as a git submodule, allowing:
- Easy updates from upstream
- Full source code availability
- Custom signing and packaging workflow

## Directory Structure

```
packages/OpenTabletDriver/
├── build.sh                    # ECUAD custom build script
├── build-info.yaml             # munkipkg configuration
├── CUSTOMIZATIONS.md           # This file
├── OpenTabletDriver.mobileconfig  # Privacy permissions profile
├── scripts/
│   ├── preinstall             # Cleanup before install
│   └── postinstall            # Post-install setup
├── payload/                    # Auto-generated during build
└── [submodule contents]       # Official OpenTabletDriver source
```

## Building from Source

### Prerequisites

1. **Git submodules initialized**:
   ```bash
   git submodule update --init --recursive
   ```

2. **.NET 8 SDK**:
   ```bash
   brew install dotnet@8
   ```

3. **GNU Coreutils** (for build scripts):
   ```bash
   brew install coreutils
   ```

4. **munkipkg**:
   ```bash
   brew install munkipkg
   ```

5. **ECUAD Code Signing Certificate** in `~/Library/Keychains/signing.keychain`

### Build Process

```bash
./build.sh <version>
```

The build script performs:
1. Updates git submodule to latest
2. Cleans previous build artifacts
3. Builds with .NET for macOS (osx-x64)
4. Updates bundle identifier and version
5. Signs all binaries with hardened runtime
6. Creates munkipkg package structure
7. Builds and signs installer package
8. Notarizes the package

### Build Output

- `build/OpenTabletDriver-<version>.pkg` - Signed and notarized installer package

## Deployment

### Via Munki

1. **Import the package**:
   ```bash
   munkiimport build/OpenTabletDriver-0.6.4.0.pkg
   ```

2. **Add to appropriate catalogs** (e.g., `testing`, `production`)

3. **Deploy the privacy profile** via MDM or as a separate Munki item

### Via MDM

Upload both:
- `build/OpenTabletDriver-<version>.pkg` - Application installer
- `OpenTabletDriver.mobileconfig` - Privacy permissions

## Privacy Permissions

OpenTabletDriver requires two privacy permissions to function:

### Accessibility
**Purpose**: To move the cursor based on tablet input  
**Service**: `kTCCServiceAccessibility`  
**System Setting**: Privacy & Security → Accessibility

### Input Monitoring
**Purpose**: To read current cursor position for relative mode movements  
**Service**: `kTCCServiceListenEvent`  
**System Setting**: Privacy & Security → Input Monitoring

### Granting Permissions

**Recommended (via MDM)**:
Deploy the `OpenTabletDriver.mobileconfig` profile to all machines that will use tablets.

**Manual (not recommended)**:
1. Open System Settings
2. Navigate to Privacy & Security
3. Click Accessibility, add OpenTabletDriver
4. Click Input Monitoring, add OpenTabletDriver

## Usage

After installation with proper permissions:

1. Launch **OpenTabletDriver.app** from `/Applications`
2. The daemon will start automatically in the background
3. Configure tablet settings in the GUI
4. Settings are saved to `~/.config/OpenTabletDriver/settings.json`

### Command Line Usage

```bash
# Get current settings
/Applications/OpenTabletDriver.app/Contents/MacOS/OpenTabletDriver.Console --get

# Set display area
/Applications/OpenTabletDriver.app/Contents/MacOS/OpenTabletDriver.Console \
  --set Display.Width=1920 --set Display.Height=1080
```

## Supported Tablets

OpenTabletDriver supports a wide range of tablets. See the [official supported tablets list](https://opentabletdriver.net/Tablets) for details.

Common brands:
- Wacom (Intuos, Bamboo, Cintiq, etc.)
- Huion
- XP-Pen
- Gaomon
- And many more

## Updating

### Update to New Upstream Version

```bash
cd packages/OpenTabletDriver

# Sync from upstream to ECUAD fork
git fetch upstream
git merge upstream/0.6.x
git push origin 0.6.x

# Update submodule in main repo
cd /Users/rod/DevOps/Munki
git submodule update --remote packages/OpenTabletDriver
cd packages/OpenTabletDriver
./build.sh <new_version>
```

### Rebuild Current Version

```bash
./build.sh <version>
```

## Troubleshooting

### Permission Issues
If the app cannot control the cursor:
1. Verify the privacy profile is installed: `profiles show -type configuration`
2. Check System Settings → Privacy & Security
3. Remove and re-add the app if necessary

### Tablet Not Detected
1. Check [supported tablets list](https://opentabletdriver.net/Tablets)
2. View daemon logs: `log show --predicate 'process == "OpenTabletDriver.Daemon"' --last 1h`
3. Try disconnecting and reconnecting the tablet

### Build Failures
1. Ensure .NET 8 SDK is installed: `dotnet --version`
2. Update submodule: `git submodule update --init --recursive`
3. Clean build directory: `rm -rf bin payload`

## Support

- **ECUAD Fork**: https://github.com/example-org/OpenTabletDriver
- **Upstream Issues**: https://github.com/OpenTabletDriver/OpenTabletDriver/issues
- **ECUAD Build Issues**: Contact Mac Admin team
- **Documentation**: https://opentabletdriver.net/Wiki

## License

OpenTabletDriver is licensed under the **GNU Lesser General Public License v3.0**.

See [LICENSE](LICENSE) in the submodule directory for full license text.

## References

- [OpenTabletDriver Official Site](https://opentabletdriver.net)
- [GitHub Repository](https://github.com/OpenTabletDriver/OpenTabletDriver)
- [Supported Tablets](https://opentabletdriver.net/Tablets)
- [Wiki & Troubleshooting](https://opentabletdriver.net/Wiki)
- [Discord Community](https://discord.gg/9bcMaPkVAR)
