import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import '../../../domain.dart';

part 'register_account_use_case.freezed.dart';

@Injectable()
class RegisterAccountUseCase
    extends BaseFutureUseCase<RegisterAccountInput, RegisterAccountOutput> {
  const RegisterAccountUseCase(this._repository);

  final Repository _repository;

  @protected
  @override
  Future<RegisterAccountOutput> buildUseCase(RegisterAccountInput input) async {
    await _repository.register(
      email: input.email,
      username: input.username,
      password: input.password,
      gender: input.gender,
    );

    return const RegisterAccountOutput();
  }
}

@freezed
abstract class RegisterAccountInput extends BaseInput
    with _$RegisterAccountInput {
  const RegisterAccountInput._();

  const factory RegisterAccountInput({
    @Default('') String email,
    @Default('') String password,
    @Default('') String confirmPassword,
    @Default('') String username,
    @Default(Gender.unknown) Gender gender,
  }) = _RegisterAccountInput;
}

@freezed
abstract class RegisterAccountOutput extends BaseOutput
    with _$RegisterAccountOutput {
  const RegisterAccountOutput._();

  const factory RegisterAccountOutput() = _RegisterAccountOutput;
}
