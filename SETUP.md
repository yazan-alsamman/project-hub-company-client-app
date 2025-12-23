# ProjectHub Setup Guide

This comprehensive guide will help you set up ProjectHub on your local development environment across all supported platforms.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation Steps](#installation-steps)
- [Platform-Specific Setup](#platform-specific-setup)
- [Configuration](#configuration)
- [Running the Application](#running-the-application)
- [Building for Production](#building-for-production)
- [Troubleshooting](#troubleshooting)
- [Development Tools](#development-tools)

## Prerequisites

### Required Software

1. **Flutter SDK** (3.8.1 or higher)
   - Download from [flutter.dev](https://flutter.dev/docs/get-started/install)
   - Verify installation: `flutter --version`

2. **Dart SDK** (3.8.1 or higher)
   - Included with Flutter SDK
   - Verify installation: `dart --version`

3. **Git**
   - Download from [git-scm.com](https://git-scm.com/downloads)
   - Verify installation: `git --version`

### Platform-Specific Requirements

#### Windows
- Windows 10 or later (64-bit)
- Visual Studio 2019 or later (with C++ desktop development workload)
- Android Studio (for Android development)
- Windows SDK

#### macOS
- macOS 10.14 (Mojave) or later
- Xcode 12 or later (for iOS development)
- CocoaPods: `sudo gem install cocoapods`
- Android Studio (for Android development)

#### Linux
- Ubuntu 18.04 or later (or equivalent)
- Required packages:
  ```bash
  sudo apt-get update
  sudo apt-get install -y curl git unzip xz-utils zip libglu1-mesa
  ```
- Android Studio (for Android development)

## Installation Steps

### Step 1: Clone the Repository

```bash
# Clone the repository
git clone https://github.com/yourusername/junior.git

# Navigate to project directory
cd junior
```

### Step 2: Verify Flutter Installation

```bash
# Check Flutter installation
flutter doctor

# This should show all platforms as available
# Fix any issues reported by flutter doctor
```

**Common Issues:**
- Missing Android SDK: Install Android Studio and configure SDK
- Missing Xcode: Install Xcode from App Store (macOS only)
- Missing VS Code extensions: Install Flutter and Dart extensions

### Step 3: Install Dependencies

```bash
# Get all Flutter dependencies
flutter pub get

# This will download all packages specified in pubspec.yaml
```

### Step 4: Verify Setup

```bash
# Run Flutter analyzer
flutter analyze

# Run tests (if available)
flutter test

# Check for available devices
flutter devices
```

## Platform-Specific Setup

### Android Setup

#### 1. Install Android Studio

- Download from [developer.android.com/studio](https://developer.android.com/studio)
- Install Android SDK (API level 21 or higher)
- Install Android SDK Platform-Tools
- Install Android Emulator (optional, for testing)

#### 2. Configure Android SDK

```bash
# Set Android SDK path (Linux/macOS)
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Windows: Add to System Environment Variables
# ANDROID_HOME = C:\Users\YourUsername\AppData\Local\Android\Sdk
```

#### 3. Accept Android Licenses

```bash
flutter doctor --android-licenses
```

#### 4. Create Android Emulator (Optional)

1. Open Android Studio
2. Go to Tools > Device Manager
3. Click "Create Device"
4. Select a device (e.g., Pixel 5)
5. Download a system image (e.g., API 33)
6. Finish setup

### iOS Setup (macOS Only)

#### 1. Install Xcode

- Download from Mac App Store
- Install Command Line Tools:
  ```bash
  xcode-select --install
  ```

#### 2. Install CocoaPods

```bash
sudo gem install cocoapods
```

#### 3. Setup iOS Simulator

```bash
# List available simulators
xcrun simctl list devices

# Open Simulator
open -a Simulator
```

#### 4. Install Pods

```bash
cd ios
pod install
cd ..
```

### Web Setup

#### 1. Enable Web Support

```bash
flutter config --enable-web
```

#### 2. Install Chrome (Recommended)

- Download Chrome browser for testing
- Flutter web apps run best in Chrome

### Windows Setup

#### 1. Install Visual Studio

- Download Visual Studio 2019 or later
- Install "Desktop development with C++" workload
- Install Windows 10 SDK

#### 2. Enable Windows Support

```bash
flutter config --enable-windows-desktop
```

### Linux Setup

#### 1. Install Required Packages

```bash
sudo apt-get update
sudo apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    clang \
    cmake \
    ninja-build \
    pkg-config \
    libgtk-3-dev
```

#### 2. Enable Linux Support

```bash
flutter config --enable-linux-desktop
```

### macOS Desktop Setup

#### 1. Enable macOS Support

```bash
flutter config --enable-macos-desktop
```

## Configuration

### Environment Variables

Create a `.env` file in the root directory (if needed):

```env
# API Configuration
API_BASE_URL=https://api.example.com
API_KEY=your_api_key_here

# Feature Flags
ENABLE_ANALYTICS=true
ENABLE_PUSH_NOTIFICATIONS=false
```

### API Configuration

Update API endpoints in `lib/lib_admin/core/constant/api_constant.dart`:

```dart
class ApiConstant {
  static const String baseUrl = 'https://your-api-url.com';
  static const String login = '/auth/login';
  // ... other endpoints
}
```

### Theme Configuration

Customize colors in `lib/lib_client/core/constant/color.dart`:

```dart
class AppColor {
  static const Color primaryColor = Color(0xFF2563EB);
  static const Color secondaryColor = Color(0xFF10B981);
  // ... other colors
}
```

### App Icons

Configure app icons in `pubspec.yaml`:

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path: "assets/images/logo/projectHub_icon.png"
```

Generate icons:

```bash
flutter pub run flutter_launcher_icons
```

## Running the Application

### Development Mode

```bash
# Run on default device
flutter run

# Run on specific device
flutter run -d chrome          # Web
flutter run -d windows         # Windows
flutter run -d macos           # macOS
flutter run -d linux          # Linux
flutter run -d <device-id>     # Specific device

# Run in release mode
flutter run --release

# Run with hot reload enabled (default)
# Press 'r' to hot reload
# Press 'R' to hot restart
# Press 'q' to quit
```

### Debug Mode

```bash
# Run in debug mode (default)
flutter run --debug

# Enable verbose logging
flutter run -v
```

### Profile Mode

```bash
# Run in profile mode (for performance testing)
flutter run --profile
```

## Building for Production

### Android

#### Build APK

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# Split APKs by ABI (smaller file size)
flutter build apk --split-per-abi --release
```

#### Build App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

#### Signing Configuration

1. Create keystore:
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 \
     -alias upload
   ```

2. Create `android/key.properties`:
   ```properties
   storePassword=<password>
   keyPassword=<password>
   keyAlias=upload
   storeFile=<path-to-keystore>
   ```

3. Update `android/app/build.gradle.kts` to use signing config

### iOS

#### Build for Device

```bash
# Build iOS app
flutter build ios --release

# Open in Xcode for further configuration
open ios/Runner.xcworkspace
```

#### App Store Distribution

1. Open `ios/Runner.xcworkspace` in Xcode
2. Configure signing and capabilities
3. Archive the app: Product > Archive
4. Distribute to App Store

### Web

```bash
# Build for web
flutter build web --release

# Output will be in build/web/
# Deploy to any web server
```

### Windows

```bash
# Build Windows executable
flutter build windows --release

# Output will be in build/windows/runner/Release/
```

### Linux

```bash
# Build Linux application
flutter build linux --release

# Output will be in build/linux/x64/release/bundle/
```

### macOS

```bash
# Build macOS application
flutter build macos --release

# Output will be in build/macos/Build/Products/Release/
```

## Troubleshooting

### Common Issues

#### Issue: Flutter doctor shows errors

**Solution:**
```bash
# Run flutter doctor for detailed information
flutter doctor -v

# Fix Android licenses
flutter doctor --android-licenses

# Update Flutter
flutter upgrade
```

#### Issue: Dependencies not installing

**Solution:**
```bash
# Clean and reinstall
flutter clean
flutter pub get

# Clear pub cache
flutter pub cache repair
```

#### Issue: Build failures

**Solution:**
```bash
# Clean build
flutter clean
flutter pub get

# Rebuild
flutter build <platform>
```

#### Issue: iOS build fails (macOS)

**Solution:**
```bash
# Update pods
cd ios
pod deintegrate
pod install
cd ..

# Clean and rebuild
flutter clean
flutter pub get
flutter build ios
```

#### Issue: Android build fails

**Solution:**
```bash
# Check Android SDK path
echo $ANDROID_HOME

# Update Gradle
cd android
./gradlew wrapper --gradle-version=8.0
cd ..

# Clean and rebuild
flutter clean
flutter pub get
flutter build apk
```

#### Issue: Web build fails

**Solution:**
```bash
# Enable web support
flutter config --enable-web

# Clear web cache
flutter clean
flutter pub get
flutter build web
```

### Getting Help

- Check [Flutter Documentation](https://flutter.dev/docs)
- Search [Stack Overflow](https://stackoverflow.com/questions/tagged/flutter)
- Check [GitHub Issues](https://github.com/yourusername/junior/issues)
- Review [Flutter Troubleshooting Guide](https://flutter.dev/docs/get-started/install)

## Development Tools

### Recommended IDE Setup

#### VS Code

1. Install extensions:
   - Flutter
   - Dart
   - Flutter Widget Snippets

2. Configure settings:
   ```json
   {
     "dart.lineLength": 80,
     "editor.formatOnSave": true,
     "dart.enableSdkFormatter": true
   }
   ```

#### Android Studio

1. Install Flutter and Dart plugins
2. Configure Flutter SDK path
3. Enable format on save

### Useful Commands

```bash
# Format code
flutter format lib/

# Analyze code
flutter analyze

# Run tests
flutter test

# Generate code (if using code generation)
flutter pub run build_runner build

# Check for outdated packages
flutter pub outdated

# Upgrade packages
flutter pub upgrade
```

### Debugging

```bash
# Run with debugging enabled
flutter run --debug

# Attach debugger in VS Code/Android Studio
# Set breakpoints in your code
# Use Flutter DevTools for performance profiling
```

## Next Steps

After setup:

1. Read [README.md](README.md) for project overview
2. Review [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines
3. Check [CHANGELOG.md](CHANGELOG.md) for recent changes
4. Explore the codebase structure
5. Start developing!

## Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [GetX Documentation](https://pub.dev/packages/get)
- [Material Design Guidelines](https://material.io/design)

---

Happy coding! 🚀

