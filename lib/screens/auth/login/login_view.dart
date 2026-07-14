import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zendora_app/app/app_colours.dart';
import 'package:zendora_app/screens/auth/login/login_form.dart';
import 'package:zendora_app/screens/auth/login/login_viewmodel.dart';
import 'package:zendora_app/screens/auth/widget/auth_step_header.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: Scaffold(
        backgroundColor: AppColours.background,
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            children: [
              const AuthTopBar(step: 1, totalSteps: 4),
              const SizedBox(height: 32),
              const AuthLogoBlock(
                kicker: 'SIGN IN',
                subtitle: 'WELCOME BACK, FAN',
              ),
              const SizedBox(height: 40),
              Text.rich(
                const TextSpan(
                  children: [
                    TextSpan(text: 'RESUME THE\n', style: AppTextStyles.headline),
                    TextSpan(text: 'MATCH.', style: AppTextStyles.headlineAccent),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Your streak, XP and rank are waiting. Pick up exactly where you left off.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 36),
              const LoginForm(),
              const SizedBox(height: 36),
              Center(
                child: Builder(
                  builder: (context) {
                    final vm = context.read<LoginViewModel>();
                    return RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'NEW TO ZEENDORA? ',
                            style: AppTextStyles.label(),
                          ),
                          TextSpan(
                            text: 'CREATE ACCOUNT  →',
                            style: AppTextStyles.label(color: AppColours.accent),
                            recognizer: (TapGestureRecognizer()..onTap = vm.goToRegister),
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
