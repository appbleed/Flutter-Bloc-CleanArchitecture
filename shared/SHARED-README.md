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

# Mozome Shared Package

A foundational package providing shared utilities, components, and core functionality across the Mozome Flutter application ecosystem. This package serves as the backbone for common functionality, ensuring consistency and reducing code duplication.

## Overview

The shared package is a critical component of the Mozome application architecture, providing:
- Core utilities and helper functions
- Common UI components and widgets
- Theme and styling definitions
- Configuration management
- Shared interfaces and models
- Cross-cutting concerns like logging and analytics

## Package Structure

```
lib/
├── common_view/           # Common UI components and views
│   ├── dialogs/          # Reusable dialog components
│   ├── forms/            # Form components and validators
│   └── layouts/          # Layout templates and structures
│
├── locale/               # Localization and internationalization
│   ├── translations/     # Language files
│   ├── delegates/        # Custom locale delegates
│   └── helpers/          # i18n utility functions
│
├── privacy_policy_t&c/   # Legal documents and policies
│   ├── privacy_policy/   # Privacy policy components
│   └── terms/            # Terms and conditions
│
├── service/             # Shared services
│   ├── analytics/       # Analytics service
│   ├── auth/           # Authentication utilities
│   ├── storage/        # Storage service
│   └── theme_mode.dart # Theme management
│
├── theme/              # Theme and styling
│   ├── color/         # Color definitions
│   ├── typography/    # Text styles
│   └── dimensions/    # Layout dimensions
│
├── utils/             # Utility functions and helpers
│   ├── configs.dart   # Configuration utilities
│   ├── constants.dart # Global constants
│   ├── date_utils.dart # Date manipulation
│   ├── string_utils.dart # String operations
│   ├── validation_utils.dart # Input validation
│   ├── file_utils.dart # File operations
│   ├── logging_utils.dart # Logging system
│   └── network_utils.dart # Network helpers
│
└── widget/           # Reusable widgets
    ├── buttons/     # Button components
    ├── cards/       # Card layouts
    ├── inputs/      # Input fields
    └── loaders/     # Loading indicators
```

## Core Components

### 1. Common Views (`common_view/`)
Reusable UI components that maintain consistency across the app:

```dart
// Example of a common dialog
class CommonDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onConfirm;

  // Implementation...
}

// Usage
CommonDialog(
  title: 'Confirm Action',
  message: 'Are you sure?',
  onConfirm: () => handleConfirmation(),
).show(context);
```

### 2. Localization (`locale/`)
Internationalization support with easy-to-use helpers:

```dart
// Accessing translations
Text(AppLocalizations.of(context).translate('key'));

// Adding new translations
{
  "welcome_message": "Welcome to Mozome",
  "settings": "Settings"
}
```

### 3. Theme Management (`theme/`)
Comprehensive theming system:

```dart
// Color definitions
abstract class AppColors {
  static const primary = Color(0xFF007AFF);
  static const secondary = Color(0xFF5856D6);
  // ... more colors
}

// Typography
abstract class AppTypography {
  static const headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );
  // ... more styles
}
```

### 4. Utilities (`utils/`)

#### Configuration (`configs.dart`)
```dart
abstract class AppConfig {
  static bool get isDevelopment => _environment == Environment.dev;
  static bool get isStaging => _environment == Environment.staging;
  static bool get isProduction => _environment == Environment.prod;

  // Firebase configurations
  static String get firebaseApiKey => _getConfig('FIREBASE_API_KEY');
  // ... more configurations
}
```

#### Logging (`logging_utils.dart`)
```dart
abstract class LoggingUtils {
  static void info(String message, {String? tag}) {
    _log('INFO', message, tag: tag);
  }

  static void error(String message, {dynamic error, StackTrace? stackTrace, String? tag}) {
    _log('ERROR', message, error: error, stackTrace: stackTrace, tag: tag);
  }
}
```

#### Validation (`validation_utils.dart`)
```dart
abstract class ValidationUtils {
  static bool isValidEmail(String email) {
    // Email validation logic
  }

  static bool isValidPassword(String password) {
    // Password validation logic
  }
}
```

### 5. Widgets (`widget/`)
Collection of custom widgets:

```dart
// Custom button example
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonStyle style;

  // Implementation...
}

// Custom input field
class AppTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  // Implementation...
}
```

## Usage Guide

### 1. Installation

Add to your `pubspec.yaml`:
```yaml
dependencies:
  shared:
    path: ../shared
```

### 2. Basic Usage

```dart
import 'package:shared/src/utils/logging_utils.dart';
import 'package:shared/theme/app_theme.dart';
import 'package:shared/widget/buttons/app_button.dart';

class MyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Screen', style: AppTypography.headline2),
      ),
      body: Column(
        children: [
          AppButton(
            text: 'Press Me',
            onPressed: () {
              LoggingUtils.info('Button pressed', tag: 'MyScreen');
            },
          ),
          AppTextField(
            label: 'Email',
            validator: (value) => ValidationUtils.isValidEmail(value ?? '')
                ? null
                : 'Invalid email',
          ),
        ],
      ),
    );
  }
}
```

### 3. Theme Usage

```dart
// In your app's theme configuration
ThemeData buildLightTheme() {
  return ThemeData(
    primaryColor: AppColors.primary,
    textTheme: TextTheme(
      headline1: AppTypography.headline1,
      bodyText1: AppTypography.body1,
    ),
    // ... more theme configurations
  );
}
```

### 4. Utilities Usage

```dart
// Configuration
final apiKey = AppConfig.apiKey;
final isDev = AppConfig.isDevelopment;

// Logging
LoggingUtils.info('Operation successful', tag: 'MyService');
LoggingUtils.error(
  'Operation failed',
  error: e,
  stackTrace: s,
  tag: 'MyService',
);

// Validation
final isValid = ValidationUtils.isValidEmail(email);

// Date formatting
final formattedDate = DateUtils.formatDate(
  DateTime.now(),
  format: 'yyyy-MM-dd',
);
```

## Best Practices

1. **Component Usage**
   - Use shared components whenever possible
   - Maintain consistent styling using theme constants
   - Follow established patterns for new components

2. **Utility Functions**
   - Use provided utilities instead of creating new ones
   - Keep utility functions pure and testable
   - Document complex utility functions

3. **Theme Management**
   - Use theme constants instead of hard-coded values
   - Follow the design system guidelines
   - Maintain dark mode compatibility

4. **Logging**
   - Use appropriate log levels
   - Include relevant context in log messages
   - Follow the logging pattern for consistency

## Contributing

### Adding New Components

1. Follow the existing directory structure
2. Create tests for new components
3. Document usage and examples
4. Update this README when adding major features

### Code Style

- Follow Flutter/Dart style guidelines
- Use meaningful names for components and variables
- Add comments for complex logic
- Include documentation for public APIs

### Testing

Run the test suite:
```bash
flutter test
```

## Troubleshooting

### Common Issues

1. **Theme Issues**
   - Verify theme initialization
   - Check context availability
   - Confirm correct import paths

2. **Localization Problems**
   - Ensure delegate initialization
   - Verify translation key existence
   - Check context locality

3. **Widget Errors**
   - Verify required parameters
   - Check build context usage
   - Confirm proper state management

## Additional Resources

- [Flutter Style Guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Best Practices](https://docs.flutter.dev/development/best-practices)
- [Material Design Guidelines](https://material.io/design)

## License

This project is licensed under the MIT License - see the LICENSE file for details.
