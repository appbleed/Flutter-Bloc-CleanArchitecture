import '../base/app_exception.dart';
import 'server_error.dart';

class RemoteException extends AppException {
  const RemoteException({
    required this.kind,
    this.httpErrorCode,
    this.serverError,
    this.rootException,
  }) : super(AppExceptionType.remote);

  final RemoteExceptionKind kind;
  final int? httpErrorCode;
  final ServerError? serverError;
  final Object? rootException;

  int get generalServerStatusCode {
    final error = serverError;
    if (error == null) {
      return -1;
    }

    // Check if it's a general server error (has the properties we need)
    try {
      // Try to access generalServerStatusCode property
      final generalError = error as dynamic;
      if (generalError.generalServerStatusCode != null) {
        return generalError.generalServerStatusCode as int;
      }

      // Try to get from errors list
      if (generalError.errors != null &&
          (generalError.errors as List).isNotEmpty) {
        final firstError = (generalError.errors as List).first as dynamic;
        if (firstError.serverStatusCode != null) {
          return firstError.serverStatusCode as int;
        }
      }
    } catch (e) {
      // If it's a simple error, return -1
    }

    return -1;
  }

  String? get generalServerErrorId {
    final error = serverError;
    if (error == null) {
      return null;
    }

    try {
      final generalError = error as dynamic;
      if (generalError.generalServerErrorId != null) {
        return generalError.generalServerErrorId as String;
      }

      if (generalError.errors != null &&
          (generalError.errors as List).isNotEmpty) {
        final firstError = (generalError.errors as List).first as dynamic;
        if (firstError.serverErrorId != null) {
          return firstError.serverErrorId as String;
        }
      }
    } catch (e) {
      // If it's a simple error, return null
    }

    return null;
  }

  String? get generalServerMessage {
    final error = serverError;
    if (error == null) {
      return null;
    }

    try {
      final generalError = error as dynamic;

      // Try generalMessage first
      if (generalError.generalMessage != null) {
        return generalError.generalMessage as String;
      }

      // Try message property (for simple errors)
      if (generalError.message != null) {
        return generalError.message as String;
      }

      // Try to get from errors list
      if (generalError.errors != null &&
          (generalError.errors as List).isNotEmpty) {
        final firstError = (generalError.errors as List).first as dynamic;
        if (firstError.detailMessage != null) {
          return firstError.detailMessage as String;
        }
        if (firstError.simpleMessage != null) {
          return firstError.simpleMessage as String;
        }
      }
    } catch (e) {
      // Return null if any error occurs
    }

    return null;
  }

  @override
  String toString() {
    return '''RemoteException: {
      kind: $kind
      httpErrorCode: $httpErrorCode,
      serverError: $serverError,
      rootException: $rootException,
      generalServerMessage: $generalServerMessage,
      generalServerStatusCode: $generalServerStatusCode,
      generalServerErrorId: $generalServerErrorId,
      stackTrace: ${rootException is Error ? (rootException as Error).stackTrace : ''}
}''';
  }
}

enum RemoteExceptionKind {
  noInternet,

  /// host not found, cannot connect to host, SocketException
  network,

  /// server has defined response
  serverDefined,

  /// server has not defined response
  serverUndefined,

  /// Caused by an incorrect certificate as configured by [ValidateCertificate]
  badCertificate,

  /// error occurs when passing JSON
  decodeError,

  refreshTokenFailed,
  timeout,
  cancellation,
  unknown,
}
