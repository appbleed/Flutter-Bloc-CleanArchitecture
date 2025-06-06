import 'package:injectable/injectable.dart';

import 'package:shared/shared.dart';
import '../../../../../../../data.dart';

@Injectable()
class JsonArrayErrorResponseMapper
    extends BaseErrorResponseMapper<List<dynamic>> {
  const JsonArrayErrorResponseMapper();

  @override
  ServerError mapToServerError(List<dynamic>? data) {
    return ServerError.general(
      generalMessage: data?.firstOrNull?['message'] as String?,
      errors: data
              ?.map((e) => ServerErrorDetail.detailed(
                    detailMessage: e['message'] as String?,
                    serverErrorId: e['error_code'] as String? ?? '',
                  ))
              .toList(growable: false) ??
          [],
    );
  }
}
