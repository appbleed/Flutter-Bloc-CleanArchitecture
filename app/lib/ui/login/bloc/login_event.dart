import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../base/bloc/base_bloc_event.dart';

part 'login_event.freezed.dart';

abstract class LoginEvent extends BaseBlocEvent {
  const LoginEvent();
}

@freezed
abstract class EmailTextFieldChanged extends LoginEvent
    with _$EmailTextFieldChanged {
  const EmailTextFieldChanged._();

  const factory EmailTextFieldChanged({
    required String email,
  }) = _EmailTextFieldChanged;
}

@freezed
abstract class PasswordTextFieldChanged extends LoginEvent
    with _$PasswordTextFieldChanged {
  const PasswordTextFieldChanged._();

  const factory PasswordTextFieldChanged({
    required String password,
  }) = _PasswordTextFieldChanged;
}

@freezed
abstract class EyeIconPressed extends LoginEvent with _$EyeIconPressed {
  const EyeIconPressed._();

  const factory EyeIconPressed() = _EyeIconPressed;
}

@freezed
abstract class LoginButtonPressed extends LoginEvent with _$LoginButtonPressed {
  const LoginButtonPressed._();

  const factory LoginButtonPressed() = _LoginButtonPressed;
}

@freezed
abstract class FakeLoginButtonPressed extends LoginEvent
    with _$FakeLoginButtonPressed {
  const FakeLoginButtonPressed._();

  const factory FakeLoginButtonPressed() = _FakeLoginButtonPressed;
}
