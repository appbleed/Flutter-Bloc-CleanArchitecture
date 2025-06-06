import 'package:domain/domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../base/bloc/base_bloc_state.dart';

part 'app_state.freezed.dart';

@freezed
abstract class AppState extends BaseBlocState with _$AppState {
  const AppState._();

  const factory AppState({
    @Default(false) bool isLoggedIn,
    @Default(false) bool isDarkMode,
    @Default(LanguageCode.defaultValue) LanguageCode languageCode,
  }) = _AppState;
}
