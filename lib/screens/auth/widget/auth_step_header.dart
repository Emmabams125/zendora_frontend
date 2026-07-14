import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zendora_app/app/app_colours.dart';

/// Top "ZEENDORA / AUTH   01 / 04" bar + back button, shared by every
/// auth step screen so the flow stays visually consistent.
class AuthTopBar extends StatelessWidget {
  final int step;
  final int totalSteps;
  final VoidCallback? onBack;

  const AuthTopBar({
    super.key,
    required this.step,
    this.totalSteps = 4,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final stepLabel =
        '${step.toString().padLeft(2, '0')} / ${totalSteps.toString().padLeft(2, '0')}';

    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: AppColours.accent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Text('ZEENDORA / AUTH', style: AppTextStyles.label()),
            const Spacer(),
            Text(stepLabel, style: AppTextStyles.label()),
          ],
        ),
        const SizedBox(height: 20),
        Container(height: 1, color: AppColours.divider),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: onBack ?? () => Get.back(),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.arrow_back, size: 16, color: AppColours.textSecondary),
              const SizedBox(width: 8),
              Text('BACK', style: AppTextStyles.label()),
            ],
          ),
        ),
      ],
    );
  }
}

/// The "Z" mark + kicker/subtitle block used under the top bar.
class AuthLogoBlock extends StatelessWidget {
  final String kicker;
  final String subtitle;

  const AuthLogoBlock({
    super.key,
    required this.kicker,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              color: AppColours.accent,
              child: const Text(
                'Z',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppColours.accentText,
                ),
              ),
            ),
            Positioned(
              top: -3,
              right: -3,
              child: Container(width: 10, height: 10, color: Colors.white),
            ),
          ],
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(kicker, style: AppTextStyles.eyebrow()),
            const SizedBox(height: 2),
            Text(subtitle, style: AppTextStyles.label()),
          ],
        ),
      ],
    );
  }
}
