<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

# Initializer Module

A core module responsible for initializing and coordinating various services and configurations in the Mozome Flutter application. This module follows clean architecture principles and provides a structured approach to application initialization.

## Overview

The initializer module serves as the central coordinator for bootstrapping the application, handling everything from environment configuration to service initialization. It's designed to work seamlessly with other modules while maintaining clean architecture boundaries.

## Features

### Core Initialization
- **Environment Management**: Handles different environments (development, staging, production)
- **Configuration Loading**: Manages secure configuration loading based on environment
- **Theme Management**: Initializes and manages application theming
- **Localization**: Sets up language support and localization

### Service Initialization
- **Firebase Services**: Coordinates initialization of Firebase services through the data module:
  - Analytics
  - Crashlytics
  - Remote Config
  - Cloud Messaging
  - Dynamic Links
  - Storage
- **Local Storage**: Sets up shared preferences and local storage capabilities
- **Authentication**: Initializes authentication services
- **Connectivity**: Sets up network connectivity monitoring

### Error Handling
- Comprehensive error tracking and reporting
- Integration with Firebase Crashlytics in release mode
- Structured logging system

## Getting Started

### Prerequisites
Ensure you have the following dependencies in your project:
```yaml
dependencies:
  shared:
    path: ../shared
  domain:
    path: ../domain
  data:
    path: ../data
  injectable: ^2.3.2
  get_it: ^7.6.4
```

### Installation
1. Add the initializer module to your app's `pubspec.yaml`:
```yaml
dependencies:
  initializer:
    path: ../initializer
```

2. Run `flutter pub get` to install dependencies

## Usage

### Basic Initialization
```dart
import 'package:initializer/initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize with default environment (based on build mode)
  await AppInitializer.initialize();

  runApp(MyApp());
}
```

### Custom Environment Initialization
```dart
import 'package:initializer/initializer.dart';
import 'package:shared/src/utils/environment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize with specific environment
  await AppInitializer.initialize(
    environment: Environment.staging,
  );

  runApp(MyApp());
}
```

### Using Dependency Injection
```dart
import 'package:initializer/initializer.dart';
import 'package:get_it/get_it.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appInitializer = GetIt.I<AppInitializer>();
  await appInitializer.initialize(AppType.customer);

  runApp(MyApp());
}
```

### Cleanup
```dart
void dispose() async {
  await AppInitializer.dispose();
}
```

## Architecture

The initializer module follows clean architecture principles:

```
initializer/
├── lib/
│   ├── src/
│   │   ├── app_initializer.dart     # Main initialization coordinator
│   │   └── di/
│   │       └── initializer_module.dart  # Dependency injection setup
│   └── initializer.dart             # Public API barrel file
```

### Key Components

#### AppInitializer
- Coordinates initialization across modules
- Manages initialization order and dependencies
- Handles error cases and logging

#### InitializerModule
- Provides dependency injection configuration
- Manages singleton instances
- Coordinates with other modules' DI setup

## Environment Configuration

The module supports multiple environments:

- **Development**: Local development environment
- **Staging**: Testing and QA environment
- **Production**: Live production environment

Environment can be set via:
1. Build parameters: `--dart-define=ENVIRONMENT=staging`
2. Programmatically: `AppInitializer.initialize(environment: Environment.staging)`
3. Default behavior: Based on debug/release mode

## Firebase Integration

Firebase services are initialized through the data module's `FirebaseService`, which handles:

- Messaging setup and notification handling
- Analytics configuration
- Crashlytics integration
- Remote config management
- Dynamic links setup
- Storage initialization

## Error Handling and Logging

The module provides comprehensive error handling:

```dart
try {
  await AppInitializer.initialize();
} catch (e) {
  LoggingUtils.error(
    'Failed to initialize app',
    error: e,
    tag: 'Initializer',
  );
}
```

## Best Practices

1. **Initialization Order**: Follow the recommended initialization order:
   - Core configurations
   - Local storage
   - Network services
   - Authentication
   - Other services

2. **Error Handling**: Always handle initialization errors appropriately
3. **Environment Management**: Use the correct environment for your build
4. **Cleanup**: Call dispose when shutting down the app
5. **Logging**: Use the provided logging utilities for debugging

## Contributing

1. Ensure all new features follow clean architecture principles
2. Add appropriate error handling and logging
3. Update tests for new functionality
4. Document any new features or changes
5. Follow the existing code style and patterns

## Troubleshooting

### Common Issues

1. **Initialization Failures**
   - Check environment configuration
   - Verify Firebase setup
   - Ensure all required services are available

2. **Dependency Issues**
   - Verify module dependencies
   - Check version compatibility
   - Ensure proper DI setup

3. **Environment Problems**
   - Validate environment variables
   - Check build parameters
   - Verify configuration files

## Additional Resources

- [Clean Architecture Guide](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter DI with injectable](https://pub.dev/packages/injectable)
- [Firebase Flutter Setup](https://firebase.google.com/docs/flutter/setup)
