import 'package:domain/domain.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:shared/shared.dart';

import '../../../base/bloc/base_bloc_state.dart';

part 'home_state.freezed.dart';

@freezed
class HomeState extends BaseBlocState with _$HomeState {
  const HomeState._();

  const factory HomeState({
    @Default(PagedList(data: <User>[])) PagedList<User> users,
    @Default(0) int loadMoreUsersCount,
  }) = _HomeState;
}
