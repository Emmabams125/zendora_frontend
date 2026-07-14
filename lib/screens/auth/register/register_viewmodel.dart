import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:zendora_app/app/locator.dart';
import 'package:zendora_app/app/routes_names.dart';
import 'package:zendora_app/core/constants/datasource/auth/auth_remote_data_source.dart';
import 'package:zendora_app/core/constants/services/storage_service/storage_service.dart';
import 'package:zendora_app/core/widgets/app_snackbar.dart';

enum PasswordStrength { empty, weak, medium, strong }

class RegisterViewModel extends ChangeNotifier {
  final AuthRemoteDataSource _auth = locator<AuthRemoteDataSource>();
  final StorageService _storage = locator<StorageService>();

  final TextEditingController displayNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  bool _agreedToTerms = false;
  bool get agreedToTerms => _agreedToTerms;

  String? error;

  RegisterViewModel() {
    passwordController.addListener(notifyListeners);
  }

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleAgreedToTerms(bool value) {
    _agreedToTerms = value;
    notifyListeners();
  }

  PasswordStrength get passwordStrength {
    final pw = passwordController.text;
    if (pw.isEmpty) return PasswordStrength.empty;

    var score = 0;
    if (pw.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(pw) && RegExp(r'[a-z]').hasMatch(pw)) score++;
    if (RegExp(r'[0-9]').hasMatch(pw)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(pw)) score++;

    if (score <= 1) return PasswordStrength.weak;
    if (score <= 2) return PasswordStrength.medium;
    return PasswordStrength.strong;
  }

  Future<void> signUp() async {
    final displayName = displayNameController.text.trim();
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (displayName.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty) {
      error = 'Fill in every field to continue';
      notifyListeners();
      return;
    }
    if (password.length < 8) {
      error = 'Password must be at least 8 characters';
      notifyListeners();
      return;
    }
    if (!_agreedToTerms) {
      error = 'Please agree to the Terms and Fair Play Charter';
      notifyListeners();
      return;
    }

    dev.log('📝 SIGNUP ATTEMPT: Email: $email, Username: $username', name: 'AUTH');

    _isLoading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _auth.signUp(
        email: email,
        password: password,
        username: username,
      );

      result.fold(
        (signUpError) {
          dev.log(
            '❌ SIGNUP FAILED: ${signUpError.message}',
            name: 'AUTH',
            error: signUpError,
          );
          error = signUpError.message;
          _isLoading = false;
          notifyListeners();
          AppSnackbar.error(signUpError.message);
        },
        (response) async {
          dev.log('✅ SIGNUP SUCCESS: Token received', name: 'AUTH');

          if (response.token != null) {
            await _storage.saveToken(response.token!);
            dev.log('💾 TOKEN SAVED to storage', name: 'AUTH');
          }
          // displayName isn't part of the signup payload today — persist it
          // locally so the dashboard can greet the user, or send it along
          // once the API supports it.
          await _storage.addString('display_name', displayName);

          _isLoading = false;
          notifyListeners();

          AppSnackbar.success('Welcome to Zeendora! Your account is ready.');

          dev.log('🎯 NAVIGATING to onboarding', name: 'AUTH');
          Get.offAllNamed(Routes.onboarding);
        },
      );
    } catch (e) {
      dev.log('💥 SIGNUP EXCEPTION: $e', name: 'AUTH', error: e);
      error = 'Sign up failed: $e';
      _isLoading = false;
      notifyListeners();
      AppSnackbar.error(error!);
    }
  }

  void goToLogin() {
    dev.log('🔄 NAVIGATING to login screen from register', name: 'NAVIGATION');
    Get.toNamed(Routes.login);
  }

  @override
  void dispose() {
    passwordController.removeListener(notifyListeners);
    displayNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
