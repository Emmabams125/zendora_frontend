import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;

import 'package:zendora_app/app/app_colours.dart';

/// Centralized snackbar styling so success/error feedback looks the same
/// everywhere (auth, dashboard, etc.) instead of every screen rolling its own.
class AppSnackbar {
  AppSnackbar._();

  static void success(String message, {String title = 'SUCCESS'}) {
    _show(title: title, message: message, accentColor: AppColours.accent, icon: Icons.check_circle);
  }

  static void error(String message, {String title = 'ERROR'}) {
    _show(title: title, message: message, accentColor: AppColours.danger, icon: Icons.error_outline);
  }

  static void _show({
    required String title,
    required String message,
    required Color accentColor,
    required IconData icon,
  }) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }

    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColours.surface,
      colorText: AppColours.textPrimary,
      icon: Icon(icon, color: accentColor),
      borderColor: accentColor,
      borderWidth: 1,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
      titleText: Text(
        title,
        style: AppTextStyles.label(color: accentColor),
      ),
      messageText: Text(
        message,
        style: const TextStyle(color: AppColours.textPrimary, fontSize: 13),
      ),
    );
  }
}
