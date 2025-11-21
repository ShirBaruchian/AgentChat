# iOS Setup Guide - Simulator & Physical Device

This guide covers setting up and running the Flutter app on both iOS Simulator and physical iPhone devices, including solutions to common build issues.

## Prerequisites

1. **macOS** with Xcode installed
2. **Flutter SDK** installed and configured
3. **CocoaPods** installed (`sudo gem install cocoapods`)
4. **Xcode Command Line Tools** (`xcode-select --install`)

## Part 1: iOS Simulator Setup

### Step 1: List Available Simulators

```bash
xcrun simctl list devices available
```

This will show all available simulators. Note the device ID (UUID) of the simulator you want to use.

### Step 2: Boot the Simulator

If the simulator is not running, boot it:

```bash
xcrun simctl boot <DEVICE_ID>
```

For example:
```bash
xcrun simctl boot 78C0C39A-AE2F-4996-AD03-A6595F34C49B
```

### Step 3: Open Simulator App (Optional)

```bash
open -a Simulator
```

### Step 4: Run Flutter App

```bash
cd mobile
flutter run -d <DEVICE_ID>
```

Or use the device name:
```bash
flutter run -d "iPhone 16 Pro"
```

### Troubleshooting Simulator Issues

**Issue: "No devices found" or "Device not found"**

**Solution:**
1. List all devices: `flutter devices`
2. Boot the simulator: `xcrun simctl boot <DEVICE_ID>`
3. If the device ID is stale, use the device name instead: `flutter run -d "iPhone 16 Pro"`

**Issue: "Xcode build failed due to concurrent builds"**

**Solution:**
```bash
cd mobile
flutter clean
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter run
```

## Part 2: Physical iPhone Setup

### Step 1: Connect Your iPhone

1. Connect your iPhone to your Mac via USB cable
2. Unlock your iPhone and trust the computer if prompted
3. Ensure your iPhone is in Developer Mode (Settings > Privacy & Security > Developer Mode)

### Step 2: Check Device Connection

```bash
flutter devices
```

You should see your iPhone listed. Note the device ID.

### Step 3: Configure Code Signing

1. Open the project in Xcode:
   ```bash
   cd mobile/ios
   open Runner.xcworkspace
   ```
   **⚠️ IMPORTANT: Always open `Runner.xcworkspace`, NOT `Runner.xcodeproj`**

2. In Xcode:
   - Select the **Runner** project in the left sidebar
   - Select the **Runner** target
   - Go to **Signing & Capabilities** tab
   - Check **"Automatically manage signing"**
   - Select your **Team** (your Apple Developer account)
   - Xcode will automatically configure the provisioning profile

### Step 4: Set Bundle Identifier (if needed)

If you get signing errors, you may need to change the bundle identifier:
- In Xcode, go to **Signing & Capabilities**
- Change **Bundle Identifier** to something unique (e.g., `com.yourname.agentChat`)

### Step 5: Run on Physical Device

```bash
cd mobile
flutter run -d <DEVICE_ID>
```

Or use the device name:
```bash
flutter run -d "iPhone"
```

### Troubleshooting Physical Device Issues

**Issue: "No devices found" (wireless device shown but not connecting)**

**Solution:**
1. Ensure your iPhone is connected via USB
2. Trust the computer on your iPhone
3. Check if Developer Mode is enabled on iOS 16+
4. Try: `flutter devices` to see if device appears

**Issue: Code Signing Errors**

**Solution:**
1. Open `Runner.xcworkspace` in Xcode
2. Go to Signing & Capabilities
3. Select your Team
4. Ensure "Automatically manage signing" is checked
5. If errors persist, try changing the Bundle Identifier

**Issue: "Failed to launch app" or "Could not find Developer Disk Image"**

**Solution:**
1. Update Xcode to the latest version
2. Update iOS on your iPhone to match Xcode's supported versions
3. Run: `xcode-select --switch /Applications/Xcode.app/Contents/Developer`

## Part 3: Common Build Issues & Solutions

### Issue 1: Firebase/gRPC Template Parsing Error

**Error:** `Parse Issue: A template argument list is expected after a name prefixed by the template keyword`

**Solution:**
Update Firebase packages to the latest versions in `pubspec.yaml`:
```yaml
firebase_core: ^4.2.1
firebase_auth: ^6.1.2
cloud_firestore: ^6.1.0
firebase_messaging: ^16.0.4
firebase_analytics: ^12.0.4
firebase_core_web: ^3.3.0
```

Then:
```bash
cd mobile
flutter pub get
cd ios
rm -rf Pods Podfile.lock
pod install
```

### Issue 2: Abseil Undefined Symbols

**Error:** Multiple `Undefined symbol: absl::lts_...` errors

**Solution:**
This is fixed by using the latest Firebase SDK (version 12.4.0+) which includes updated gRPC and Abseil versions. Follow the solution for Issue 1.

### Issue 3: Module Not Found Errors

**Error:** `Module 'cloud_firestore' not found` or similar

**Solution:**
1. Ensure you're opening `Runner.xcworkspace` (not `.xcodeproj`)
2. Clean and reinstall pods:
   ```bash
   cd mobile/ios
   rm -rf Pods Podfile.lock
   pod install
   ```
3. Clean Flutter build:
   ```bash
   cd mobile
   flutter clean
   flutter pub get
   ```

### Issue 4: CocoaPods Encoding Error

**Error:** `Unicode Normalization not appropriate for ASCII-8BIT`

**Solution:**
```bash
export LANG=en_US.UTF-8
cd mobile/ios
pod install
```

Or add to your `~/.zshrc` or `~/.bash_profile`:
```bash
export LANG=en_US.UTF-8
```

## Part 4: Complete Clean Setup (When All Else Fails)

If you're experiencing persistent issues, perform a complete clean setup:

```bash
# 1. Clean Flutter
cd mobile
flutter clean

# 2. Clean iOS build artifacts
cd ios
rm -rf Pods Podfile.lock
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# 3. Get Flutter dependencies
cd ..
flutter pub get

# 4. Reinstall pods
cd ios
export LANG=en_US.UTF-8
pod install

# 5. Boot simulator (if using simulator)
xcrun simctl boot <DEVICE_ID>
open -a Simulator

# 6. Run the app
cd ..
flutter run -d <DEVICE_ID>
```

## Part 5: Podfile Configuration

The current `Podfile` is configured with:
- **Static frameworks** (`use_frameworks! :linkage => :static`) - Fixes Abseil linking issues
- **iOS 15.0** minimum deployment target
- **Automatic Flutter plugin installation**

**Important:** Do not modify the Podfile unless you understand the implications. The current configuration has been tested and works with:
- Firebase SDK 12.4.0+
- gRPC-Core 1.69.0+
- Abseil 1.20240722.0+

## Quick Reference Commands

```bash
# List available devices
flutter devices

# List simulators
xcrun simctl list devices available

# Boot simulator
xcrun simctl boot <DEVICE_ID>

# Open Simulator app
open -a Simulator

# Run on device
flutter run -d <DEVICE_ID>

# Clean build
flutter clean
cd ios && rm -rf Pods Podfile.lock && pod install

# Open in Xcode (ALWAYS use .xcworkspace)
cd ios && open Runner.xcworkspace
```

## Notes

- **Always use `Runner.xcworkspace`** when opening in Xcode, never `Runner.xcodeproj`
- The `Podfile.lock` should be committed to version control for consistent builds
- Firebase SDK version 12.4.0+ includes fixes for gRPC template parsing issues
- Static frameworks are required to properly link Abseil symbols

## Support

If you encounter issues not covered in this guide:
1. Check Flutter and Xcode versions are up to date
2. Ensure all dependencies are updated (`flutter pub outdated`)
3. Review the error messages carefully - they often point to specific solutions
4. Check Firebase iOS SDK GitHub issues: https://github.com/firebase/firebase-ios-sdk/issues

