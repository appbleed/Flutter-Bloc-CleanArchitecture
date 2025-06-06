import 'package:freezed_annotation/freezed_annotation.dart';

import 'api_user_data.dart';

part 'api_auth_response_data.freezed.dart';
part 'api_auth_response_data.g.dart';

@freezed
abstract class ApiAuthResponseData with _$ApiAuthResponseData {
  const ApiAuthResponseData._();

  const factory ApiAuthResponseData({
    @JsonKey(name: 'access_token') String? accessToken,
    String? email,
    String? gender,
    @JsonKey(name: 'is_new_user') bool? isNewUser,
    @JsonKey(name: 'age_range') String? ageRange,
    ApiUserData? user,
  }) = _ApiAuthResponseData;

  factory ApiAuthResponseData.fromJson(Map<String, dynamic> json) =>
      _$ApiAuthResponseDataFromJson(json);
}
