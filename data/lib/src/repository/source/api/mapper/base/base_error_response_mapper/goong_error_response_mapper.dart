import 'package:injectable/injectable.dart';
import 'package:shared/shared.dart';

import '../../../../../../../data.dart';

@Injectable()
class GoongErrorResponseMapper
    extends BaseErrorResponseMapper<Map<String, dynamic>> {
  const GoongErrorResponseMapper();

  @override
  ServerError mapToServerError(Map<String, dynamic>? json) {
    return ServerError.general(
      generalMessage: json?['message'] as String?,
    );
  }
}
