import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:zendora_app/app/locator.dart';
import 'package:zendora_app/app/routes_names.dart';
import 'package:zendora_app/core/constants/datasource/profile/profile_remote_data_source.dart';
import 'package:zendora_app/core/constants/services/storage_service/storage_service.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  void initState() {
    super.initState();
    _init();
  }

  void _init() async {
    await Future.delayed(const Duration(seconds: 2));

    final token = locator<StorageService>().getToken();
    if (token == null || token.isEmpty) {
      Get.offAllNamed(Routes.login);
      return;
    }

    final result = await locator<ProfileRemoteDataSource>().getMe();
    result.fold(
      (_) => Get.offAllNamed(Routes.login),
      (_) => Get.offAllNamed(Routes.dashboard),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/icons/z.png', height: 108),
            20.verticalSpace,
            Text(
              'ZEENDORA',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
