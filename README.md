# ProjectHub

<div align="center">

![ProjectHub Logo](assets/images/logo/projectHub_full_logo.png)

**A modern, cross-platform project management application built with Flutter**

[![Flutter](https://img.shields.io/badge/Flutter-3.8.1+-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.8.1+-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Windows%20%7C%20Linux%20%7C%20macOS-lightgrey)](https://flutter.dev)

</div>

---

## 📋 Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Screenshots](#screenshots)
- [Getting Started](#getting-started)
- [Installation](#installation)
- [Configuration](#configuration)
- [Project Structure](#project-structure)
- [Architecture](#architecture)
- [Technologies Used](#technologies-used)
- [Contributing](#contributing)
- [License](#license)
- [Support](#support)

## 🎯 Overview

ProjectHub is a comprehensive project management solution designed to streamline team collaboration, task tracking, and project oversight. Built with Flutter, it provides a unified experience across all major platforms, enabling teams to manage projects efficiently from anywhere.

The application features dual interfaces:
- **Admin Interface**: Complete project management with team oversight, analytics, and administrative controls
- **Client Interface**: Streamlined view for team members to track tasks, projects, and collaborate

### Key Highlights

- 🚀 **Cross-Platform**: Single codebase for Android, iOS, Web, Windows, Linux, and macOS
- 🎨 **Modern UI/UX**: Beautiful Material Design 3 interface with dark/light theme support
- ⚡ **Performance**: Optimized with GetX state management for smooth, responsive interactions
- 🔒 **Secure**: Robust authentication and authorization system
- 📊 **Analytics**: Comprehensive project analytics and reporting
- 👥 **Team Management**: Complete team member management and assignment system

## ✨ Features

### Admin Features

- **Project Management**
  - Create, edit, and delete projects
  - Track project progress and status
  - Set project timelines and deadlines
  - Assign team members to projects
  - View detailed project dashboards

- **Task Management**
  - Create and assign tasks
  - Set task priorities and deadlines
  - Track task completion status
  - Filter and search tasks
  - Task comments and collaboration

- **Team Management**
  - Add and manage team members
  - View employee profiles and details
  - Assign roles and permissions
  - Track team performance

- **Analytics & Reporting**
  - Project progress analytics
  - Team performance metrics
  - Task completion statistics
  - Export reports (PDF support)

- **Assignments**
  - Create project assignments
  - Assign tasks to team members
  - Track assignment progress

### Client Features

- **Task View**
  - View assigned tasks
  - Update task status
  - Add comments and updates
  - Filter tasks by status/priority

- **Project Overview**
  - View assigned projects
  - Track project progress
  - Access project details

- **Analytics**
  - Personal performance metrics
  - Task completion statistics
  - Project contribution insights

- **Profile & Settings**
  - Manage profile information
  - Theme preferences (dark/light mode)
  - Application settings

### General Features

- **Authentication**
  - Secure login system
  - Password reset functionality
  - Email verification
  - Session management

- **User Experience**
  - Onboarding flow for new users
  - Intuitive navigation
  - Responsive design
  - Offline support (connectivity awareness)

- **Theme Support**
  - Light and dark themes
  - System theme detection
  - Customizable color schemes

## 📸 Screenshots

> Screenshots coming soon. Check back for visual previews of the application.

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.8.1 or higher)
- **Dart SDK** (3.8.1 or higher)
- **Android Studio** / **Xcode** (for mobile development)
- **VS Code** or **Android Studio** (recommended IDEs)
- **Git** for version control

### System Requirements

- **Windows**: Windows 10 or later
- **macOS**: macOS 10.14 or later
- **Linux**: Ubuntu 18.04 or later
- **Android**: Android SDK 21 or higher
- **iOS**: iOS 12.0 or higher (macOS required)

## 📦 Installation

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/junior.git
cd junior
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run the Application

```bash
# For development
flutter run

# For specific platform
flutter run -d chrome          # Web
flutter run -d windows         # Windows
flutter run -d macos           # macOS
flutter run -d linux          # Linux
```

### 4. Build for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release

# Web
flutter build web --release

# Windows
flutter build windows --release

# macOS
flutter build macos --release

# Linux
flutter build linux --release
```

For detailed setup instructions, see [SETUP.md](SETUP.md).

## ⚙️ Configuration

### Environment Setup

1. **API Configuration**: Update API endpoints in `lib/lib_admin/core/constant/api_constant.dart`
2. **Theme Customization**: Modify colors in `lib/lib_client/core/constant/color.dart`
3. **Routes**: Configure routes in `lib/lib_admin/core/constant/routes.dart`

### Platform-Specific Configuration

#### Android

- Update `android/app/build.gradle.kts` for app configuration
- Configure signing keys in `android/app/key.properties`
- Update `AndroidManifest.xml` for permissions

#### iOS

- Update `ios/Runner/Info.plist` for iOS-specific settings
- Configure signing in Xcode
- Update bundle identifier

#### Web

- Configure `web/index.html` for web-specific settings
- Update `web/manifest.json` for PWA configuration

## 📁 Project Structure

```
junior/
├── lib/
│   ├── main.dart                 # Main application entry point
│   ├── core/
│   │   └── services/            # Core services initialization
│   ├── lib_admin/                # Admin interface
│   │   ├── controller/           # Business logic controllers
│   │   │   ├── auth/            # Authentication controllers
│   │   │   ├── project/         # Project management controllers
│   │   │   ├── task/            # Task management controllers
│   │   │   ├── employee/        # Employee management controllers
│   │   │   └── assignment/      # Assignment controllers
│   │   ├── core/
│   │   │   ├── constant/        # Constants and configurations
│   │   │   ├── functions/       # Utility functions
│   │   │   ├── services/        # Service layer
│   │   │   └── middleWare/      # Route middleware
│   │   ├── data/
│   │   │   ├── Models/          # Data models
│   │   │   ├── repository/      # Data repositories
│   │   │   └── static/          # Static data
│   │   ├── routes.dart           # Route definitions
│   │   └── view/
│   │       ├── screens/         # UI screens
│   │       └── widgets/         # Reusable widgets
│   └── lib_client/               # Client interface
│       ├── controller/          # Client-side controllers
│       ├── core/                # Core client functionality
│       ├── data/                # Client data layer
│       └── view/                # Client UI
├── assets/
│   ├── images/                  # Image assets
│   └── assets/                  # Additional assets
├── android/                     # Android platform files
├── ios/                         # iOS platform files
├── web/                         # Web platform files
├── windows/                     # Windows platform files
├── linux/                       # Linux platform files
├── macos/                       # macOS platform files
├── pubspec.yaml                 # Project dependencies
└── README.md                    # This file
```

## 🏗️ Architecture

ProjectHub follows a clean architecture pattern with clear separation of concerns:

### Architecture Layers

1. **Presentation Layer** (`view/`)
   - UI screens and widgets
   - User interaction handling

2. **Controller Layer** (`controller/`)
   - Business logic
   - State management using GetX
   - Data flow coordination

3. **Data Layer** (`data/`)
   - Models and data structures
   - Repository pattern implementation
   - API communication

4. **Core Layer** (`core/`)
   - Shared utilities
   - Constants and configurations
   - Services and middleware

### State Management

The project uses **GetX** for state management, providing:
- Reactive state management
- Dependency injection
- Route management
- Theme management

## 🛠️ Technologies Used

### Core Technologies

- **Flutter** - Cross-platform UI framework
- **Dart** - Programming language
- **GetX** - State management and dependency injection

### Key Dependencies

- `get: ^4.6.6` - State management and routing
- `shared_preferences: ^2.2.2` - Local storage
- `http: ^1.1.2` - HTTP client
- `dartz: ^0.10.1` - Functional programming utilities
- `lottie: ^3.1.2` - Animations
- `font_awesome_flutter: ^10.5.0` - Icon library
- `connectivity_plus: ^5.0.2` - Network connectivity
- `timezone: ^0.9.2` - Timezone handling
- `pdf: ^3.10.7` - PDF generation
- `path_provider: ^2.1.2` - File system paths
- `share_plus: ^7.2.2` - Sharing functionality
- `permission_handler: ^11.3.1` - Permission management
- `url_launcher: ^6.2.2` - URL launching
- `open_file: ^3.3.2` - File opening
- `flutter_slidable: ^3.1.1` - Swipeable actions

### Development Tools

- `flutter_lints: ^5.0.0` - Linting rules
- `flutter_launcher_icons: ^0.13.1` - App icon generation

## 🤝 Contributing

We welcome contributions! Please read our [Contributing Guidelines](CONTRIBUTING.md) for details on:

- Code of Conduct
- Development workflow
- Pull request process
- Coding standards
- Issue reporting

See [CONTRIBUTING.md](CONTRIBUTING.md) for more information.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 💬 Support

- **Documentation**: Check [SETUP.md](SETUP.md) for detailed setup instructions
- **Issues**: Report bugs or request features via [GitHub Issues](https://github.com/yourusername/junior/issues)
- **Discussions**: Join discussions in [GitHub Discussions](https://github.com/yourusername/junior/discussions)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- GetX community for excellent state management solution
- All contributors who help improve this project

---

<div align="center">

**Made with ❤️ using Flutter**

[Report Bug](https://github.com/yourusername/junior/issues) · [Request Feature](https://github.com/yourusername/junior/issues) · [Documentation](SETUP.md)

</div>

