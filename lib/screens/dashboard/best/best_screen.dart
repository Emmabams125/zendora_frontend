import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zendora_app/app/app_colours.dart';
import 'package:zendora_app/app/locator.dart';
import 'package:zendora_app/core/constants/datasource/best/best_remote_data_source.dart';
import 'package:zendora_app/core/constants/models/best_model.dart';
import 'package:zendora_app/screens/dashboard/best/entity_leaderboard_screen.dart';
import 'package:zendora_app/screens/dashboard/learn/category_entities_screen.dart';
import 'package:zendora_app/screens/dashboard/profile/public_profile_screen.dart';
import 'package:zendora_app/screens/dashboard/widget/dashboard_shared.dart';

String formatThousands(int value) {
  final s = value.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i != 0 && (s.length - i) % 3 == 0) buffer.write(',');
    buffer.write(s[i]);
  }
  return buffer.toString();
}

class BestViewModel extends ChangeNotifier {
  final BestRemoteDataSource _ds = locator<BestRemoteDataSource>();

  BestViewModel() {
    _loadLeaderboard();
    _loadCategories();
  }

  int selectedScope = 0;
  final List<String> scopes = const ['GLOBAL', 'FRIENDS', 'CLUB', 'COUNTRY'];

  bool isLoadingLeaderboard = true;
  String? leaderboardError;
  BestLeaderboardModel? leaderboard;

  bool isLoadingCategories = true;
  String? categoriesError;
  List<BestCategoryModel> categories = [];

  Future<void> selectScope(int i) async {
    if (selectedScope == i) return;
    selectedScope = i;
    notifyListeners();
    await _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    isLoadingLeaderboard = true;
    leaderboardError = null;
    notifyListeners();

    final res = await _ds.getLeaderboard(scope: scopes[selectedScope]);
    res.fold(
      (err) {
        leaderboardError = err.message;
        isLoadingLeaderboard = false;
        notifyListeners();
      },
      (l) {
        leaderboard = l;
        isLoadingLeaderboard = false;
        notifyListeners();
      },
    );
  }

  Future<void> retryLeaderboard() => _loadLeaderboard();

  Future<void> _loadCategories() async {
    isLoadingCategories = true;
    categoriesError = null;
    notifyListeners();

    final res = await _ds.getCategories();
    res.fold(
      (err) {
        categoriesError = err.message;
        isLoadingCategories = false;
        notifyListeners();
      },
      (c) {
        categories = c;
        isLoadingCategories = false;
        notifyListeners();
      },
    );
  }

  Future<void> refreshCategories() => _loadCategories();
}

class BestScreen extends StatelessWidget {
  const BestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BestViewModel(),
      child: Consumer<BestViewModel>(
        builder: (context, vm, _) => SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              const DashboardTopBar(left: 'BEST MODE · LIVE', right: 'BEST / 04'),
              const SizedBox(height: 24),
              Text('BEST MODE', style: AppTextStyles.eyebrow()),
              const SizedBox(height: 8),
              const Text('BE THE BEST.\nPICK YOUR LANE.', style: AppTextStyles.headline),
              const SizedBox(height: 12),
              const Text(
                'Focus on a club, player, league or competition. Answer focused questions to climb the table.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: 24),
              _ScopeTabs(vm: vm),
              const SizedBox(height: 24),
              if (vm.isLoadingLeaderboard)
                const LoadingBox(height: 120)
              else if (vm.leaderboardError != null)
                ErrorRetryBox(message: vm.leaderboardError!, onRetry: vm.retryLeaderboard)
              else ...[
                if (vm.leaderboard?.yourPosition != null) _YourPositionCard(vm: vm),
                const SizedBox(height: 32),
                SectionLabel(tag: 'A', title: 'LEADERBOARD · ${vm.scopes[vm.selectedScope]}'),
                const SizedBox(height: 12),
                if (vm.leaderboard!.leaderboard.isEmpty)
                  Text('No players ranked here yet.', style: AppTextStyles.body)
                else
                  ...vm.leaderboard!.leaderboard.map((e) => _LeaderboardRow(entry: e)),
              ],
              const SizedBox(height: 28),
              const SectionLabel(tag: 'B', title: 'PICK A BEST MODE'),
              const SizedBox(height: 12),
              if (vm.isLoadingCategories)
                const LoadingBox(height: 120)
              else if (vm.categoriesError != null)
                ErrorRetryBox(message: vm.categoriesError!, onRetry: vm.refreshCategories)
              else
                ...vm.categories.map((c) => _BestModeRow(category: c, vm: vm)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScopeTabs extends StatelessWidget {
  final BestViewModel vm;
  const _ScopeTabs({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(vm.scopes.length, (i) {
        final active = i == vm.selectedScope;
        return Expanded(
          child: GestureDetector(
            onTap: () => vm.selectScope(i),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 14),
              color: active ? AppColours.accent : Colors.transparent,
              child: Text(vm.scopes[i], style: AppTextStyles.label(color: active ? AppColours.accentText : AppColours.textMuted)),
            ),
          ),
        );
      }),
    );
  }
}

class _YourPositionCard extends StatelessWidget {
  final BestViewModel vm;
  const _YourPositionCard({required this.vm});

  @override
  Widget build(BuildContext context) {
    final pos = vm.leaderboard!.yourPosition!;
    return Container(
      decoration: BoxDecoration(border: Border.all(color: AppColours.accent)),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('YOUR POSITION', style: AppTextStyles.label(color: AppColours.accent)),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('RANK', style: AppTextStyles.label(color: AppColours.textMuted)),
                    const SizedBox(height: 6),
                    Text('#${pos.rank}', style: const TextStyle(color: AppColours.accent, fontWeight: FontWeight.w800, fontSize: 34)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text('XP', style: AppTextStyles.label(color: AppColours.textMuted)),
                    const SizedBox(height: 6),
                    Text(formatThousands(pos.xp),
                        style: const TextStyle(color: AppColours.textPrimary, fontWeight: FontWeight.w800, fontSize: 24)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final LeaderboardEntryModel entry;
  const _LeaderboardRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final isTop = entry.rank <= 3;
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PublicProfileScreen(username: entry.username)),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColours.divider))),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isTop ? AppColours.accent : Colors.transparent,
                border: Border.all(color: isTop ? AppColours.accent : AppColours.border),
              ),
              child: Text(
                entry.rank.toString().padLeft(2, '0'),
                style: TextStyle(
                  color: isTop ? AppColours.accentText : AppColours.textMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.username, style: const TextStyle(color: AppColours.textPrimary, fontWeight: FontWeight.w800, fontSize: 16)),
                  if (entry.country != null) ...[
                    const SizedBox(height: 2),
                    Text(entry.country!, style: AppTextStyles.label(color: AppColours.textMuted).copyWith(fontSize: 10)),
                  ],
                ],
              ),
            ),
            Text(formatThousands(entry.xp), style: const TextStyle(color: AppColours.textPrimary, fontWeight: FontWeight.w800, fontSize: 16)),
            if (isTop) ...[
              const SizedBox(width: 10),
              const Icon(Icons.emoji_events, color: AppColours.accent, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}

class _BestModeRow extends StatelessWidget {
  final BestCategoryModel category;
  final BestViewModel vm;
  const _BestModeRow({required this.category, required this.vm});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (category.picked && category.entity != null) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => EntityLeaderboardScreen(entityId: category.entity!.id)),
          );
        } else {
          final picked = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => CategoryEntitiesScreen(
                sportKey: 'football',
                type: category.type,
                categoryTitle: category.type,
                pickMode: true,
              ),
            ),
          );
          if (picked == true) vm.refreshCategories();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColours.divider))),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(category.type, style: AppTextStyles.label(color: AppColours.textMuted)),
                  const SizedBox(height: 6),
                  Text(
                    category.picked ? category.entity!.name : 'Not picked yet',
                    style: const TextStyle(color: AppColours.textPrimary, fontWeight: FontWeight.w800, fontSize: 18),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    category.picked ? 'Tap to view leaderboard' : 'Tap to choose who you specialize in',
                    style: AppTextStyles.body,
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColours.textMuted),
          ],
        ),
      ),
    );
  }
}
