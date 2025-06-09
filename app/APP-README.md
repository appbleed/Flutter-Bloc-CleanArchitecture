# Mozome Customer App

A Flutter application built using Clean Architecture principles for the Mozome platform's customer-facing mobile application.

## Overview

The customer app is designed to provide a seamless experience for users to:
- Browse and book services
- Manage appointments and bookings
- Track service provider locations
- Handle payments and transactions
- Manage user profiles and preferences
- Receive real-time notifications

## Architecture

This app follows Clean Architecture principles and is part of a monorepo structure:

```
app/
├── lib/
│   ├── core/                  # Core utilities and configurations
│   │   ├── config/           # App configuration
│   │   ├── theme/            # UI theme and styling
│   │   ├── router/          # Navigation routing
│   │   └── utils/           # Shared utilities
│   ├── ui/                  # UI Layer
│   │   ├── pages/           # Screen implementations
│   │   ├── widgets/         # Reusable widgets
│   │   └── blocs/           # Business Logic Components
│   ├── di/                  # Dependency injection
│   │   └── injection.dart
│   └── main.dart            # Application entry point
├── test/                    # Unit and widget tests
└── integration_test/        # Integration tests
```

## Features

### 1. Authentication
- Social login integration (Google, Apple)
- Phone number verification
- Profile management
- Session handling

### 2. Service Booking
- Service category browsing
- Provider search and filtering
- Booking management
- Real-time availability checking
- Location-based provider matching

### 3. Payments
- Multiple payment method support
- Transaction history
- Receipt generation
- Refund handling

### 4. Real-time Features
- Live tracking of service providers
- Instant messaging
- Push notifications
- Status updates

### 5. User Experience
- Offline support
- Dark/Light theme
- Localization
- Accessibility features

## Implementation Details

### 1. State Management
```dart
/// Example BLoC pattern implementation for booking flow
@injectable
class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final IBookingRepository _bookingRepository;
  final ILocationRepository _locationRepository;

  BookingBloc(
    this._bookingRepository,
    this._locationRepository,
  ) : super(BookingInitial()) {
    on<LoadAvailableSlots>(_onLoadAvailableSlots);
    on<CreateBooking>(_onCreateBooking);
    on<CancelBooking>(_onCancelBooking);
  }

  Future<void> _onLoadAvailableSlots(
    LoadAvailableSlots event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());

    final result = await _bookingRepository.getAvailableSlots(
      serviceId: event.serviceId,
      date: event.date,
    );

    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (slots) => emit(AvailableSlotsLoaded(slots)),
    );
  }
}
```

### 2. Navigation
```dart
@MaterialAutoRouter(
  replaceInRouteName: 'Page,Route',
  routes: <AutoRoute>[
    AutoRoute(page: SplashPage, initial: true),
    AutoRoute(
      page: HomePage,
      children: [
        AutoRoute(page: ServicesPage),
        AutoRoute(page: BookingsPage),
        AutoRoute(page: ProfilePage),
      ],
    ),
    AutoRoute(page: ServiceDetailsPage),
    AutoRoute(page: BookingConfirmationPage),
    AutoRoute(page: PaymentPage),
  ],
)
class $AppRouter {}
```

### 3. Theme Configuration
```dart
class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    textTheme: AppTextStyles.textTheme,
    // Custom theme configurations
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    textTheme: AppTextStyles.textTheme,
    // Dark theme configurations
  );
}
```

### 4. Dependency Injection
```dart
@module
abstract class AppModule {
  @singleton
  GraphQLClient get graphQLClient => GraphQLClient(
    link: AuthLink(
      getToken: () => getIt<AuthRepository>().getAccessToken(),
    ).concat(HttpLink(Environment.apiUrl)),
    cache: GraphQLCache(),
  );

  @singleton
  SharedPreferences get prefs => throw UnimplementedError();

  @singleton
  FirebaseMessaging get firebaseMessaging => FirebaseMessaging.instance;
}

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies() => getIt.init();
```

## Testing

### 1. Unit Tests
```dart
void main() {
  group('BookingBloc', () {
    late BookingBloc bloc;
    late MockBookingRepository mockBookingRepository;
    late MockLocationRepository mockLocationRepository;

    setUp(() {
      mockBookingRepository = MockBookingRepository();
      mockLocationRepository = MockLocationRepository();
      bloc = BookingBloc(
        mockBookingRepository,
        mockLocationRepository,
      );
    });

    blocTest<BookingBloc, BookingState>(
      'emits [BookingLoading, AvailableSlotsLoaded] when LoadAvailableSlots is added',
      build: () => bloc,
      act: (bloc) => bloc.add(LoadAvailableSlots(
        serviceId: '1',
        date: DateTime.now(),
      )),
      expect: () => [
        BookingLoading(),
        isA<AvailableSlotsLoaded>(),
      ],
    );
  });
}
```

### 2. Widget Tests
```dart
void main() {
  group('ServiceCard', () {
    testWidgets('displays service information correctly', (tester) async {
      final service = Service(
        id: '1',
        name: 'Test Service',
        price: 100.0,
        rating: 4.5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ServiceCard(service: service),
        ),
      );

      expect(find.text('Test Service'), findsOneWidget);
      expect(find.text('\$100.0'), findsOneWidget);
      expect(find.text('4.5'), findsOneWidget);
    });
  });
}
```

## Getting Started

1. **Setup Environment**
```bash
# Install dependencies
flutter pub get

# Generate code
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

2. **Environment Configuration**
Create a `.env` file in the root directory:
```
API_URL=https://api.mozome.com/graphql
STRIPE_PUBLISHABLE_KEY=pk_test_...
GOOGLE_MAPS_API_KEY=...
```

3. **Firebase Setup**
- Add `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
- Configure Firebase in the respective platform folders

## Best Practices

1. **Code Style**
- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use meaningful naming conventions
- Document public APIs
- Keep files focused and maintainable

2. **Performance**
- Implement proper caching strategies
- Use lazy loading where appropriate
- Optimize image loading and processing
- Implement pagination for lists

3. **Security**
- Secure storage for sensitive data
- API key protection
- Input validation
- Proper error handling

4. **Accessibility**
- Semantic labels for widgets
- Proper contrast ratios
- Support for screen readers
- Scalable text

## Contributing

1. Follow the established project structure
2. Write tests for new features
3. Update documentation
4. Follow the git workflow
5. Submit detailed PR descriptions

## Resources

- [Flutter Documentation](https://docs.flutter.dev)
- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [BLoC Pattern](https://bloclibrary.dev)
- [Material Design](https://material.io/design)
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
