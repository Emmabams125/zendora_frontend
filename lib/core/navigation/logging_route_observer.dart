import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:zendora_app/core/constants/utils/app_logger.dart';

class LoggingRouteObserver extends GetObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    AppLogger.navigation("Navigated to ${route.settings.name}");
    super.didPush(route, previousRoute);
  }
}
