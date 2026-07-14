import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:zendora_app/app/app_pages.dart';
import 'package:zendora_app/app/routes_names.dart';
import 'package:zendora_app/app/locator.dart';
import 'package:zendora_app/core/navigation/logging_route_observer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(1.0)),
          child: GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Zendora App',
            initialRoute: Routes.SplashView,
            getPages: AppPages.routes,
            navigatorObservers: [LoggingRouteObserver()],
            theme: ThemeData(
              fontFamily: 'Inter',
            ),
          ),
        );
      },
    );
  }
}