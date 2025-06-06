import 'package:auto_route/auto_route.dart';
import 'package:domain/domain.dart';
import 'package:injectable/injectable.dart';

import '../../app.dart';

@LazySingleton(as: BaseRouteInfoMapper)
class AppRouteInfoMapper extends BaseRouteInfoMapper {
  @override
  PageRouteInfo map(AppRouteInfo appRouteInfo) {
    switch (appRouteInfo.runtimeType.toString()) {
      case '_Login':
        return const LoginRoute();
      case '_Main':
        return const MainRoute();
      case '_ItemDetail':
        final itemDetail = appRouteInfo as dynamic;
        return ItemDetailRoute(user: itemDetail.user);
      default:
        throw UnimplementedError(
            'Unknown AppRouteInfo type: ${appRouteInfo.runtimeType}');
    }
  }
}
