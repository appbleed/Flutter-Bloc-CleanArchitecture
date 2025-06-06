import 'package:domain/domain.dart';
import 'package:flutter/cupertino.dart';
import 'package:injectable/injectable.dart';
import 'package:resources/resources.dart';
import 'package:shared/shared.dart';

import '../../app.dart';

@LazySingleton(as: BasePopupInfoMapper)
class AppPopupInfoMapper extends BasePopupInfoMapper {
  @override
  Widget map(AppPopupInfo appPopupInfo, AppNavigator navigator) {
    switch (appPopupInfo.runtimeType.toString()) {
      case '_ConfirmDialog':
        final confirmDialog = appPopupInfo as dynamic;
        return CommonDialog(
          actions: [
            PopupButton(
              text: S.current.ok,
              onPressed:
                  confirmDialog.onPressed ?? Func0(() => navigator.pop()),
            ),
          ],
          message: confirmDialog.message ?? '',
        );
      case '_ErrorWithRetryDialog':
        final errorDialog = appPopupInfo as dynamic;
        return CommonDialog(
          actions: [
            PopupButton(
              text: S.current.cancel,
              onPressed: Func0(() => navigator.pop()),
            ),
            PopupButton(
              text: S.current.retry,
              onPressed:
                  errorDialog.onRetryPressed ?? Func0(() => navigator.pop()),
              isDefault: true,
            ),
          ],
          message: errorDialog.message ?? '',
        );
      case '_RequiredLoginDialog':
        return CommonDialog.adaptive(
          title: S.current.login,
          message: S.current.login,
          actions: [
            PopupButton(
              text: S.current.cancel,
              onPressed: Func0(() => navigator.pop()),
            ),
            PopupButton(
              text: S.current.login,
              onPressed: Func0(() async {
                await navigator.pop();
                await navigator.push(const AppRouteInfo.login());
              }),
            ),
          ],
        );
      default:
        throw UnimplementedError(
            'Unknown AppPopupInfo type: ${appPopupInfo.runtimeType}');
    }
  }
}
