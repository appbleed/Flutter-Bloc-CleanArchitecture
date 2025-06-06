import 'package:freezed_annotation/freezed_annotation.dart';

part 'server_error_detail.freezed.dart';

@freezed
class ServerErrorDetail with _$ServerErrorDetail {
  const factory ServerErrorDetail.detailed({
    String? detail,
    String? path,
    String? serverErrorId,
    int? serverStatusCode,
    String? detailMessage,
    String? field,
  }) = _DetailedServerErrorDetail;

  const factory ServerErrorDetail.simple(
    String? simpleMessage,
  ) = _SimpleServerErrorDetail;
}
