# Cyber Mobile App

A production-ready Flutter mobile client for the Cyber Store ecosystem, featuring automated CI/CD pipelines for Google Play Console and Apple TestFlight.

---

## 📱 Tech Stack & Infrastructure

- **Framework**: [Flutter 3.x](https://flutter.dev/) (Channel `stable`)
- **Language**: [Dart](https://dart.dev/)
- **iOS Dependency Manager**: CocoaPods
- **Android Target**: SDK 36 (Android 16 compliance)
- **CI/CD Orchestration**: GitHub Actions with reusable workflow templates (`exa31/github-workflows`)
- **Distribution**:
  - **Android**: Google Play Console (Internal Track)
  - **iOS**: Apple TestFlight via App Store Connect

---

## 🛠️ Infrastructure & CI/CD Changelog

Recent infrastructure and build configuration updates:

### 1. Android Target SDK 36 (Google Play 2026 Compliance)
- **Problem**: Google Play rejected releases due to outdated Target SDK levels (`Target SDK too low`).
- **Resolution**:
  - Updated `compileSdk` to `36` and `targetSdk` to `36` in [`android/app/build.gradle`](file:///Users/macbookair/projects/cyber/cyber-mobile/android/app/build.gradle).
  - Configured Flutter embedding v2 metadata in [`android/app/src/main/AndroidManifest.xml`](file:///Users/macbookair/projects/cyber/cyber-mobile/android/app/src/main/AndroidManifest.xml).

### 2. iOS Dependency & CocoaPods Integration
- **Problem**: Flutter Swift Package Manager (SPM) caused header search path resolution errors with native pods (e.g., `flutter_native_splash`).
- **Resolution**:
  - Disabled experimental SPM in [`pubspec.yaml`](file:///Users/macbookair/projects/cyber/cyber-mobile/pubspec.yaml) via `flutter: config: enable-swift-package-manager: false`.
  - Configured standard CocoaPods installation in both local and CI build scripts.

### 3. iOS Manual Code Signing & Keychain Automation
- **Problem**: Xcode project was configured with `Automatic` signing and `iPhone Developer` identity without team credentials, causing CI builds to fail (`No valid code signing certificates were found`).
- **Resolution**:
  - Configured `CODE_SIGN_STYLE = Manual` and `CODE_SIGN_IDENTITY = "Apple Distribution"` in [`ios/Runner.xcodeproj/project.pbxproj`](file:///Users/macbookair/projects/cyber/cyber-mobile/ios/Runner.xcodeproj/project.pbxproj) and [`ios/Flutter/Release.xcconfig`](file:///Users/macbookair/projects/cyber/cyber-mobile/ios/Flutter/Release.xcconfig).
  - Automated temporary macOS keychain creation, `.p12` decryption, and `.mobileprovision` installation in CI.
  - Dynamically extracted `Team ID`, `App ID`, and `Profile Name` from the provisioning profile.
  - Generated `ExportOptions.plist` using Python `plistlib` to ensure valid format without YAML syntax issues.

### 4. Direct `.ipa` Path for TestFlight Deployment
- **Problem**: `apple-actions/upload-testflight-build` (`xcrun altool`) fails when passed wildcard paths like `*.ipa`.
- **Resolution**: Resolved the exact generated `.ipa` path dynamically before triggering App Store Connect upload.

### 5. Automated `.env` Injection
- **Problem**: Sensitive configurations were either hardcoded or required manual `.env` file copying.
- **Resolution**: Configured GitHub Actions workflows to assemble `.env` dynamically from repository variables (`vars.*`) and secrets at build time.

---

## 🔑 Required GitHub Actions Secrets & Variables

To run the automated deployment pipelines, configure the following in **GitHub Repository Settings > Secrets and variables > Actions**:

### Repository Variables (`vars`)
| Variable | Description | Example |
| :--- | :--- | :--- |
| `BASE_URL` | Backend API Base URL | `https://api.example.com` |
| `GOOGLE_CLIENT_ID` | OAuth Client ID (Android/Web) | `89790...apps.googleusercontent.com` |
| `GOOGLE_IOS_CLIENT_ID` | OAuth Client ID (iOS) | `89790...apps.googleusercontent.com` |
| `GOOGLE_SERVER_CLIENT_ID` | OAuth Backend Server Client ID | `89790...apps.googleusercontent.com` |
| `LOKI_URL` | Loki Telemetry Log Push URL | `https://loki.example.com/loki/api/v1/push` |

### Repository Secrets (`secrets`)
| Secret Name | Platform | Description |
| :--- | :--- | :--- |
| `ANDROID_KEYSTORE_BASE64` | Android | Base64-encoded release `.jks` or `.keystore` |
| `ANDROID_KEYSTORE_PASSWORD` | Android | Keystore password |
| `ANDROID_KEY_ALIAS` | Android | Key alias name |
| `ANDROID_KEY_PASSWORD` | Android | Key password |
| `PLAY_STORE_SERVICE_ACCOUNT_JSON` | Android | Google Play Service Account JSON key |
| `APPLE_CERTIFICATE_BASE64` | iOS | Base64-encoded Apple Distribution `.p12` certificate |
| `APPLE_CERTIFICATE_PASSWORD` | iOS | Password for the `.p12` certificate |
| `APPLE_PROVISIONING_PROFILE_BASE64` | iOS | Base64-encoded `.mobileprovision` file |
| `APP_STORE_CONNECT_API_KEY_BASE64` | iOS | App Store Connect API Key (`AuthKey_XXXXX.p8`) |
| `APP_STORE_CONNECT_KEY_ID` | iOS | App Store Connect Key ID (10 alphanumeric characters) |
| `APP_STORE_CONNECT_ISSUER_ID` | iOS | App Store Connect Issuer UUID |

---

## 🚀 Getting Started Locally

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.24+)
- [Xcode](https://developer.apple.com/xcode/) (macOS only, for iOS builds)
- [Android Studio](https://developer.android.com/studio) / Android SDK (API 36)
- [CocoaPods](https://cocoapods.org/) (`sudo gem install cocoapods`)

### Setup Instructions
1. **Clone the repository**:
   ```bash
   git clone https://github.com/exa-dev-cyber-store/cyber-mobile.git
   cd cyber-mobile
   ```

2. **Configure environment variables**:
   ```bash
   cp .env.example .env
   # Edit .env with your local or staging backend endpoints
   ```

3. **Install Flutter packages & iOS Pods**:
   ```bash
   flutter pub get
   cd ios && pod install && cd ..
   ```

4. **Run the application**:
   ```bash
   # Run on connected device / emulator
   flutter run
   ```

---

## 📦 Manual Build Commands

### Android
```bash
# Build Release APK
flutter build apk --release

# Build Release App Bundle (for Google Play)
flutter build appbundle --release
```

### iOS
```bash
# Build Release iOS App Bundle
flutter build ios --release

# Build Release IPA (Requires active signing profile)
flutter build ipa --release
```

---

## 🔄 CI/CD Workflows

- **Deploy Android**: `.github/workflows/deploy-android.yml`
  - Triggered on push to `main` or via manual `workflow_dispatch`.
  - Compiles release `.aab` and uploads to Google Play Internal Track.
- **Deploy iOS**: `.github/workflows/deploy-ios.yml`
  - Triggered via manual `workflow_dispatch` (optional input: `upload_to_testflight=true`).
  - Compiles release `.ipa`, signs with Apple Distribution certificate, and uploads to TestFlight.
