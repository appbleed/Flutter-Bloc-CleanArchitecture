import 'dart:async';

import 'package:domain/domain.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared/shared.dart';

import '../../app.dart';

class RunBlocCatchingParams {
  RunBlocCatchingParams({
    required this.action,
    this.doOnRetry,
    this.doOnError,
    this.doOnSubscribe,
    this.doOnSuccessOrError,
    this.doOnEventCompleted,
    this.handleLoading = true,
    this.handleError = true,
    this.handleRetry = true,
    this.forceHandleError,
    this.overrideErrorMessage,
    this.maxRetries,
  });

  final Future<void> Function() action;
  final Future<void> Function()? doOnRetry;
  final Future<void> Function(AppException)? doOnError;
  final Future<void> Function()? doOnSubscribe;
  final Future<void> Function()? doOnSuccessOrError;
  final Future<void> Function()? doOnEventCompleted;
  final bool handleLoading;
  final bool handleError;
  final bool handleRetry;
  final bool Function(AppException)? forceHandleError;
  final String? overrideErrorMessage;
  final int? maxRetries;

  RunBlocCatchingParams copyWith({
    Future<void> Function()? action,
    Future<void> Function()? doOnRetry,
    Future<void> Function(AppException)? doOnError,
    Future<void> Function()? doOnSubscribe,
    Future<void> Function()? doOnSuccessOrError,
    Future<void> Function()? doOnEventCompleted,
    bool? handleLoading,
    bool? handleError,
    bool? handleRetry,
    bool Function(AppException)? forceHandleError,
    String? overrideErrorMessage,
    int? maxRetries,
  }) {
    return RunBlocCatchingParams(
      action: action ?? this.action,
      doOnRetry: doOnRetry ?? this.doOnRetry,
      doOnError: doOnError ?? this.doOnError,
      doOnSubscribe: doOnSubscribe ?? this.doOnSubscribe,
      doOnSuccessOrError: doOnSuccessOrError ?? this.doOnSuccessOrError,
      doOnEventCompleted: doOnEventCompleted ?? this.doOnEventCompleted,
      handleLoading: handleLoading ?? this.handleLoading,
      handleError: handleError ?? this.handleError,
      handleRetry: handleRetry ?? this.handleRetry,
      forceHandleError: forceHandleError ?? this.forceHandleError,
      overrideErrorMessage: overrideErrorMessage ?? this.overrideErrorMessage,
      maxRetries: maxRetries ?? this.maxRetries,
    );
  }
}

abstract class BaseBloc<E extends BaseBlocEvent, S extends BaseBlocState>
    extends BaseBlocDelegate<E, S> with EventTransformerMixin, LogMixin {
  BaseBloc(super.initialState);
}

abstract class BaseBlocDelegate<E extends BaseBlocEvent,
    S extends BaseBlocState> extends Bloc<E, S> {
  BaseBlocDelegate(super.initialState);

  late final AppNavigator navigator;
  late final AppBloc appBloc;
  late final ExceptionHandler exceptionHandler;
  late final ExceptionMessageMapper exceptionMessageMapper;
  late final DisposeBag disposeBag;
  late final CommonBloc _commonBloc;

  set commonBloc(CommonBloc commonBloc) {
    _commonBloc = commonBloc;
  }

  CommonBloc get commonBloc =>
      this is CommonBloc ? this as CommonBloc : _commonBloc;

  @override
  void add(E event) {
    if (!isClosed) {
      super.add(event);
    } else {
      Log.e('Cannot add new event $event because $runtimeType was closed');
    }
  }

  Future<void> addException(AppExceptionWrapper appExceptionWrapper) async {
    commonBloc.add(ExceptionEmitted(
      appExceptionWrapper: appExceptionWrapper,
    ));

    return appExceptionWrapper.exceptionCompleter?.future;
  }

  void showLoading() {
    commonBloc.add(const LoadingVisibilityEmitted(isLoading: true));
  }

  void hideLoading() {
    commonBloc.add(const LoadingVisibilityEmitted(isLoading: false));
  }

  Future<void> runBlocCatchingV2(RunBlocCatchingParams params) async {
    assert(params.maxRetries == null || params.maxRetries! > 0,
        'maxRetries must be positive');
    Completer<void>? recursion;
    try {
      await params.doOnSubscribe?.call();
      if (params.handleLoading) {
        showLoading();
      }

      await params.action.call();

      if (params.handleLoading) {
        hideLoading();
      }
      await params.doOnSuccessOrError?.call();
    } on AppException catch (e) {
      if (params.handleLoading) {
        hideLoading();
      }
      await params.doOnSuccessOrError?.call();
      await params.doOnError?.call(e);

      if (params.handleError ||
          (params.forceHandleError?.call(e) ?? _forceHandleError(e))) {
        await addException(AppExceptionWrapper(
          appException: e,
          doOnRetry: params.doOnRetry ??
              (params.handleRetry && params.maxRetries != 1
                  ? () async {
                      recursion = Completer();
                      await runBlocCatchingV2(
                        params.copyWith(
                          maxRetries: params.maxRetries?.minus(1),
                        ),
                      );
                      recursion?.complete();
                    }
                  : null),
          exceptionCompleter: Completer<void>(),
          overrideMessage: params.overrideErrorMessage,
        ));
      }
    } finally {
      await recursion?.future;
      await params.doOnEventCompleted?.call();
    }
  }

  bool _forceHandleError(AppException appException) {
    return appException is RemoteException &&
        appException.kind == RemoteExceptionKind.refreshTokenFailed;
  }
}
