import 'package:get/get.dart';
import 'package:zendora_app/app/routes_names.dart';
import 'package:zendora_app/screens/auth/login/login_view.dart';
import 'package:zendora_app/screens/auth/register/register_view.dart';
import 'package:zendora_app/screens/auth/splash_view.dart';
import 'package:zendora_app/screens/dashboard/dashboard_view.dart';
import 'package:zendora_app/screens/dashboard/hub/hub_screen.dart';
import 'package:zendora_app/screens/dashboard/learn/learn_screen.dart';
import 'package:zendora_app/screens/dashboard/best/best_screen.dart';
import 'package:zendora_app/screens/dashboard/profile/profile_screen.dart';
import 'package:zendora_app/screens/onboarding/onboarding_screen.dart';

class AppPages {
  static final routes = [
    GetPage(name: Routes.SplashView, page: () => const SplashView()),
    GetPage(name: Routes.login, page: () => const LoginView()),
    GetPage(name: Routes.signup, page: () => const RegisterView()),
    GetPage(name: Routes.onboarding, page: () => const OnboardingScreen()),
    GetPage(name: Routes.dashboard, page: () => const DashboardView()),
    GetPage(name: Routes.hub, page: () => const HubScreen()),
    GetPage(name: Routes.learn, page: () => const LearnScreen()),
    GetPage(name: Routes.best, page: () => const BestScreen()),
    GetPage(name: Routes.profile, page: () => const ProfileScreen()),
  ];
}