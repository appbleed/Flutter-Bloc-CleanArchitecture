# Mozome Tools Package

A specialized package containing development tools, code generators, and build utilities for the Mozome Flutter application ecosystem. This package streamlines development workflows and maintains consistency across the application.

## Overview

The tools package provides essential development utilities and automation tools:
- Environment configuration generators
- Build scripts and utilities
- Code generation tools
- Development workflow automation
- IDE configuration generators
- Asset management tools

## Package Structure

```
tools/
├── gen_env/                # Environment configuration generator
│   ├── lib/
│   │   ├── android_studio/  # Android Studio configuration
│   │   │   ├── conf_skeleton.dart
│   │   │   └── gen_android_studio.dart
│   │   ├── xcode/          # Xcode configuration
│   │   │   ├── conf_skeleton.dart
│   │   │   └── gen_xcode.dart
│   │   ├── utils.dart      # Shared utilities
│   │   └── main.dart       # Main generator script
│   └── test/               # Generator tests
│
├── scripts/               # Development scripts
│   ├── build/            # Build automation
│   │   ├── android.dart  # Android build scripts
│   │   ├── ios.dart      # iOS build scripts
│   │   ├── graphql_codegen.dart  # GraphQL code generator
│   │   └── generate_graphql.sh   # GraphQL generation script
│   ├── setup/            # Project setup scripts
│   └── test/             # Test automation
│
└── assets/              # Asset management tools
    ├── icons/          # Icon generation tools
    └── images/         # Image optimization tools
```

## Core Components

### 1. Environment Generator (`gen_env/`)

The environment generator creates and manages environment-specific configurations:

```dart
// Usage example
void main() async {
  await generateEnvironment(
    app: 'customer',
    env: 'dev',
    check: true,
    verbose: true,
  );
}
```

#### Features
- Multi-environment support (dev, staging, prod)
- IDE configuration generation
- Environment validation
- Secure configuration handling

### 2. IDE Configuration

#### Android Studio Configuration
```dart
// Generate Android Studio run configurations
final androidConfig = AndroidStudioConfig(
  appName: 'CustomerApp',
  environment: Environment.development,
  flavor: 'dev',
);

await androidConfig.generate();
```

#### Xcode Configuration
```dart
// Generate Xcode schemes and configurations
final xcodeConfig = XcodeConfig(
  appName: 'CustomerApp',
  environment: Environment.development,
  configurations: ['Debug', 'Release'],
);

await xcodeConfig.generate();
```

### 3. Build Scripts (`scripts/build/`)

Automated build processes for different platforms:

```bash
# Android build
flutter run scripts/build/android.dart --flavor dev --type debug

# iOS build
flutter run scripts/build/ios.dart --scheme Development --configuration Debug
```

### 4. Asset Management (`assets/`)

Tools for managing and optimizing assets:

```dart
// Icon generation
await generateAppIcons(
  source: 'assets/icon.png',
  platforms: ['ios', 'android'],
);

// Image optimization
await optimizeImages(
  directory: 'assets/images',
  quality: 85,
);
```

### GraphQL Code Generation

The project includes automated GraphQL code generation with special handling for AWS AppSync scalar types.

#### Running Code Generation

```bash
# Generate all GraphQL code
./tools/scripts/build/generate_graphql.sh

# Or run with specific options
dart run tools/scripts/build/graphql_codegen.dart
```

#### Features

- Automated code generation for GraphQL operations
- Special handling for AWS AppSync scalar types
- Proper organization of generated files
- Integration with build process
- Support for queries, mutations, and subscriptions

#### Generated File Structure

```
data/lib/graphql/operations/
├── queries/
│   ├── generated/        # Generated query files
│   └── *.graphql        # GraphQL query definitions
├── mutations/
│   ├── generated/        # Generated mutation files
│   └── *.graphql        # GraphQL mutation definitions
└── subscriptions/
    ├── generated/        # Generated subscription files
    └── *.graphql        # GraphQL subscription definitions
```

#### AWS Scalar Type Handling

The generator handles special AWS scalar types:
- AWSJSON
- AWSDateTime
- AWSDate
- AWSTime
- AWSTimestamp
- AWSEmail
- AWSPhone
- AWSURL
- AWSIPAddress

#### Configuration

The generation process is configured in:
- `data/build.yaml`: Build configuration
- `data/codegen.yaml`: GraphQL codegen configuration
- `tools/scripts/build/graphql_codegen.dart`: Generation script

## Usage Guide

### 1. Environment Setup

```bash
# Generate environment for specific app
flutter run tools/gen_env/lib/main.dart --app customer --env dev

# Generate all environments
flutter run tools/gen_env/lib/main.dart --all
```

### 2. IDE Configuration

```bash
# Generate Android Studio configurations
flutter run tools/gen_env/lib/main.dart --ide android-studio

# Generate Xcode configurations
flutter run tools/gen_env/lib/main.dart --ide xcode
```

### 3. Build Management

```bash
# Development build
flutter run scripts/build/android.dart \
  --flavor dev \
  --type debug \
  --clean

# Production release
flutter run scripts/build/ios.dart \
  --scheme Production \
  --configuration Release \
  --archive
```

### 4. Asset Management

```bash
# Generate app icons
flutter run tools/assets/icons/generate.dart

# Optimize images
flutter run tools/assets/images/optimize.dart
```

## Configuration Files

### 1. Environment Configuration
```yaml
# env.yaml
development:
  API_URL: "https://dev-api.mozome.com"
  FIREBASE_CONFIG: "firebase_dev.json"

staging:
  API_URL: "https://staging-api.mozome.com"
  FIREBASE_CONFIG: "firebase_staging.json"

production:
  API_URL: "https://api.mozome.com"
  FIREBASE_CONFIG: "firebase_prod.json"
```

### 2. Build Configuration
```yaml
# build.yaml
android:
  flavors:
    - dev
    - prod
  buildTypes:
    - debug
    - release

ios:
  schemes:
    - Development
    - Production
  configurations:
    - Debug
    - Release
```

## Best Practices

1. **Environment Management**
   - Keep sensitive data in secure storage
   - Use environment-specific configurations
   - Validate configurations before builds

2. **Build Process**
   - Follow consistent naming conventions
   - Implement proper version management
   - Maintain build documentation

3. **Asset Management**
   - Optimize assets before commits
   - Follow naming conventions
   - Maintain asset organization

4. **Script Development**
   - Add proper error handling
   - Include logging and feedback
   - Document script usage

## Contributing

### Adding New Tools

1. Follow the established directory structure
2. Create comprehensive documentation
3. Include usage examples
4. Add tests for new functionality

### Script Guidelines

- Use consistent argument parsing
- Implement proper error handling
- Add detailed help documentation
- Include progress indicators

### Testing

```bash
# Run all tool tests
flutter test tools/test

# Test specific component
flutter test tools/gen_env/test
```

## Troubleshooting

### Common Issues

1. **Environment Generation**
   - Verify configuration files
   - Check file permissions
   - Validate environment values

2. **Build Problems**
   - Check dependency versions
   - Verify signing configurations
   - Review build logs

3. **Asset Issues**
   - Verify asset paths
   - Check file formats
   - Confirm optimization settings

## Command Reference

### Environment Generator
```bash
flutter run tools/gen_env/lib/main.dart [options]

Options:
  --app        Application name (customer, provider)
  --env        Environment (dev, staging, prod)
  --check      Validate configurations
  --verbose    Enable detailed logging
```

### Build Scripts
```bash
flutter run scripts/build/[platform].dart [options]

Android Options:
  --flavor     Build flavor (dev, prod)
  --type       Build type (debug, release)
  --clean      Clean build files

iOS Options:
  --scheme     Build scheme
  --configuration  Build configuration
  --archive    Create archive
```

## Additional Resources

- [Flutter CLI Documentation](https://docs.flutter.dev/reference/flutter-cli)
- [Xcode Build System Guide](https://developer.apple.com/documentation/xcode/building_your_app_to_run_on_a_device)
- [Android Gradle Guide](https://developer.android.com/studio/build)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## License

This project is licensed under the MIT License - see the LICENSE file for details.
