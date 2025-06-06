import 'package:freezed_annotation/freezed_annotation.dart';

part 'test_freezed.freezed.dart';

@freezed
class TestFreezed with _$TestFreezed {
  const factory TestFreezed.success(String data) = _Success;
  const factory TestFreezed.error(String message) = _Error;
}
