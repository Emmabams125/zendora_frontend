import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:zendora_app/app/locator.dart';
import 'package:zendora_app/app/routes_names.dart';
import 'package:zendora_app/core/constants/datasource/auth/auth_remote_data_source.dart';
import 'package:zendora_app/core/constants/services/storage_service/storage_service.dart';
import 'package:zendora_app/core/widgets/app_snackbar.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRemoteDataSource _auth = locator<AuthRemoteDataSource>();
  final StorageService _storage = locator<StorageService>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  bool _keepSignedIn = true;
  bool get keepSignedIn => _keepSignedIn;

  String? error;

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleKeepSignedIn(bool value) {
    _keepSignedIn = value;
    notifyListeners();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      error = 'Enter your email/username and password';
      notifyListeners();
      return;
    }

    dev.log('🔐 LOGIN ATTEMPT: Email: $email', name: 'AUTH');

    _isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _auth.login(email: email, password: password);

      result.fold(
        (loginError) {
          dev.log(
            '❌ LOGIN FAILED: ${loginError.message}',
            name: 'AUTH',
            error: loginError,
          );
          error = loginError.message;
          _isLoading = false;
          notifyListeners();
          AppSnackbar.error(loginError.message);
        },
        (response) async {
          dev.log('✅ LOGIN SUCCESS: Token received', name: 'AUTH');

          if (response.token != null) {
            await _storage.saveToken(response.token!);
            dev.log('💾 TOKEN SAVED to storage', name: 'AUTH');
          }

          _isLoading = false;
          notifyListeners();

          AppSnackbar.success('Welcome back!');

          dev.log('🏠 NAVIGATING to dashboard', name: 'AUTH');
          Get.offAllNamed(Routes.dashboard);
        },
      );
    } catch (e) {
      dev.log('💥 LOGIN EXCEPTION: $e', name: 'AUTH', error: e);
      error = 'Login failed: $e';
      _isLoading = false;
      notifyListeners();
      AppSnackbar.error(error!);
    }
  }

  void goToRegister() {
    dev.log('🔄 NAVIGATING to register screen from login', name: 'NAVIGATION');
    Get.toNamed(Routes.signup);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
