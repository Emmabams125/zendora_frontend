import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zendora_app/app/app_colours.dart';
import 'package:zendora_app/screens/auth/register/register_viewmodel.dart';
import 'package:zendora_app/screens/auth/widget/auth_text_field.dart';
import 'package:zendora_app/core/widgets/app_primary_button.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegisterViewModel>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthTextField(
          index: '01',
          label: 'DISPLAY NAME',
          hint: 'Alex Striker',
          controller: vm.displayNameController,
        ),
        const SizedBox(height: 24),
        AuthTextField(
          index: '02',
          label: 'USERNAME',
          hint: '@alex.striker',
          controller: vm.usernameController,
        ),
        const SizedBox(height: 24),
        AuthTextField(
          index: '03',
          label: 'EMAIL',
          hint: 'you@zeendora.fb',
          controller: vm.emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),
        AuthTextField(
          index: '04',
          label: 'PASSWORD',
          hint: 'At least 8 characters',
          controller: vm.passwordController,
          obscureText: vm.obscurePassword,
          trailing: GestureDetector(
            onTap: vm.toggleObscurePassword,
            child: Icon(
              vm.obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: AppColours.textMuted,
              size: 20,
            ),
          ),
        ),
        const SizedBox(height: 12),
        _PasswordStrengthMeter(strength: vm.passwordStrength),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () => vm.toggleAgreedToTerms(!vm.agreedToTerms),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 20,
                height: 20,
                margin: const EdgeInsets.only(top: 1),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: vm.agreedToTerms ? AppColours.accent : Colors.transparent,
                  border: Border.all(
                    color: vm.agreedToTerms ? AppColours.accent : AppColours.border,
                  ),
                ),
                child: vm.agreedToTerms
                    ? const Icon(Icons.check, size: 14, color: AppColours.accentText)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: AppTextStyles.label(),
                    children: const [
                      TextSpan(text: 'I AGREE TO THE '),
                      TextSpan(text: 'TERMS', style: TextStyle(color: AppColours.accent)),
                      TextSpan(text: ' AND '),
                      TextSpan(text: 'FAIR PLAY CHARTER', style: TextStyle(color: AppColours.accent)),
                      TextSpan(text: '.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (vm.error != null) ...[
          const SizedBox(height: 16),
          Text(vm.error!, style: const TextStyle(color: AppColours.danger, fontSize: 13)),
        ],
        const SizedBox(height: 28),
        AppPrimaryButton(
          onPressed: vm.signUp,
          loading: vm.isLoading,
          label: 'CREATE ACCOUNT',
          icon: Icons.arrow_forward,
          verticalPadding: 20,
        ),
      ],
    );
  }
}

class _PasswordStrengthMeter extends StatelessWidget {
  final PasswordStrength strength;

  const _PasswordStrengthMeter({required this.strength});

  int get _filledBars {
    switch (strength) {
      case PasswordStrength.empty:
        return 0;
      case PasswordStrength.weak:
        return 1;
      case PasswordStrength.medium:
        return 2;
      case PasswordStrength.strong:
        return 3;
    }
  }

  String get _label {
    switch (strength) {
      case PasswordStrength.empty:
        return '';
      case PasswordStrength.weak:
        return 'WEAK';
      case PasswordStrength.medium:
        return 'MEDIUM';
      case PasswordStrength.strong:
        return 'STRONG';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 3; i++) ...[
          Expanded(
            child: Container(
              height: 3,
              color: i < _filledBars ? AppColours.accent : AppColours.border,
            ),
          ),
          if (i != 2) const SizedBox(width: 6),
        ],
        const SizedBox(width: 12),
        SizedBox(
          width: 60,
          child: Text(
            _label,
            textAlign: TextAlign.right,
            style: AppTextStyles.label(color: AppColours.accent),
          ),
        ),
      ],
    );
  }
}
