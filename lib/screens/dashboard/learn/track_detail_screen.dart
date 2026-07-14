import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zendora_app/app/app_colours.dart';
import 'package:zendora_app/app/locator.dart';
import 'package:zendora_app/core/constants/datasource/learn/learn_remote_data_source.dart';
import 'package:zendora_app/core/constants/models/learn_model.dart';
import 'package:zendora_app/screens/dashboard/gtq/gtq_screen.dart';
import 'package:zendora_app/screens/dashboard/widget/dashboard_shared.dart';

class TrackDetailViewModel extends ChangeNotifier {
  final int trackId;
  final LearnRemoteDataSource _ds = locator<LearnRemoteDataSource>();

  TrackDetailViewModel(this.trackId) {
    _load();
  }

  bool isLoading = true;
  String? error;
  LearnTrackDetailModel? track;

  Future<void> _load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    final res = await _ds.getTrackDetail(trackId);
    res.fold(
      (err) {
        error = err.message;
        isLoading = false;
        notifyListeners();
      },
      (t) {
        track = t;
        isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> retry() => _load();
}

class TrackDetailScreen extends StatelessWidget {
  final int trackId;
  const TrackDetailScreen({super.key, required this.trackId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TrackDetailViewModel(trackId),
      child: Scaffold(
        backgroundColor: AppColours.background,
        body: Consumer<TrackDetailViewModel>(
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
                        Text('TRACK', style: AppTextStyles.label()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (vm.isLoading) const Expanded(child: LoadingBox(height: 300)),
                    if (!vm.isLoading && vm.error != null)
                      Expanded(child: ErrorRetryBox(message: vm.error!, onRetry: vm.retry)),
                    if (!vm.isLoading && vm.track != null)
                      Expanded(child: _TrackContent(track: vm.track!, trackId: trackId)),
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

class _TrackContent extends StatelessWidget {
  final LearnTrackDetailModel track;
  final int trackId;
  const _TrackContent({required this.track, required this.trackId});

  @override
  Widget build(BuildContext context) {
    final learnDs = locator<LearnRemoteDataSource>();
    return ListView(
      children: [
        Text(track.title, style: AppTextStyles.headline.copyWith(fontSize: 30)),
        if (track.subtitle != null) ...[
          const SizedBox(height: 8),
          Text(track.subtitle!, style: AppTextStyles.body),
        ],
        const SizedBox(height: 16),
        Text(
          '${track.level} · ${track.estimatedMinutes} MIN · ${track.sets.length} SETS',
          style: AppTextStyles.label(color: AppColours.textMuted),
        ),
        if (track.progress != null) ...[
          const SizedBox(height: 16),
          ProgressTrack(progress: track.progress!.percent / 100),
        ],
        const SizedBox(height: 28),
        const SectionLabel(tag: 'A', title: 'SETS'),
        const SizedBox(height: 16),
        ...track.sets.map((s) {
          final locked = s.questionCount == 0;
          final completed = (track.progress?.completedSets ?? 0) >= s.order;
          return GestureDetector(
            onTap: locked
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => GtqScreen(
                          fetcher: () => learnDs.getSetQuestions(s.id),
                          source: 'LEARN',
                          categoryLabel: track.title.toUpperCase(),
                          trackId: trackId,
                          completedSetsToReport: s.order,
                        ),
                      ),
                    );
                  },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColours.divider)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: completed ? AppColours.accent : Colors.transparent,
                      border: Border.all(color: completed ? AppColours.accent : AppColours.border),
                    ),
                    child: completed
                        ? const Icon(Icons.check, size: 16, color: AppColours.accentText)
                        : Text(
                            s.order.toString().padLeft(2, '0'),
                            style: AppTextStyles.label(color: AppColours.textMuted),
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      s.title,
                      style: TextStyle(
                        color: locked ? AppColours.textMuted : AppColours.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Text(
                    locked ? 'SOON' : '${s.questionCount} Q',
                    style: AppTextStyles.label(color: AppColours.textMuted).copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
