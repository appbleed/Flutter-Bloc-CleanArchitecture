import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared.dart';

part 'result.freezed.dart';

@freezed
sealed class Result<T> with _$Result<T> {
  const factory Result.success(T data) = _Success;
  const factory Result.failure(AppException exception) = _Error;
}

extension ResultExtension<T> on Result<T> {
  R when<R>({
    required R Function(T data) success,
    required R Function(AppException exception) failure,
  }) {
    return switch (this) {
      _Success<T>(data: final data) => success(data),
      _Error<T>(exception: final exception) => failure(exception),
    };
  }
}
