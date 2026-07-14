import 'package:flutter/material.dart';

import 'package:zendora_app/app/app_colours.dart';

/// Full-width accent submit button used across auth, onboarding and quiz
/// flows. Centralizes the loading/disabled styling so a button never falls
/// back to Flutter's default (near-invisible) disabled look when its
/// `onPressed` is nulled out for a loading or not-ready state.
class AppPrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool loading;
  final String label;
  final IconData? icon;
  final double verticalPadding;

  const AppPrimaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.loading = false,
    this.icon,
    this.verticalPadding = 18,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null && !loading;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: disabled ? AppColours.border : AppColours.accent,
          foregroundColor: disabled ? AppColours.textMuted : AppColours.accentText,
          disabledBackgroundColor: loading ? AppColours.accent : AppColours.border,
          disabledForegroundColor: loading ? AppColours.accentText : AppColours.textMuted,
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          shape: const RoundedRectangleBorder(),
          elevation: 0,
        ),
        child: loading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColours.accentText,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(icon, size: 18),
                  ],
                ],
              ),
      ),
    );
  }
}
