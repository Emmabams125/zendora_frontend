import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zendora_app/app/app_colours.dart';
import 'package:zendora_app/app/locator.dart';
import 'package:zendora_app/core/constants/datasource/gtq/gtq_remote_data_source.dart';
import 'package:zendora_app/core/constants/datasource/hub/hub_remote_data_source.dart';
import 'package:zendora_app/core/constants/models/hub_model.dart';
import 'package:zendora_app/screens/dashboard/dashboard_view.dart';
import 'package:zendora_app/screens/dashboard/gtq/gtq_screen.dart';
import 'package:zendora_app/screens/dashboard/learn/track_detail_screen.dart';
import 'package:zendora_app/screens/dashboard/widget/dashboard_shared.dart';

class HubViewModel extends ChangeNotifier {
  final HubRemoteDataSource _ds = locator<HubRemoteDataSource>();

  HubViewModel() {
    _load();
  }

  bool isLoading = true;
  String? error;
  HubModel? hub;

  Future<void> _load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    final res = await _ds.getHub();
    res.fold(
      (err) {
        error = err.message;
        isLoading = false;
        notifyListeners();
      },
      (h) {
        hub = h;
        isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> retry() => _load();

  String get challengeExpiry {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final left = midnight.difference(now);
    return '${left.inHours}H ${left.inMinutes % 60}M';
  }
}

class HubScreen extends StatelessWidget {
  const HubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HubViewModel(),
      child: Consumer<HubViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const SafeArea(child: Center(child: LoadingBox(height: 160)));
          }
          if (vm.error != null || vm.hub == null) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ErrorRetryBox(message: vm.error ?? 'Could not load your hub', onRetry: vm.retry),
              ),
            );
          }

          final hub = vm.hub!;
          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                const DashboardTopBar(left: 'LIVE · MATCHDAY', right: 'HUB / 01'),
                const SizedBox(height: 28),
                _WelcomeHeader(hub: hub),
                const SizedBox(height: 24),
                _XpBar(hub: hub),
                const SizedBox(height: 36),
                if (hub.dailyChallenge != null) ...[
                  const SectionLabel(tag: 'A', title: 'DAILY CHALLENGE'),
                  const SizedBox(height: 16),
                  _DailyChallengeCard(hub: hub, vm: vm),
                  const SizedBox(height: 36),
                ],
                const SectionLabel(tag: 'B', title: 'CONTINUE LEARNING'),
                const SizedBox(height: 16),
                if (hub.continueLearning.isEmpty)
                  Text('Start a track in Learn Mode to see it here.', style: AppTextStyles.body)
                else
                  ...hub.continueLearning.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _ContinueLearningCard(item: item),
                    ),
                  ),
                const SizedBox(height: 24),
                const SectionLabel(tag: 'C', title: 'TODAY'),
                const SizedBox(height: 16),
                _TodayStatsRow(hub: hub),
                const SizedBox(height: 24),
                _BestModeCard(hub: hub),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  final HubModel hub;
  const _WelcomeHeader({required this.hub});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('WELCOME BACK', style: AppTextStyles.eyebrow()),
              const SizedBox(height: 6),
              Text(
                hub.username.toUpperCase(),
                style: AppTextStyles.headline.copyWith(fontSize: 40),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('LV.${hub.progression.level.toString().padLeft(2, '0')}', style: AppTextStyles.label()),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(border: Border.all(color: AppColours.border)),
              child: Row(
                children: [
                  const Icon(Icons.local_fire_department, size: 16, color: AppColours.accent),
                  const SizedBox(width: 6),
                  Text('${hub.currentStreak}d', style: AppTextStyles.label(color: AppColours.textPrimary)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _XpBar extends StatelessWidget {
  final HubModel hub;
  const _XpBar({required this.hub});

  @override
  Widget build(BuildContext context) {
    final p = hub.progression;
    final shownTarget = p.xpIntoLevel + p.xpToNextLevel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('XP · ${p.xpIntoLevel} / $shownTarget', style: AppTextStyles.label()),
            Text('${p.percent}%', style: AppTextStyles.label(color: AppColours.accent)),
          ],
        ),
        const SizedBox(height: 10),
        ProgressTrack(progress: p.percent / 100),
      ],
    );
  }
}

class _DailyChallengeCard extends StatelessWidget {
  final HubModel hub;
  final HubViewModel vm;
  const _DailyChallengeCard({required this.hub, required this.vm});

  @override
  Widget build(BuildContext context) {
    final c = hub.dailyChallenge!;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColours.border),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColours.surface, AppColours.background],
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.sports_soccer_outlined, color: AppColours.textMuted, size: 20),
              Spacer(),
              Icon(Icons.emoji_events_outlined, color: AppColours.textMuted, size: 20),
            ],
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                color: AppColours.accent,
                child: const Text('DAILY',
                    style: TextStyle(color: AppColours.accentText, fontWeight: FontWeight.w800, fontSize: 11)),
              ),
              const SizedBox(width: 10),
              Text('EXP ${vm.challengeExpiry}', style: AppTextStyles.label()),
            ],
          ),
          const SizedBox(height: 16),
          Text(c.title.toUpperCase(), style: AppTextStyles.headline.copyWith(fontSize: 30)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  '${c.questionCount} Q · +${c.xpReward} XP · ${c.difficulty}',
                  style: AppTextStyles.body,
                ),
              ),
              GestureDetector(
                onTap: c.completed
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => GtqScreen(
                              fetcher: () async {
                                final res = await locator<GtqRemoteDataSource>().getDailyChallenge();
                                return res.map((dc) => dc.questions);
                              },
                              source: 'DAILY',
                              categoryLabel: c.title.toUpperCase(),
                            ),
                          ),
                        );
                      },
                child: Container(
                  width: 44,
                  height: 44,
                  color: c.completed ? AppColours.border : AppColours.accent,
                  alignment: Alignment.center,
                  child: Icon(
                    c.completed ? Icons.check : Icons.play_arrow_rounded,
                    color: c.completed ? AppColours.textMuted : AppColours.accentText,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ContinueLearningCard extends StatelessWidget {
  final HubContinueLearningItem item;
  const _ContinueLearningCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.trackId == null
          ? null
          : () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => TrackDetailScreen(trackId: item.trackId!)),
              );
            },
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            color: AppColours.surface,
            alignment: Alignment.center,
            child: const Icon(Icons.image_outlined, color: AppColours.textMuted, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.tag != null) Text(item.tag!, style: AppTextStyles.label(color: AppColours.accent)),
                const SizedBox(height: 4),
                Text(item.title.toUpperCase(),
                    style: const TextStyle(color: AppColours.textPrimary, fontWeight: FontWeight.w800, fontSize: 17)),
                const SizedBox(height: 10),
                ProgressTrack(progress: item.progress, height: 3),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.north_east, color: AppColours.textMuted, size: 18),
        ],
      ),
    );
  }
}

class _TodayStatsRow extends StatelessWidget {
  final HubModel hub;
  const _TodayStatsRow({required this.hub});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: AppColours.border)),
      child: Row(
        children: [
          Expanded(child: _StatCell(tag: 'Q', value: '${hub.today.answered}', label: 'ANSWERED')),
          Container(width: 1, color: AppColours.border),
          Expanded(
            child: _StatCell(
              tag: '%',
              value: hub.today.accuracy.toStringAsFixed(1),
              label: 'ACCURACY',
              highlightLastChar: true,
            ),
          ),
          Container(width: 1, color: AppColours.border),
          Expanded(child: _StatCell(tag: 'XP', value: '${hub.today.xpGained}', label: 'GAINED')),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String tag;
  final String value;
  final String label;
  final bool highlightLastChar;
  const _StatCell({
    required this.tag,
    required this.value,
    required this.label,
    this.highlightLastChar = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(tag, style: AppTextStyles.label(color: AppColours.textMuted)),
          const SizedBox(height: 10),
          highlightLastChar
              ? RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColours.textPrimary),
                    children: [
                      TextSpan(text: value.substring(0, value.length - 1)),
                      TextSpan(
                        text: value.substring(value.length - 1),
                        style: const TextStyle(color: AppColours.accent),
                      ),
                    ],
                  ),
                )
              : Text(value, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColours.textPrimary)),
          const SizedBox(height: 6),
          Text(label, style: AppTextStyles.label(color: AppColours.textMuted).copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}

class _BestModeCard extends StatelessWidget {
  final HubModel hub;
  const _BestModeCard({required this.hub});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Provider.of<DashboardViewModel>(context, listen: false).setIndex(3),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: AppColours.border)),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bolt, color: AppColours.accent, size: 16),
                const SizedBox(width: 8),
                Text('BEST MODE', style: AppTextStyles.label(color: AppColours.accent)),
                const Spacer(),
                const Icon(Icons.north_east, color: AppColours.textMuted, size: 18),
              ],
            ),
            const SizedBox(height: 12),
            const Text('CLIMB THE TABLE',
                style: TextStyle(color: AppColours.textPrimary, fontWeight: FontWeight.w800, fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              hub.bestMode.globalRank != null
                  ? 'Current rank #${hub.bestMode.globalRank} · Top ${hub.bestMode.topPercent}%'
                  : 'Pick a lane in Best Mode to get ranked.',
              style: AppTextStyles.body,
            ),
            const SizedBox(height: 16),
            ProgressTrack(progress: hub.progression.percent / 100, height: 3),
          ],
        ),
      ),
    );
  }
}
