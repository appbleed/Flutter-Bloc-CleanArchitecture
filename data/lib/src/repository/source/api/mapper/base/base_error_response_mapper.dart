import 'package:shared/shared.dart';

import '../../../../../../data.dart';

enum ErrorResponseMapperType {
  jsonObject,
  jsonArray,
  line,
  twitter,
  goong,
  firebaseStorage,
}

abstract class BaseErrorResponseMapper<T extends Object> {
  const BaseErrorResponseMapper();

  factory BaseErrorResponseMapper.fromType(ErrorResponseMapperType type) {
    switch (type) {
      case ErrorResponseMapperType.jsonObject:
        return const JsonObjectErrorResponseMapper()
            as BaseErrorResponseMapper<T>;
      case ErrorResponseMapperType.jsonArray:
        return const JsonArrayErrorResponseMapper()
            as BaseErrorResponseMapper<T>;
      case ErrorResponseMapperType.line:
        return const LineErrorResponseMapper() as BaseErrorResponseMapper<T>;
      case ErrorResponseMapperType.twitter:
        return const TwitterErrorResponseMapper() as BaseErrorResponseMapper<T>;
      case ErrorResponseMapperType.goong:
        return const GoongErrorResponseMapper() as BaseErrorResponseMapper<T>;
      case ErrorResponseMapperType.firebaseStorage:
        return const FirebaseStorageErrorResponseMapper()
            as BaseErrorResponseMapper<T>;
    }
  }

  ServerError map(dynamic errorResponse) {
    try {
      if (errorResponse is! T) {
        throw RemoteException(
          kind: RemoteExceptionKind.decodeError,
          rootException: 'Response ${errorResponse} is not $T',
        );
      }

      final serverError = mapToServerError(errorResponse);

      return serverError;
    } on RemoteException catch (_) {
      rethrow;
    } catch (e) {
      throw RemoteException(
          kind: RemoteExceptionKind.decodeError, rootException: e);
    }
  }

  ServerError mapToServerError(T? errorResponse);
}
