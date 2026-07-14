import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zendora_app/app/app_colours.dart';
import 'package:zendora_app/screens/auth/register/register_form.dart';
import 'package:zendora_app/screens/auth/register/register_viewmodel.dart';
import 'package:zendora_app/screens/auth/widget/auth_step_header.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RegisterViewModel(),
      child: Scaffold(
        backgroundColor: AppColours.background,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            children: [
              const AuthTopBar(step: 2, totalSteps: 4),
              const SizedBox(height: 32),
              const AuthLogoBlock(
                kicker: 'NEW PROFILE',
                subtitle: 'JOIN THE GLOBAL PITCH',
              ),
              const SizedBox(height: 40),
              Text.rich(
                const TextSpan(
                  children: [
                    TextSpan(text: 'CLAIM YOUR\n', style: AppTextStyles.headline),
                    TextSpan(text: 'ZCP.', style: AppTextStyles.headlineAccent),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Free forever. No ads in feed. One identity across every Zeendora mode.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 36),
              const RegisterForm(),
              const SizedBox(height: 32),
              Center(
                child: Builder(
                  builder: (context) {
                    final vm = context.read<RegisterViewModel>();
                    return RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'ALREADY PLAYING? ',
                            style: AppTextStyles.label(),
                          ),
                          TextSpan(
                            text: 'SIGN IN  →',
                            style: AppTextStyles.label(color: AppColours.accent),
                            recognizer: (TapGestureRecognizer()..onTap = vm.goToLogin),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}