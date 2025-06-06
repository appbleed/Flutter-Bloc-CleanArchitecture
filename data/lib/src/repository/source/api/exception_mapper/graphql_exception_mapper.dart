// import 'package:graphql_flutter/graphql_flutter.dart';

import 'package:shared/shared.dart';

// TODO(dev): GraphQL exception mapper temporarily disabled due to dependency conflicts
class GraphQLExceptionMapper extends ExceptionMapper<RemoteException> {
  GraphQLExceptionMapper();

  @override
  RemoteException map(Object? exception) {
    // Temporary implementation - replace with actual GraphQL logic once dependencies are resolved
    return RemoteException(
      kind: RemoteExceptionKind.unknown,
      rootException: exception,
    );

    /*
    // Original GraphQL implementation - uncomment once dependencies are resolved
    if (exception is! OperationException) {
      return RemoteException(kind: RemoteExceptionKind.unknown, rootException: exception);
    }

    if (exception.linkException?.originalException is DioException) {
      final dioException = exception.linkException!.originalException as DioException;
      if (dioException.type == DioExceptionType.badResponse) {
        /// server-defined error
        ServerError? serverError;
        if (dioException.response?.data != null) {
          serverError = dioException.response!.data! is Map
              ? _errorResponseMapper.map(dioException.response!.data!)
              : ServerError.simple(
                  dioException.response!.data! is String
                      ? dioException.response!.data! as String
                      : 'Unknown server error',
                );
        }

        return RemoteException(
          kind: RemoteExceptionKind.serverUndefined,
          serverError: serverError,
        );
      } else {
        return DioExceptionMapper(_errorResponseMapper)
            .map(exception.linkException?.originalException);
      }
    } else {
      final serverError = _serverGraphQLErrorResponseMapper.map(exception);

      return RemoteException(
        kind: RemoteExceptionKind.serverDefined,
        serverError: serverError,
      );
    }
    */
  }
}
