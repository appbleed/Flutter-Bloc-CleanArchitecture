import 'package:domain/domain.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../app.dart';

@LazySingleton()
class AppBloc extends BaseBloc<AppEvent, AppState> {
  AppBloc(
    this._getInitialAppDataUseCase,
    this._saveIsDarkModeUseCase,
    this._saveLanguageCodeUseCase,
  ) : super(const AppState()) {
    on<IsLoggedInStatusChanged>(
      _onIsLoggedInStatusChanged,
      transformer: log(),
    );

    on<AppThemeChanged>(
      _onAppThemeChanged,
      transformer: throttleTime(),
    );

    on<AppLanguageChanged>(
      _onAppLanguageChanged,
      transformer: log(),
    );

    on<AppInitiated>(
      _onAppInitiated,
      transformer: log(),
    );
  }

  final GetInitialAppDataUseCase _getInitialAppDataUseCase;
  final SaveIsDarkModeUseCase _saveIsDarkModeUseCase;
  final SaveLanguageCodeUseCase _saveLanguageCodeUseCase;

  void _onIsLoggedInStatusChanged(
      IsLoggedInStatusChanged event, Emitter<AppState> emit) {
    emit(state.copyWith(isLoggedIn: event.isLoggedIn));
  }

  Future<void> _onAppThemeChanged(
      AppThemeChanged event, Emitter<AppState> emit) async {
    await runBlocCatching(
      action: () async {
        await _saveIsDarkModeUseCase
            .execute(SaveIsDarkModeInput(isDarkMode: event.isDarkMode));
        _updateThemeSetting(event.isDarkMode);
        emit(state.copyWith(isDarkMode: event.isDarkMode));
      },
    );
  }

  Future<void> _onAppLanguageChanged(
      AppLanguageChanged event, Emitter<AppState> emit) async {
    await runBlocCatching(
      action: () async {
        await _saveLanguageCodeUseCase
            .execute(SaveLanguageCodeInput(languageCode: event.languageCode));
        emit(state.copyWith(languageCode: event.languageCode));
      },
    );
  }

  Future<void> _onAppInitiated(
      AppInitiated event, Emitter<AppState> emit) async {
    await runBlocCatching(
      action: () async {
        final output = await _getInitialAppDataUseCase
            .execute(const GetInitialAppDataInput());
        _updateThemeSetting(output.isDarkMode);
        emit(state.copyWith(
          isDarkMode: output.isDarkMode,
          isLoggedIn: output.isLoggedIn,
          languageCode: output.languageCode,
        ));
      },
    );
  }

  void _updateThemeSetting(bool isDarkMode) {
    AppThemeSetting.currentAppThemeType =
        isDarkMode ? AppThemeType.dark : AppThemeType.light;
  }
}
