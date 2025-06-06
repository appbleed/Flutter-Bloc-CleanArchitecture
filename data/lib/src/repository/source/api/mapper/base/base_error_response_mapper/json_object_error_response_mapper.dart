import 'package:injectable/injectable.dart';

import 'package:shared/shared.dart';
import '../../../../../../../data.dart';

@Injectable()
class JsonObjectErrorResponseMapper
    extends BaseErrorResponseMapper<Map<String, dynamic>> {
  const JsonObjectErrorResponseMapper();

  @override
  ServerError mapToServerError(Map<String, dynamic>? data) {
    return ServerError.general(
      generalMessage: data?['message'] as String?,
    );
  }
}
