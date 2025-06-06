// import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:injectable/injectable.dart';

import 'package:shared/shared.dart';
import '../../../../../../../data.dart';

@Injectable()
// TODO(dev): GraphQL error mapper temporarily disabled due to dependency conflicts
class ServerGraphQLErrorMapper extends BaseErrorResponseMapper<Object> {
  const ServerGraphQLErrorMapper();

  @override
  ServerError mapToServerError(Object? data) {
    // Temporary implementation - replace with actual GraphQL logic once dependencies are resolved
    return const ServerError.simple(
        'GraphQL error mapper temporarily disabled');

    /*
    // Original GraphQL implementation - uncomment once dependencies are resolved
    final operationException = data as OperationException?;
    return ServerError.general(
      generalMessage: operationException?.graphqlErrors.firstOrNull?.message,
      generalServerErrorId: operationException?.graphqlErrors.firstOrNull?.extensions?['code'] as String?,
      errors: operationException?.graphqlErrors
              .map((e) => ServerErrorDetail(
                    message: e.message,
                    serverErrorId: e.extensions?['code'] as String? ?? '',
                  ))
              .toList(growable: false) ??
          [],
    );
    */
  }
}
