import 'package:flutter/material.dart';
import 'package:zendora_app/app/app_colours.dart';
/// "[01]  EMAIL OR USERNAME" style labeled field used across the auth flow.
class AuthTextField extends StatelessWidget {
  final String index;
  final String label;
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? trailing;
  final Widget? topTrailing; // e.g. "FORGOT?" link next to the label
  final TextInputType? keyboardType;

  const AuthTextField({
    super.key,
    required this.index,
    required this.label,
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.trailing,
    this.topTrailing,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '[$index] ',
                    style: AppTextStyles.label(color: AppColours.textMuted),
                  ),
                  TextSpan(text: label, style: AppTextStyles.label()),
                ],
              ),
            ),
            if (topTrailing != null) topTrailing!,
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColours.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  keyboardType: keyboardType,
                  style: AppTextStyles.inputText,
                  cursorColor: AppColours.accent,
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: AppTextStyles.inputHint,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ],
    );
  }
}
