import 'package:freezed_annotation/freezed_annotation.dart';

import 'server_error_detail.dart';

part 'server_error.freezed.dart';

@freezed
class ServerError with _$ServerError {
  const factory ServerError.general({
    int? generalServerStatusCode,
    String? generalServerErrorId,
    String? generalMessage,
    @Default(<ServerErrorDetail>[]) List<ServerErrorDetail> errors,
  }) = _GeneralServerError;

  const factory ServerError.simple(String message) = _SimpleServerError;
}
