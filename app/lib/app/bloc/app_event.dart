import 'package:domain/domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../base/bloc/base_bloc_event.dart';

part 'app_event.freezed.dart';

abstract class AppEvent extends BaseBlocEvent {
  const AppEvent();
}

@freezed
abstract class IsLoggedInStatusChanged extends AppEvent
    with _$IsLoggedInStatusChanged {
  const IsLoggedInStatusChanged._();

  const factory IsLoggedInStatusChanged({
    required bool isLoggedIn,
  }) = _IsLoggedInStatusChanged;
}

@freezed
abstract class AppThemeChanged extends AppEvent with _$AppThemeChanged {
  const AppThemeChanged._();

  const factory AppThemeChanged({
    required bool isDarkMode,
  }) = _AppThemeChanged;
}

@freezed
abstract class AppLanguageChanged extends AppEvent with _$AppLanguageChanged {
  const AppLanguageChanged._();

  const factory AppLanguageChanged({
    required LanguageCode languageCode,
  }) = _AppLanguageChanged;
}

@freezed
class AppInitiated extends AppEvent with _$AppInitiated {
  const AppInitiated._();

  const factory AppInitiated() = _AppInitiated;
}
