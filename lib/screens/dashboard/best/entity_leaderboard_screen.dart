import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zendora_app/app/app_colours.dart';
import 'package:zendora_app/app/locator.dart';
import 'package:zendora_app/core/constants/datasource/best/best_remote_data_source.dart';
import 'package:zendora_app/core/constants/models/best_model.dart';
import 'package:zendora_app/screens/dashboard/profile/public_profile_screen.dart';
import 'package:zendora_app/screens/dashboard/widget/dashboard_shared.dart';

class EntityLeaderboardViewModel extends ChangeNotifier {
  final int entityId;
  final BestRemoteDataSource _ds = locator<BestRemoteDataSource>();

  EntityLeaderboardViewModel(this.entityId) {
    _load();
  }

  bool isLoading = true;
  String? error;
  EntityLeaderboardModel? data;

  Future<void> _load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    final res = await _ds.getEntityLeaderboard(entityId);
    res.fold(
      (err) {
        error = err.message;
        isLoading = false;
        notifyListeners();
      },
      (d) {
        data = d;
        isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> retry() => _load();
}

class EntityLeaderboardScreen extends StatelessWidget {
  final int entityId;
  const EntityLeaderboardScreen({super.key, required this.entityId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EntityLeaderboardViewModel(entityId),
      child: Scaffold(
        backgroundColor: AppColours.background,
        body: Consumer<EntityLeaderboardViewModel>(
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
                        Text('LEADERBOARD', style: AppTextStyles.label()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (vm.isLoading) const Expanded(child: LoadingBox(height: 300)),
                    if (!vm.isLoading && vm.error != null)
                      Expanded(child: ErrorRetryBox(message: vm.error!, onRetry: vm.retry)),
                    if (!vm.isLoading && vm.data != null)
                      Expanded(child: _Content(data: vm.data!)),
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
  final EntityLeaderboardModel data;
  const _Content({required this.data});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text(data.entity.name, style: AppTextStyles.headline.copyWith(fontSize: 30)),
        const SizedBox(height: 20),
        if (data.yourPosition != null)
          Container(
            decoration: BoxDecoration(border: Border.all(color: AppColours.accent)),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text('YOUR RANK', style: AppTextStyles.label(color: AppColours.accent)),
                const Spacer(),
                Text('#${data.yourPosition!.rank}', style: const TextStyle(color: AppColours.textPrimary, fontWeight: FontWeight.w800, fontSize: 20)),
                const SizedBox(width: 16),
                Text('${data.yourPosition!.xp} XP', style: AppTextStyles.label(color: AppColours.textMuted)),
              ],
            ),
          ),
        const SizedBox(height: 24),
        if (data.leaderboard.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text('No one has played this yet — be the first.', style: AppTextStyles.body),
          ),
        ...data.leaderboard.map((e) => GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => PublicProfileScreen(username: e.username)),
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
                      decoration: BoxDecoration(border: Border.all(color: AppColours.border)),
                      child: Text(
                        e.rank.toString().padLeft(2, '0'),
                        style: AppTextStyles.label(color: AppColours.textMuted),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(e.username, style: const TextStyle(color: AppColours.textPrimary, fontWeight: FontWeight.w800, fontSize: 15)),
                    ),
                    Text('${e.xp} XP', style: AppTextStyles.label(color: AppColours.textMuted)),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}
