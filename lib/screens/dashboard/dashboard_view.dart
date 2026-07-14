import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zendora_app/app/app_colours.dart';
import 'package:zendora_app/app/locator.dart';
import 'package:zendora_app/core/constants/datasource/gtq/gtq_remote_data_source.dart';
import 'package:zendora_app/screens/dashboard/widget/dashboard_shared.dart';
import 'package:zendora_app/screens/dashboard/hub/hub_screen.dart';
import 'package:zendora_app/screens/dashboard/learn/learn_screen.dart';
import 'package:zendora_app/screens/dashboard/gtq/gtq_screen.dart';
import 'package:zendora_app/screens/dashboard/best/best_screen.dart';
import 'package:zendora_app/screens/dashboard/profile/profile_screen.dart';

class DashboardViewModel extends ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setIndex(int i) {
    if (_currentIndex == i) return;
    _currentIndex = i;
    notifyListeners();
  }
}

class DashboardView extends StatelessWidget {
  final int index;
  const DashboardView({super.key, this.index = 0});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardViewModel()..setIndex(index),
      child: Consumer<DashboardViewModel>(
        builder: (context, vm, _) => Scaffold(
          backgroundColor: AppColours.background,
          body: IndexedStack(
            sizing: StackFit.expand,
            index: vm.currentIndex,
            children: const [
              HubScreen(),
              LearnScreen(),
              SizedBox.shrink(), // GTQ opens full-screen, see onTap below
              BestScreen(),
              ProfileScreen(),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: DashboardBottomNav(
              currentIndex: vm.currentIndex,
              onTap: (i) {
                if (i == 2) {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (_) => GtqScreen(
                        fetcher: () => locator<GtqRemoteDataSource>()
                            .getQuestions(sport: 'football', count: 15),
                        source: 'GTQ',
                        categoryLabel: 'RANDOM',
                      ),
                      fullscreenDialog: true,
                    ),
                  );
                  return;
                }
                vm.setIndex(i);
              },
            ),
          ),
        ),
      ),
    );
  }
}
