import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zendora_app/app/app_colours.dart';

import 'package:zendora_app/screens/auth/login/login_viewmodel.dart';
import 'package:zendora_app/screens/auth/widget/auth_text_field.dart';
import 'package:zendora_app/core/widgets/app_primary_button.dart';

class LoginForm extends StatelessWidget {
  const LoginForm({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LoginViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthTextField(
          index: '01',
          label: 'EMAIL OR USERNAME',
          hint: 'alex.striker@zeendora.fb',
          controller: vm.emailController,
          keyboardType: TextInputType.emailAddress,
          trailing: const Icon(Icons.mail_outline,
              color: AppColours.textMuted, size: 20),
        ),
        const SizedBox(height: 24),
        AuthTextField(
          index: '02',
          label: 'PASSWORD',
          hint: '••••••••',
          controller: vm.passwordController,
          obscureText: vm.obscurePassword,
          topTrailing: GestureDetector(
            onTap: () {
              // TODO: wire to forgot-password flow.
            },
            child: Text('FORGOT?', style: AppTextStyles.label(color: AppColours.accent)),
          ),
          trailing: GestureDetector(
            onTap: vm.toggleObscurePassword,
            child: Icon(
              vm.obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: AppColours.textMuted,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => vm.toggleKeepSignedIn(!vm.keepSignedIn),
          child: Row(
            children: [
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: vm.keepSignedIn ? AppColours.accent : Colors.transparent,
                  border: Border.all(
                    color: vm.keepSignedIn ? AppColours.accent : AppColours.border,
                  ),
                ),
                child: vm.keepSignedIn
                    ? const Icon(Icons.check, size: 14, color: AppColours.accentText)
                    : null,
              ),
              const SizedBox(width: 12),
              Text('KEEP ME SIGNED IN ON THIS DEVICE', style: AppTextStyles.label()),
            ],
          ),
        ),
        if (vm.error != null) ...[
          const SizedBox(height: 16),
          Text(vm.error!, style: const TextStyle(color: AppColours.danger, fontSize: 13)),
        ],
        const SizedBox(height: 28),
        AppPrimaryButton(
          onPressed: vm.login,
          loading: vm.isLoading,
          label: 'SIGN IN',
          icon: Icons.arrow_forward,
          verticalPadding: 20,
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            const Expanded(child: Divider(color: AppColours.divider)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('OR CONTINUE WITH', style: AppTextStyles.label(color: AppColours.textMuted)),
            ),
            const Expanded(child: Divider(color: AppColours.divider)),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: _SocialButton(icon: Icons.g_mobiledata, label: 'GOOGLE')),
            const SizedBox(width: 16),
            Expanded(child: _SocialButton(icon: Icons.apple, label: 'APPLE')),
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const _SocialButton({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: () {
        // TODO: wire to Google / Apple sign-in.
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColours.border),
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: const RoundedRectangleBorder(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: AppColours.textPrimary),
          const SizedBox(width: 8),
          Text(label,
              style: const TextStyle(
                color: AppColours.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              )),
        ],
      ),
    );
  }
}
