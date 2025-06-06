import 'package:freezed_annotation/freezed_annotation.dart';

part 'token.freezed.dart';

@freezed
abstract class Token with _$Token {
  const factory Token({
    @Default(Token.defaultAccessToken) String accessToken,
    @Default(Token.defaultRefreshToken) String refreshToken,
  }) = _Token;

  const Token._();

  static const defaultAccessToken = '';
  static const defaultRefreshToken = '';
}
