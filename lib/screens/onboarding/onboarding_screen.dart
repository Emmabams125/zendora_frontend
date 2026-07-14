import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:zendora_app/app/app_colours.dart';
import 'package:zendora_app/app/locator.dart';
import 'package:zendora_app/app/routes_names.dart';
import 'package:zendora_app/core/constants/datasource/profile/profile_remote_data_source.dart';
import 'package:zendora_app/core/constants/datasource/sports/sports_remote_data_source.dart';
import 'package:zendora_app/core/constants/models/entity_model.dart';
import 'package:zendora_app/core/constants/models/sport_model.dart';
import 'package:zendora_app/screens/dashboard/widget/dashboard_shared.dart';
import 'package:zendora_app/core/widgets/app_primary_button.dart';

class OnboardingViewModel extends ChangeNotifier {
  final SportsRemoteDataSource _sportsDs = locator<SportsRemoteDataSource>();
  final ProfileRemoteDataSource _profileDs = locator<ProfileRemoteDataSource>();

  OnboardingViewModel() {
    _loadSports();
  }

  bool isLoading = true;
  String? error;
  List<SportModel> sports = [];
  int? selectedSportId;

  bool isLoadingEntities = false;
  List<EntitySummaryModel> entities = [];
  final Set<int> selectedEntityIds = {};

  bool isSaving = false;

  Future<void> _loadSports() async {
    isLoading = true;
    error = null;
    notifyListeners();

    final res = await _sportsDs.getSports();
    res.fold(
      (err) {
        error = err.message;
        isLoading = false;
        notifyListeners();
      },
      (list) {
        sports = list;
        isLoading = false;
        final active = list.where((s) => s.isActive).toList();
        if (active.isNotEmpty) selectSport(active.first);
        notifyListeners();
      },
    );
  }

  Future<void> selectSport(SportModel sport) async {
    if (!sport.isActive) return;
    selectedSportId = sport.id;
    selectedEntityIds.clear();
    isLoadingEntities = true;
    notifyListeners();

    final res = await _sportsDs.getEntities(sport.key, 'CLUB', pageSize: 12);
    res.fold(
      (_) {
        entities = [];
        isLoadingEntities = false;
        notifyListeners();
      },
      (page) {
        entities = page.entities;
        isLoadingEntities = false;
        notifyListeners();
      },
    );
  }

  void toggleEntity(int id) {
    if (selectedEntityIds.contains(id)) {
      selectedEntityIds.remove(id);
    } else {
      selectedEntityIds.add(id);
    }
    notifyListeners();
  }

  Future<void> finish() async {
    if (selectedSportId == null) {
      Get.offAllNamed(Routes.dashboard);
      return;
    }
    isSaving = true;
    notifyListeners();

    await _profileDs.saveOnboarding(
      favoriteSportId: selectedSportId!,
      interestEntityIds: selectedEntityIds.toList(),
    );

    isSaving = false;
    Get.offAllNamed(Routes.dashboard);
  }

  void skip() => Get.offAllNamed(Routes.dashboard);
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OnboardingViewModel(),
      child: Scaffold(
        backgroundColor: AppColours.background,
        body: Consumer<OnboardingViewModel>(
          builder: (context, vm, _) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('SET UP YOUR PROFILE', style: AppTextStyles.eyebrow()),
                        GestureDetector(
                          onTap: vm.skip,
                          child: Text('SKIP', style: AppTextStyles.label(color: AppColours.textMuted)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('PICK YOUR SPORT\n& FAVORITE CLUBS.', style: AppTextStyles.headline),
                    const SizedBox(height: 28),
                    if (vm.isLoading)
                      const Expanded(child: LoadingBox(height: 300))
                    else if (vm.error != null)
                      Expanded(child: ErrorRetryBox(message: vm.error!, onRetry: vm._loadSports))
                    else
                      Expanded(
                        child: ListView(
                          children: [
                            const SectionLabel(tag: 'A', title: 'SPORT'),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: vm.sports.map((s) {
                                final selected = vm.selectedSportId == s.id;
                                return GestureDetector(
                                  onTap: () => vm.selectSport(s),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: selected ? AppColours.accent : Colors.transparent,
                                      border: Border.all(color: selected ? AppColours.accent : AppColours.border),
                                    ),
                                    child: Text(
                                      s.isActive ? s.name.toUpperCase() : '${s.name.toUpperCase()} · SOON',
                                      style: AppTextStyles.label(
                                        color: selected ? AppColours.accentText : (s.isActive ? AppColours.textPrimary : AppColours.textMuted),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 28),
                            const SectionLabel(tag: 'B', title: 'FOLLOW A FEW CLUBS'),
                            const SizedBox(height: 12),
                            if (vm.isLoadingEntities) const LoadingBox(height: 120),
                            if (!vm.isLoadingEntities)
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: vm.entities.map((e) {
                                  final selected = vm.selectedEntityIds.contains(e.id);
                                  return GestureDetector(
                                    onTap: () => vm.toggleEntity(e.id),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: selected ? AppColours.accent : Colors.transparent,
                                        border: Border.all(color: selected ? AppColours.accent : AppColours.border),
                                      ),
                                      child: Text(
                                        e.name.toUpperCase(),
                                        style: AppTextStyles.label(color: selected ? AppColours.accentText : AppColours.textPrimary),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    AppPrimaryButton(
                      onPressed: vm.finish,
                      loading: vm.isSaving,
                      label: 'CONTINUE',
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
