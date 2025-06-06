import 'package:injectable/injectable.dart';

import 'package:shared/shared.dart';
import '../../../../../../../data.dart';

@Injectable()
class LineErrorResponseMapper
    extends BaseErrorResponseMapper<Map<String, dynamic>> {
  const LineErrorResponseMapper();

  @override
  ServerError mapToServerError(Map<String, dynamic>? json) {
    return ServerError.general(
        generalMessage: json?['error_description'] as String?);
  }
}
