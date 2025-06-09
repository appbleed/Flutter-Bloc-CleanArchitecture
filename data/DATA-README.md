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

# Data Layer

The data layer implements the repository contracts defined in the domain layer and handles all data operations. This layer is responsible for coordinating data from different sources (remote API, local database, cache) and mapping between data models and domain entities.

## Overview

The data layer provides:
- Repository implementations
- Data models (DTOs)
- Data sources (Remote/Local)
- Data mapping logic
- GraphQL operations
- Network handling

## Structure

```
data/
├── lib/
│   ├── core/                  # Data layer utilities
│   │   ├── network/          # Network handling
│   │   │   ├── network_info.dart
│   │   │   └── api_client.dart
│   │   └── error/            # Error handling
│   │       └── exceptions.dart
│   ├── data/                 # Data implementation
│   │   ├── models/          # Data transfer objects
│   │   │   ├── user_model.dart
│   │   │   └── ...
│   │   ├── repositories/    # Repository implementations
│   │   │   ├── user_repository_impl.dart
│   │   │   └── ...
│   │   └── datasources/    # Data providers
│   │       ├── remote/
│   │       │   ├── user_remote_datasource.dart
│   │       │   └── ...
│   │       └── local/
│   │           ├── user_local_datasource.dart
│   │           └── ...
│   ├── di/                  # Dependency injection
│   │   ├── injection.dart
│   │   └── injection.config.dart
│   └── graphql/             # GraphQL specific code
│       ├── operations/      # GraphQL operations
│       │   ├── mutations/
│       │   └── queries/
│       └── generated/       # Generated GraphQL code
└── test/                    # Unit tests
```

## Core Components

### 1. Data Models

Data Transfer Objects (DTOs) that handle serialization/deserialization and mapping to domain entities.

```dart
@JsonSerializable()
class UserModel {
  final String id;
  final String email;
  final String name;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
  });

  // JSON serialization
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  // Domain entity mapping
  factory UserModel.fromEntity(User user) => UserModel(
    id: user.id,
    email: user.email,
    name: user.name,
    createdAt: user.createdAt,
  );

  User toEntity() => User(
    id: id,
    email: email,
    name: name,
    createdAt: createdAt,
  );
}
```

### 2. Repository Implementations

Classes that implement the repository interfaces from the domain layer.

```dart
@Injectable(as: IUserRepository)
class UserRepositoryImpl implements IUserRepository {
  final UserRemoteDataSource _remoteDataSource;
  final UserLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;

  UserRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
  );

  @override
  Future<Either<Failure, User>> getUser(String id) async {
    if (await _networkInfo.isConnected) {
      try {
        final remoteUser = await _remoteDataSource.getUser(id);
        await _localDataSource.cacheUser(remoteUser);
        return Right(remoteUser.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(e.message));
      }
    } else {
      try {
        final localUser = await _localDataSource.getLastUser();
        return Right(localUser.toEntity());
      } on CacheException {
        return Left(CacheFailure('No cached data available'));
      }
    }
  }
}
```

### 3. Data Sources

Classes that handle direct data operations with specific sources.

#### Remote Data Source
```dart
@injectable
class UserRemoteDataSource {
  final GraphQLClient _client;

  UserRemoteDataSource(this._client);

  Future<UserModel> getUser(String id) async {
    final result = await _client.query(
      QueryOptions(
        document: GET_USER_QUERY_DOCUMENT,
        variables: {'id': id},
      ),
    );

    if (result.hasException) {
      throw ServerException(result.exception?.message ?? 'Server error');
    }

    return UserModel.fromJson(result.data!['user']);
  }
}
```

#### Local Data Source
```dart
@injectable
class UserLocalDataSource {
  final Box<UserModel> _box;

  UserLocalDataSource(this._box);

  Future<void> cacheUser(UserModel user) async {
    await _box.put(user.id, user);
  }

  Future<UserModel> getLastUser() async {
    final user = _box.values.lastOrNull;
    if (user == null) {
      throw CacheException('No user cached');
    }
    return user;
  }
}
```

### 4. GraphQL Integration

#### Operations
```graphql
# operations/queries/get_user.graphql
query GetUser($id: ID!) {
  user(id: $id) {
    id
    email
    name
    createdAt
  }
}

# operations/mutations/update_user.graphql
mutation UpdateUser($id: ID!, $input: UpdateUserInput!) {
  updateUser(id: $id, input: $input) {
    id
    email
    name
    createdAt
  }
}
```

#### Code Generation Configuration
```yaml
# build.yaml
targets:
  $default:
    builders:
      graphql_codegen:
        options:
          clients:
            - graphql
          scalars:
            DateTime:
              type: DateTime
          addTypename: true
          generateHelpers: true
```

## Dependencies

```yaml
dependencies:
  domain:
    path: ../domain
  graphql: ^5.2.0-beta.7
  injectable: ^2.3.2
  json_annotation: ^4.8.1
  objectbox: ^2.5.0
  shared_preferences: ^2.2.0

dev_dependencies:
  build_runner: ^2.4.7
  graphql_codegen: ^0.13.11
  injectable_generator: ^2.4.1
  json_serializable: ^6.7.1
  mockito: ^5.4.3
  test: ^1.24.0
```

## Testing

### Repository Tests
```dart
void main() {
  late UserRepositoryImpl repository;
  late MockRemoteDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockRemoteDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = UserRepositoryImpl(
      mockRemoteDataSource,
      mockLocalDataSource,
      mockNetworkInfo,
    );
  });

  group('getUser', () {
    test('should return remote data when network is available', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(() => mockRemoteDataSource.getUser(any()))
          .thenAnswer((_) async => tUserModel);

      // Act
      final result = await repository.getUser('1');

      // Assert
      verify(() => mockRemoteDataSource.getUser('1')).called(1);
      expect(result, Right(tUser));
    });

    test('should return cached data when network is unavailable', () async {
      // Arrange
      when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      when(() => mockLocalDataSource.getLastUser())
          .thenAnswer((_) async => tUserModel);

      // Act
      final result = await repository.getUser('1');

      // Assert
      verify(() => mockLocalDataSource.getLastUser()).called(1);
      expect(result, Right(tUser));
    });
  });
}
```

## Code Generation

To generate code for GraphQL operations and JSON serialization:

```bash
# Generate all code
flutter pub run build_runner build --delete-conflicting-outputs

# Watch for changes
flutter pub run build_runner watch
```

## Best Practices

1. **Error Handling**
   - Map exceptions to domain failures
   - Handle network connectivity
   - Implement proper error logging

2. **Caching Strategy**
   - Implement offline-first approach when applicable
   - Clear cache at appropriate times
   - Handle cache invalidation

3. **Data Mapping**
   - Keep mapping logic in data models
   - Validate data during mapping
   - Handle null values appropriately

4. **Testing**
   - Test both success and failure cases
   - Mock external dependencies
   - Test caching behavior

5. **GraphQL**
   - Keep operations in separate files
   - Use fragments for shared fields
   - Handle pagination properly

## Contributing

1. Follow the established project structure
2. Add tests for new functionality
3. Generate code before committing
4. Document complex data transformations
5. Handle errors appropriately
6. Keep repository implementations clean
7. Use dependency injection

## Additional Resources

- [GraphQL Code Generator Documentation](https://pub.dev/packages/graphql_codegen)
- [ObjectBox Documentation](https://docs.objectbox.io/getting-started)
- [JSON Serialization in Dart](https://dart.dev/guides/json)
- [Error Handling Best Practices](https://dart.dev/guides/language/effective-dart/usage#error-handling)

## Extended Examples and Patterns

### Advanced Data Models

#### 1. Nested Object Handling
```dart
@JsonSerializable()
class OrderModel {
  final String id;
  final UserModel user;
  final List<OrderItemModel> items;
  @JsonKey(name: 'total_amount')
  final double totalAmount;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'status')
  final OrderStatus status;

  const OrderModel({
    required this.id,
    required this.user,
    required this.items,
    required this.totalAmount,
    required this.createdAt,
    required this.status,
  });

  // JSON serialization
  factory OrderModel.fromJson(Map<String, dynamic> json) => _$OrderModelFromJson(json);
  Map<String, dynamic> toJson() => _$OrderModelToJson(this);

  // Domain entity mapping
  factory OrderModel.fromEntity(Order order) => OrderModel(
    id: order.id,
    user: UserModel.fromEntity(order.user),
    items: order.items.map((item) => OrderItemModel.fromEntity(item)).toList(),
    totalAmount: order.totalAmount,
    createdAt: order.createdAt,
    status: order.status,
  );

  Order toEntity() => Order(
    id: id,
    user: user.toEntity(),
    items: items.map((item) => item.toEntity()).toList(),
    totalAmount: totalAmount,
    createdAt: createdAt,
    status: status,
  );
}
```

#### 2. Enum Handling
```dart
@JsonSerializable()
class ServiceModel {
  final String id;
  final String name;
  @JsonKey(
    name: 'service_type',
    fromJson: _serviceTypeFromJson,
    toJson: _serviceTypeToJson,
  )
  final ServiceType serviceType;
  @JsonKey(name: 'is_active')
  final bool isActive;

  const ServiceModel({
    required this.id,
    required this.name,
    required this.serviceType,
    required this.isActive,
  });

  // Custom JSON converters for enums
  static ServiceType _serviceTypeFromJson(String value) =>
      ServiceType.values.firstWhere(
        (type) => type.toString().split('.').last == value,
        orElse: () => ServiceType.unknown,
      );

  static String _serviceTypeToJson(ServiceType type) =>
      type.toString().split('.').last;

  // Standard JSON serialization
  factory ServiceModel.fromJson(Map<String, dynamic> json) =>
      _$ServiceModelFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceModelToJson(this);
}
```

### GraphQL Operations Examples

#### 1. Query with Pagination
```graphql
# operations/queries/list_services.graphql
query ListServices($first: Int!, $after: String) {
  services(first: $first, after: $after) {
    edges {
      node {
        id
        name
        serviceType
        isActive
        price
        description
      }
      cursor
    }
    pageInfo {
      hasNextPage
      endCursor
    }
  }
}
```

#### 2. Mutation with Input Type
```graphql
# operations/mutations/create_booking.graphql
mutation CreateBooking($input: CreateBookingInput!) {
  createBooking(input: $input) {
    booking {
      id
      service {
        id
        name
      }
      customer {
        id
        name
        email
      }
      provider {
        id
        name
        rating
      }
      scheduledTime
      status
      notes
    }
    errors {
      field
      message
    }
  }
}
```

#### 3. Subscription Example
```graphql
# operations/subscriptions/booking_updates.graphql
subscription OnBookingUpdate($bookingId: ID!) {
  bookingUpdated(bookingId: $bookingId) {
    id
    status
    lastUpdate
    notification {
      type
      message
    }
  }
}
```

### Advanced Data Source Implementations

#### 1. Remote Data Source with Pagination
```dart
@injectable
class ServiceRemoteDataSource {
  final GraphQLClient _client;

  ServiceRemoteDataSource(this._client);

  Future<PaginatedResponse<ServiceModel>> getServices({
    required int first,
    String? after,
  }) async {
    final result = await _client.query(
      QueryOptions(
        document: LIST_SERVICES_QUERY_DOCUMENT,
        variables: {
          'first': first,
          'after': after,
        },
      ),
    );

    if (result.hasException) {
      throw ServerException(_handleGraphQLException(result.exception!));
    }

    final data = result.data!['services'];
    return PaginatedResponse(
      items: (data['edges'] as List)
          .map((edge) => ServiceModel.fromJson(edge['node']))
          .toList(),
      pageInfo: PageInfo(
        hasNextPage: data['pageInfo']['hasNextPage'],
        endCursor: data['pageInfo']['endCursor'],
      ),
    );
  }

  String _handleGraphQLException(GraphQLException exception) {
    // Custom error handling logic
    if (exception.graphqlErrors.isNotEmpty) {
      final error = exception.graphqlErrors.first;
      if (error.extensions?['code'] == 'UNAUTHORIZED') {
        throw UnauthorizedException(error.message);
      }
      return error.message;
    }
    return 'An unexpected error occurred';
  }
}
```

#### 2. Local Data Source with ObjectBox
```dart
@injectable
class BookingLocalDataSource {
  final Store _store;
  late final Box<BookingModel> _box;
  late final Stream<List<BookingModel>> _bookingStream;

  BookingLocalDataSource(this._store) {
    _box = _store.box<BookingModel>();
    _bookingStream = _box
        .query()
        .watch(triggerImmediately: true)
        .map((query) => query.find());
  }

  Future<void> cacheBookings(List<BookingModel> bookings) async {
    await _box.putMany(bookings);
  }

  Future<BookingModel?> getBooking(String id) async {
    final booking = _box.query(BookingModel_.id.equals(id)).build().findFirst();
    if (booking == null) {
      throw CacheException('Booking not found');
    }
    return booking;
  }

  Stream<List<BookingModel>> watchBookings() => _bookingStream;

  Future<void> clearOutdatedBookings() async {
    final outdatedQuery = _box.query(
      BookingModel_.scheduledTime.lessThan(
        DateTime.now().subtract(const Duration(days: 30)).millisecondsSinceEpoch,
      ),
    ).build();
    await outdatedQuery.remove();
  }
}
```

### Comprehensive Error Handling

#### 1. Exception Hierarchy
```dart
/// Base exception class for the data layer
abstract class DataException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const DataException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'DataException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Network-related exceptions
class NetworkException extends DataException {
  final int? statusCode;

  const NetworkException(
    String message, {
    this.statusCode,
    String? code,
    dynamic originalError,
  }) : super(message, code: code, originalError: originalError);
}

/// GraphQL-specific exceptions
class GraphQLException extends DataException {
  final List<GraphQLError> graphqlErrors;
  final Map<String, dynamic>? extensions;

  const GraphQLException(
    String message, {
    required this.graphqlErrors,
    this.extensions,
    String? code,
    dynamic originalError,
  }) : super(message, code: code, originalError: originalError);
}

/// Cache-related exceptions
class CacheException extends DataException {
  const CacheException(
    String message, {
    String? code,
    dynamic originalError,
  }) : super(message, code: code, originalError: originalError);
}
```

#### 2. Error Mapping in Repository
```dart
@Injectable(as: IBookingRepository)
class BookingRepositoryImpl implements IBookingRepository {
  final BookingRemoteDataSource _remoteDataSource;
  final BookingLocalDataSource _localDataSource;
  final NetworkInfo _networkInfo;
  final ErrorMapper _errorMapper;

  BookingRepositoryImpl(
    this._remoteDataSource,
    this._localDataSource,
    this._networkInfo,
    this._errorMapper,
  );

  @override
  Future<Either<Failure, Booking>> createBooking(CreateBookingParams params) async {
    try {
      if (!await _networkInfo.isConnected) {
        return Left(NetworkFailure('No internet connection'));
      }

      final bookingModel = await _remoteDataSource.createBooking(params);
      await _localDataSource.cacheBooking(bookingModel);
      return Right(bookingModel.toEntity());
    } on DataException catch (e) {
      return Left(_errorMapper.mapException(e));
    } catch (e) {
      return Left(UnexpectedFailure('An unexpected error occurred: ${e.toString()}'));
    }
  }
}

@injectable
class ErrorMapper {
  Failure mapException(DataException exception) {
    return switch (exception) {
      NetworkException e => NetworkFailure(e.message),
      GraphQLException e => _handleGraphQLError(e),
      CacheException e => CacheFailure(e.message),
      _ => UnexpectedFailure(exception.message),
    };
  }

  Failure _handleGraphQLError(GraphQLException exception) {
    if (exception.graphqlErrors.isEmpty) {
      return ServerFailure('GraphQL error: ${exception.message}');
    }

    final error = exception.graphqlErrors.first;
    final code = error.extensions?['code'] as String?;

    return switch (code) {
      'UNAUTHORIZED' => AuthenticationFailure(error.message),
      'FORBIDDEN' => AuthorizationFailure(error.message),
      'NOT_FOUND' => NotFoundFailure(error.message),
      'VALIDATION_ERROR' => ValidationFailure(error.message),
      _ => ServerFailure(error.message),
    };
  }
}
```

#### 3. Error Logging and Monitoring
```dart
@injectable
class ErrorLogger {
  final CrashlyticsPlatform _crashlytics;
  final AnalyticsPlatform _analytics;

  ErrorLogger(this._crashlytics, this._analytics);

  Future<void> logError(
    Object error,
    StackTrace stackTrace, {
    String? context,
    Map<String, dynamic>? extras,
  }) async {
    // Log to crashlytics
    await _crashlytics.recordError(
      error,
      stackTrace,
      reason: context,
      information: extras?.entries.map((e) => '${e.key}: ${e.value}').toList(),
    );

    // Track in analytics
    await _analytics.trackError(
      error.toString(),
      stackTrace: stackTrace.toString(),
      parameters: {
        if (context != null) 'context': context,
        if (extras != null) ...extras,
      },
    );

    // Log to console in debug mode
    if (kDebugMode) {
      print('Error: $error');
      print('Context: $context');
      print('Extras: $extras');
      print('StackTrace: $stackTrace');
    }
  }
}
```

## Best Practices for Complex Data Operations

### 1. Batch Operations
```dart
@injectable
class BatchOperationHandler {
  final GraphQLClient _client;

  Future<List<T>> executeBatch<T>({
    required List<Map<String, dynamic>> operations,
    required T Function(Map<String, dynamic>) mapper,
    int batchSize = 10,
  }) async {
    final results = <T>[];

    for (var i = 0; i < operations.length; i += batchSize) {
      final batch = operations.skip(i).take(batchSize).toList();
      final batchResults = await Future.wait(
        batch.map((op) => _executeOperation(op, mapper)),
      );
      results.addAll(batchResults);
    }

    return results;
  }

  Future<T> _executeOperation<T>(
    Map<String, dynamic> operation,
    T Function(Map<String, dynamic>) mapper,
  ) async {
    // Implementation
  }
}
```

### 2. Caching Strategy
```dart
@injectable
class CacheManager {
  final SharedPreferences _prefs;
  final Duration _defaultExpiration;

  Future<T?> getCachedData<T>({
    required String key,
    required T Function(String) deserializer,
  }) async {
    final data = _prefs.getString(key);
    if (data == null) return null;

    final expirationKey = '${key}_expiration';
    final expirationTime = _prefs.getInt(expirationKey) ?? 0;

    if (DateTime.now().millisecondsSinceEpoch > expirationTime) {
      await Future.wait([
        _prefs.remove(key),
        _prefs.remove(expirationKey),
      ]);
      return null;
    }

    return deserializer(data);
  }

  Future<void> cacheData<T>({
    required String key,
    required T data,
    required String Function(T) serializer,
    Duration? expiration,
  }) async {
    final expirationTime = DateTime.now().add(expiration ?? _defaultExpiration);

    await Future.wait([
      _prefs.setString(key, serializer(data)),
      _prefs.setInt(
        '${key}_expiration',
        expirationTime.millisecondsSinceEpoch,
      ),
    ]);
  }
}
```

### 3. Retry Mechanism
```dart
@injectable
class RetryManager {
  Future<T> executeWithRetry<T>({
    required Future<T> Function() operation,
    int maxAttempts = 3,
    Duration initialDelay = const Duration(seconds: 1),
    double backoffFactor = 2.0,
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (true) {
      try {
        attempt++;
        return await operation();
      } on NetworkException catch (e) {
        if (attempt >= maxAttempts) rethrow;

        await Future.delayed(delay);
        delay *= backoffFactor;

        if (e.statusCode == 429) { // Rate limit
          delay *= 2; // Additional delay for rate limits
        }
      }
    }
  }
}
```

These examples demonstrate advanced patterns and best practices for handling complex data operations in a Clean Architecture Flutter application. They provide robust error handling, efficient caching, and reliable data management strategies.

// to build iOS app
//Note Make sure you are changing ENV

flutter build ios --release --dart-define-from-file=env/prod.json;

// to build android app
//Note Make sure you are changing ENV

flutter build appbundle --dart-define-from-file=env/prod.json;

flutter build web --dart-define-from-file=env/dev.json;
flutter run -d chrome --web-port=3000 --dart-define-from-file=env/dev.json

// intilized codegen

npx @aws-amplify/cli codegen add --apiId tqfsw65x2facxp4eenldmqhp2e --region ap-southeast-2

/// to get latest aws schema.graphql in dev

// Step 1

cd data/lib/graphql

aws appsync get-introspection-schema --api-id tqfsw65x2facxp4eenldmqhp2e --region ap-southeast-2 --format SDL schema.graphql

and to genrate model run this

npx @aws-amplify/cli codegen models --model-schema schema.graphql --target flutter --output-dir ./models;

// add this 2 line in schema.graphql inside lib/graphql/schema.graphql

scalar AWSJSON
scalar AWSDateTime
