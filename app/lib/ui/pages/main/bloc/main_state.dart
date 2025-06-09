import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../base/bloc/base_bloc_state.dart';

part 'main_state.freezed.dart';

@freezed
abstract class MainState extends BaseBlocState with _$MainState {
  const MainState._();

  const factory MainState({
    @Default(0) int currentBottomTabIndex,
  }) = _MainState;
}
