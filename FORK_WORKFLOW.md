# OpenTabletDriver Fork Workflow

## Repository Structure

```
ECUAD Fork:    github.com/example-org/OpenTabletDriver
Upstream:      github.com/OpenTabletDriver/OpenTabletDriver
Branch:        0.6.x
```

## Remote Configuration

Inside the submodule (`packages/OpenTabletDriver`):

```bash
origin    → https://github.com/example-org/OpenTabletDriver
upstream  → https://github.com/OpenTabletDriver/OpenTabletDriver
```

## Sync from Upstream

```bash
cd packages/OpenTabletDriver

# Fetch latest from upstream
git fetch upstream

# Merge upstream changes into ECUAD fork
git checkout 0.6.x
git merge upstream/0.6.x

# Push to ECUAD fork
git push origin 0.6.x
```

## Making ECUAD-Specific Changes

### Changes to the App (in submodule)

```bash
cd packages/OpenTabletDriver

# Make changes to source files
# Commit to ECUAD fork
git add .
git commit -m "ECUAD: Your change description"
git push origin 0.6.x
```

### Changes to Build/Package Files (outside submodule)

```bash
cd /Users/rod/DevOps/Munki/packages/OpenTabletDriver

# Edit files like build.sh, build-info.yaml, scripts/*, etc.
# These are NOT in the submodule

# Stage from main repo
cd /Users/rod/DevOps/Munki
git add packages/OpenTabletDriver/build.sh
git commit -m "Update OpenTabletDriver build script"
```

## Update Submodule Pointer

After pushing changes to the ECUAD fork:

```bash
cd /Users/rod/DevOps/Munki
git submodule update --remote packages/OpenTabletDriver
git add packages/OpenTabletDriver
git commit -m "Update OpenTabletDriver submodule"
```

## Files Tracked Where

### In ECUAD Fork (submodule):
- All OpenTabletDriver source code
- .NET project files
- Official build scripts (eng/bash/*)

### In Main Munki Repo:
- `build.sh` - ECUAD custom build script
- `build-info.yaml` - munkipkg config
- `scripts/preinstall` - Pre-install script
- `scripts/postinstall` - Post-install script  
- `OpenTabletDriver.mobileconfig` - Privacy profile
- `CUSTOMIZATIONS.md` - ECUAD docs
- `README.ECUAD.md` - ECUAD docs
- `payload/` - Build output directory

## Complete Build Workflow

```bash
# 1. Sync from upstream (optional)
cd packages/OpenTabletDriver
git fetch upstream
git merge upstream/0.6.x
git push origin 0.6.x

# 2. Build package
./build.sh 0.6.4.0

# 3. Test
sudo installer -pkg build/OpenTabletDriver-0.6.4.0.pkg -target /
profiles install -path=OpenTabletDriver.mobileconfig

# 4. Import to Munki
munkiimport build/OpenTabletDriver-0.6.4.0.pkg
```
