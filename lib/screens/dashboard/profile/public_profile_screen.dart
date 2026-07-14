import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zendora_app/app/app_colours.dart';
import 'package:zendora_app/app/locator.dart';
import 'package:zendora_app/core/constants/datasource/profile/profile_remote_data_source.dart';
import 'package:zendora_app/core/constants/models/profile_model.dart';
import 'package:zendora_app/screens/dashboard/widget/dashboard_shared.dart';

class PublicProfileViewModel extends ChangeNotifier {
  final String username;
  final ProfileRemoteDataSource _ds = locator<ProfileRemoteDataSource>();

  PublicProfileViewModel(this.username) {
    _load();
  }

  bool isLoading = true;
  String? error;
  ZcpProfileModel? profile;

  Future<void> _load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    final res = await _ds.getPublicProfile(username);
    res.fold(
      (err) {
        error = err.message;
        isLoading = false;
        notifyListeners();
      },
      (p) {
        profile = p;
        isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> retry() => _load();
}

class PublicProfileScreen extends StatelessWidget {
  final String username;
  const PublicProfileScreen({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PublicProfileViewModel(username),
      child: Scaffold(
        backgroundColor: AppColours.background,
        body: Consumer<PublicProfileViewModel>(
          builder: (context, vm, _) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.maybePop(context),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(border: Border.all(color: AppColours.border)),
                            alignment: Alignment.center,
                            child: const Icon(Icons.arrow_back, size: 16, color: AppColours.textPrimary),
                          ),
                        ),
                        const Spacer(),
                        Text('PROFILE', style: AppTextStyles.label()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (vm.isLoading) const Expanded(child: LoadingBox(height: 300)),
                    if (!vm.isLoading && vm.error != null)
                      Expanded(child: ErrorRetryBox(message: vm.error!, onRetry: vm.retry)),
                    if (!vm.isLoading && vm.profile != null)
                      Expanded(child: _Content(profile: vm.profile!)),
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

class _Content extends StatelessWidget {
  final ZcpProfileModel profile;
  const _Content({required this.profile});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          decoration: BoxDecoration(border: Border.all(color: AppColours.accent)),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 84,
                        height: 84,
                        color: AppColours.surface,
                        alignment: Alignment.center,
                        child: const Icon(Icons.person, color: AppColours.textMuted, size: 32),
                      ),
                      Positioned(
                        bottom: -8,
                        right: -8,
                        child: Container(
                          width: 28,
                          height: 28,
                          color: AppColours.accent,
                          alignment: Alignment.center,
                          child: Text(
                            profile.progression.level.toString().padLeft(2, '0'),
                            style: const TextStyle(color: AppColours.accentText, fontWeight: FontWeight.w800, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ZCP · ${profile.znd}', style: AppTextStyles.label(color: AppColours.accent)),
                        const SizedBox(height: 6),
                        Text(profile.username, style: const TextStyle(color: AppColours.textPrimary, fontWeight: FontWeight.w800, fontSize: 22)),
                        if (profile.title != null || profile.country != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            [profile.title, profile.country].where((e) => e != null).join(' · '),
                            style: AppTextStyles.body,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Level ${profile.progression.level}', style: AppTextStyles.label()),
                  Text('${profile.progression.xp} XP', style: AppTextStyles.label(color: AppColours.accent)),
                ],
              ),
              const SizedBox(height: 10),
              ProgressTrack(progress: profile.progression.percent / 100),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _RankCell(label: 'GLOBAL', value: profile.ranks.global)),
                  Expanded(child: _RankCell(label: 'COUNTRY', value: profile.ranks.country)),
                  Expanded(child: _RankCell(label: 'CLUB', value: profile.ranks.club)),
                ],
              ),
            ],
          ),
        ),
        if (profile.currentStreak != null) ...[
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(border: Border.all(color: AppColours.border)),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department, size: 16, color: AppColours.accent),
                const SizedBox(width: 8),
                Text('${profile.currentStreak}-DAY STREAK', style: AppTextStyles.label()),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _RankCell extends StatelessWidget {
  final String label;
  final int? value;
  const _RankCell({required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label(color: AppColours.textMuted).copyWith(fontSize: 10)),
        const SizedBox(height: 6),
        Text(
          value != null ? '#$value' : '—',
          style: const TextStyle(color: AppColours.textPrimary, fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ],
    );
  }
}
