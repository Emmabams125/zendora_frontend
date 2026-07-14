import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:zendora_app/app/app_colours.dart';
import 'package:zendora_app/app/app_config.dart';
import 'package:zendora_app/app/locator.dart';
import 'package:zendora_app/core/constants/datasource/achievements/achievements_remote_data_source.dart';
import 'package:zendora_app/core/constants/datasource/profile/profile_remote_data_source.dart';
import 'package:zendora_app/core/constants/models/achievement_model.dart';
import 'package:zendora_app/core/constants/models/profile_model.dart';
import 'package:zendora_app/screens/dashboard/widget/dashboard_shared.dart';
import 'package:zendora_app/core/widgets/app_primary_button.dart';

class ProfileViewModel extends ChangeNotifier {
  final ProfileRemoteDataSource _profileDs = locator<ProfileRemoteDataSource>();
  final AchievementsRemoteDataSource _achievementsDs = locator<AchievementsRemoteDataSource>();

  ProfileViewModel() {
    _load();
  }

  bool isLoading = true;
  String? error;
  ZcpProfileModel? profile;
  List<AchievementModel> achievements = [];

  bool isSavingEdit = false;
  String? editError;

  bool isUploadingAvatar = false;

  Future<void> _load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    final profileRes = await _profileDs.getMe();
    final achievementsRes = await _achievementsDs.getAll();

    profileRes.fold(
      (err) {
        error = err.message;
      },
      (p) => profile = p,
    );
    achievementsRes.fold(
      (_) {},
      (a) => achievements = a.achievements,
    );

    isLoading = false;
    notifyListeners();
  }

  Future<void> retry() => _load();

  Future<bool> saveEdit({
    required String username,
    String? title,
    String? country,
    String? bio,
  }) async {
    isSavingEdit = true;
    editError = null;
    notifyListeners();

    final res = await _profileDs.updateMe(
      username: username,
      title: title,
      country: country,
      bio: bio,
    );

    bool success = false;
    res.fold(
      (err) => editError = err.message,
      (_) => success = true,
    );
    isSavingEdit = false;
    notifyListeners();

    if (success) await _load();
    return success;
  }

  Future<void> pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (xfile == null) return;

    isUploadingAvatar = true;
    notifyListeners();

    final res = await _profileDs.uploadAvatar(File(xfile.path));
    res.fold((_) {}, (_) {});

    isUploadingAvatar = false;
    notifyListeners();
    await _load();
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileViewModel(),
      child: Consumer<ProfileViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const SafeArea(child: Center(child: LoadingBox(height: 160)));
          }
          if (vm.error != null || vm.profile == null) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ErrorRetryBox(message: vm.error ?? 'Could not load your profile', onRetry: vm.retry),
              ),
            );
          }

          final p = vm.profile!;
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                const DashboardTopBar(left: 'ZCP · CARD PROFILE', right: 'PROFILE / 05'),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ID · ${p.znd}', style: AppTextStyles.label(color: AppColours.textMuted)),
                    Row(
                      children: [
                        _IconButton(icon: Icons.ios_share, onTap: () {}),
                        const SizedBox(width: 10),
                        _IconButton(
                          icon: Icons.settings_outlined,
                          onTap: () => _showEditSheet(context, vm),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _ProfileCard(profile: p, vm: vm),
                const SizedBox(height: 32),
                if (p.performance != null) ...[
                  const SectionLabel(tag: 'A', title: 'PERFORMANCE'),
                  const SizedBox(height: 16),
                  _PerformanceGrid(performance: p.performance!),
                  const SizedBox(height: 32),
                ],
                if (p.masteryCategories.isNotEmpty) ...[
                  const SectionLabel(tag: 'B', title: 'MASTERY CATEGORIES'),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(border: Border.all(color: AppColours.border)),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(children: p.masteryCategories.map((m) => _MasteryRow(category: m)).toList()),
                  ),
                  const SizedBox(height: 32),
                ],
                SectionLabel(
                  tag: 'C',
                  title: 'ACHIEVEMENTS · ${vm.achievements.where((a) => a.unlocked).length} OF ${vm.achievements.length}',
                ),
                const SizedBox(height: 16),
                _AchievementsGrid(achievements: vm.achievements),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showEditSheet(BuildContext context, ProfileViewModel vm) {
    final p = vm.profile!;
    final usernameCtrl = TextEditingController(text: p.username);
    final titleCtrl = TextEditingController(text: p.title ?? '');
    final countryCtrl = TextEditingController(text: p.country ?? '');
    final bioCtrl = TextEditingController(text: p.bio ?? '');

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColours.background,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(sheetContext).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('EDIT PROFILE', style: AppTextStyles.eyebrow()),
              const SizedBox(height: 20),
              _EditField(label: 'USERNAME', controller: usernameCtrl),
              const SizedBox(height: 14),
              _EditField(label: 'TITLE', controller: titleCtrl),
              const SizedBox(height: 14),
              _EditField(label: 'COUNTRY', controller: countryCtrl),
              const SizedBox(height: 14),
              _EditField(label: 'BIO', controller: bioCtrl, maxLines: 3),
              const SizedBox(height: 20),
              AppPrimaryButton(
                onPressed: () async {
                  final ok = await vm.saveEdit(
                    username: usernameCtrl.text.trim(),
                    title: titleCtrl.text.trim(),
                    country: countryCtrl.text.trim(),
                    bio: bioCtrl.text.trim(),
                  );
                  if (ok && sheetContext.mounted) Navigator.of(sheetContext).pop();
                },
                loading: vm.isSavingEdit,
                label: 'SAVE',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EditField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  const _EditField({required this.label, required this.controller, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label(color: AppColours.textMuted)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(border: Border.all(color: AppColours.border)),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: AppTextStyles.inputText,
            cursorColor: AppColours.accent,
            decoration: const InputDecoration(border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.symmetric(vertical: 14)),
          ),
        ),
      ],
    );
  }
}

class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(border: Border.all(color: AppColours.border)),
        alignment: Alignment.center,
        child: Icon(icon, size: 18, color: AppColours.textPrimary),
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final ZcpProfileModel profile;
  final ProfileViewModel vm;
  const _ProfileCard({required this.profile, required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: AppColours.accent)),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: vm.pickAndUploadAvatar,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      color: AppColours.surface,
                      alignment: Alignment.center,
                      child: vm.isUploadingAvatar
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColours.accent),
                            )
                          : (AppConfig.resolveMediaUrl(profile.avatarUrl) != null
                              ? Image.network(
                                  AppConfig.resolveMediaUrl(profile.avatarUrl)!,
                                  fit: BoxFit.cover,
                                  width: 84,
                                  height: 84,
                                )
                              : const Icon(Icons.person, color: AppColours.textMuted, size: 32)),
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
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ZEENDORA CARD PROFILE', style: AppTextStyles.label(color: AppColours.accent)),
                    const SizedBox(height: 6),
                    Text(profile.username, style: const TextStyle(color: AppColours.textPrimary, fontWeight: FontWeight.w800, fontSize: 22)),
                    const SizedBox(height: 6),
                    if (profile.title != null || profile.country != null)
                      Text([profile.title, profile.country].where((e) => e != null).join(' · '), style: AppTextStyles.body),
                    if (profile.bio != null && profile.bio!.isNotEmpty) Text(profile.bio!, style: AppTextStyles.body),
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
        Text(value != null ? '#$value' : '—', style: const TextStyle(color: AppColours.textPrimary, fontWeight: FontWeight.w800, fontSize: 18)),
      ],
    );
  }
}

class _PerformanceGrid extends StatelessWidget {
  final ProfilePerformanceModel performance;
  const _PerformanceGrid({required this.performance});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: AppColours.border)),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _PerfCell(icon: Icons.track_changes, label: 'ACCURACY', value: performance.accuracy.toStringAsFixed(1), suffix: '%')),
              Container(width: 1, height: 100, color: AppColours.border),
              Expanded(child: _PerfCell(icon: Icons.bolt, label: 'STREAK', value: '${performance.currentStreak}', suffix: 'd')),
            ],
          ),
          Container(height: 1, color: AppColours.border),
          Row(
            children: [
              Expanded(child: _PerfCell(icon: Icons.adjust, label: 'ANSWERED', value: '${performance.answered}', suffix: '')),
              Container(width: 1, height: 100, color: AppColours.border),
              Expanded(
                child: _PerfCell(
                  icon: Icons.emoji_events_outlined,
                  label: 'MASTERY',
                  value: '${performance.mastery.unlocked}/${performance.mastery.total}',
                  suffix: '',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PerfCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String suffix;
  const _PerfCell({required this.icon, required this.label, required this.value, required this.suffix});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 16, color: AppColours.textMuted),
              Text(label, style: AppTextStyles.label(color: AppColours.textMuted).copyWith(fontSize: 9)),
            ],
          ),
          const SizedBox(height: 16),
          Text.rich(
            TextSpan(
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColours.textPrimary),
              children: [
                TextSpan(text: value),
                TextSpan(text: suffix, style: const TextStyle(color: AppColours.accent, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MasteryRow extends StatelessWidget {
  final MasteryCategoryModel category;
  const _MasteryRow({required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColours.divider))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(category.title, style: const TextStyle(color: AppColours.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
              Text(category.level, style: AppTextStyles.label(color: AppColours.textMuted).copyWith(fontSize: 10)),
            ],
          ),
          const SizedBox(height: 10),
          ProgressTrack(progress: category.progress, height: 3),
        ],
      ),
    );
  }
}

class _AchievementsGrid extends StatelessWidget {
  final List<AchievementModel> achievements;
  const _AchievementsGrid({required this.achievements});

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) {
      return Text('No achievements yet.', style: AppTextStyles.body);
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: achievements.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, i) {
        final a = achievements[i];
        return Tooltip(
          message: a.title,
          child: Container(
            decoration: BoxDecoration(border: Border.all(color: a.unlocked ? AppColours.accent : AppColours.border)),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events, size: 22, color: a.unlocked ? AppColours.accent : AppColours.textMuted.withOpacity(0.4)),
                const SizedBox(height: 6),
                Text(
                  '#${(i + 1).toString().padLeft(2, '0')}',
                  style: AppTextStyles.label(color: a.unlocked ? AppColours.accent : AppColours.textMuted.withOpacity(0.4)).copyWith(fontSize: 10),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
