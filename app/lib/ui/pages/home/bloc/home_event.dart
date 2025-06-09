import 'dart:async';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../base/bloc/base_bloc_event.dart';

part 'home_event.freezed.dart';

abstract class HomeEvent extends BaseBlocEvent {
  const HomeEvent();
}

@freezed
abstract class HomePageInitiated extends HomeEvent with _$HomePageInitiated {
  const HomePageInitiated._();

  const factory HomePageInitiated() = _HomePageInitiated;
}

@freezed
abstract class HomePageRefreshed extends HomeEvent with _$HomePageRefreshed {
  const HomePageRefreshed._();

  const factory HomePageRefreshed({
    @Default(false) bool isInitial,
    Completer<void>? completer,
  }) = _HomePageRefreshed;
}

@freezed
abstract class UserLoadMore extends HomeEvent with _$UserLoadMore {
  const UserLoadMore._();

  const factory UserLoadMore() = _UserLoadMore;
}
