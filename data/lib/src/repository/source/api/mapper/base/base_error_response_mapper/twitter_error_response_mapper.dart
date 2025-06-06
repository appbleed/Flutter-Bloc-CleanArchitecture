import 'package:injectable/injectable.dart';

import 'package:shared/shared.dart';
import '../../../../../../../data.dart';

@Injectable()
class TwitterErrorResponseMapper
    extends BaseErrorResponseMapper<Map<String, dynamic>> {
  const TwitterErrorResponseMapper();

  @override
  ServerError mapToServerError(Map<String, dynamic>? json) {
    return ServerError.general(
      generalServerStatusCode: json?['status_code'] as int?,
      generalMessage: json?['message'] as String?,
    );
  }
}
