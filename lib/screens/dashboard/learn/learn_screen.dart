import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zendora_app/app/app_colours.dart';
import 'package:zendora_app/app/locator.dart';
import 'package:zendora_app/core/constants/datasource/learn/learn_remote_data_source.dart';
import 'package:zendora_app/core/constants/datasource/sports/sports_remote_data_source.dart';
import 'package:zendora_app/core/constants/models/learn_model.dart';
import 'package:zendora_app/core/constants/models/search_result_model.dart';
import 'package:zendora_app/core/constants/models/sport_model.dart';
import 'package:zendora_app/screens/dashboard/learn/category_entities_screen.dart';
import 'package:zendora_app/screens/dashboard/learn/entity_detail_screen.dart';
import 'package:zendora_app/screens/dashboard/learn/track_detail_screen.dart';
import 'package:zendora_app/screens/dashboard/widget/dashboard_shared.dart';

class LearnViewModel extends ChangeNotifier {
  final SportsRemoteDataSource _sportsDs = locator<SportsRemoteDataSource>();
  final LearnRemoteDataSource _learnDs = locator<LearnRemoteDataSource>();

  LearnViewModel() {
    _loadSports();
  }

  bool isLoading = true;
  String? error;
  List<SportModel> sports = [];
  String selectedSportKey = 'football';

  bool isLoadingContent = false;
  List<LearnTrackModel> tracks = [];
  List<CategoryModel> categories = [];

  String query = '';
  bool isSearching = false;
  SearchResultModel? searchResult;
  Timer? _debounce;

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
      (list) async {
        sports = list;
        final active = list.firstWhere((s) => s.isActive, orElse: () => list.first);
        selectedSportKey = active.key;
        isLoading = false;
        notifyListeners();
        await _loadContent();
      },
    );
  }

  Future<void> retry() => _loadSports();

  void selectSport(SportModel sport) {
    if (!sport.isActive || sport.key == selectedSportKey) return;
    selectedSportKey = sport.key;
    notifyListeners();
    _loadContent();
  }

  Future<void> _loadContent() async {
    isLoadingContent = true;
    notifyListeners();

    final tracksRes = await _learnDs.getTracks(sport: selectedSportKey);
    final categoriesRes = await _sportsDs.getCategories(selectedSportKey);

    tracksRes.fold((_) {}, (list) => tracks = list);
    categoriesRes.fold((_) {}, (list) => categories = list);

    isLoadingContent = false;
    notifyListeners();
  }

  void search(String q) {
    query = q;
    _debounce?.cancel();
    if (q.trim().isEmpty) {
      searchResult = null;
      isSearching = false;
      notifyListeners();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      isSearching = true;
      notifyListeners();
      final res = await _sportsDs.search(q.trim());
      res.fold(
        (_) => searchResult = null,
        (r) => searchResult = r,
      );
      isSearching = false;
      notifyListeners();
    });
  }

  void clearSearch() {
    query = '';
    searchResult = null;
    isSearching = false;
    _debounce?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LearnViewModel(),
      child: Consumer<LearnViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const SafeArea(child: Center(child: LoadingBox(height: 160)));
          }
          if (vm.error != null) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ErrorRetryBox(message: vm.error!, onRetry: vm.retry),
              ),
            );
          }

          return SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              children: [
                const DashboardTopBar(left: 'LEARN MODE', right: 'LEARN / 02'),
                const SizedBox(height: 24),
                Text('LEARN MODE', style: AppTextStyles.eyebrow()),
                const SizedBox(height: 8),
                const Text('FOOTBALL,\nSTRUCTURED.', style: AppTextStyles.headline),
                const SizedBox(height: 24),
                _SearchField(vm: vm),
                if (vm.query.trim().isNotEmpty) _SearchResults(vm: vm),
                const SizedBox(height: 20),
                _SportTabs(vm: vm),
                const SizedBox(height: 32),
                if (vm.isLoadingContent)
                  const LoadingBox(height: 220)
                else ...[
                  const SectionLabel(tag: 'A', title: 'TRACKS'),
                  const SizedBox(height: 16),
                  if (vm.tracks.isEmpty)
                    Text('No tracks yet for this sport.', style: AppTextStyles.body)
                  else
                    ...vm.tracks.map(
                      (t) => Padding(padding: const EdgeInsets.only(bottom: 16), child: _TrackCard(track: t)),
                    ),
                  const SizedBox(height: 20),
                  const SectionLabel(tag: 'B', title: 'CATEGORIES'),
                  const SizedBox(height: 16),
                  _CategoryGrid(categories: vm.categories, sportKey: vm.selectedSportKey),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final LearnViewModel vm;
  const _SearchField({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: AppColours.border)),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColours.textMuted, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              style: AppTextStyles.inputText,
              cursorColor: AppColours.accent,
              onChanged: vm.search,
              decoration: InputDecoration(
                hintText: 'Search clubs, players, leagues...',
                hintStyle: AppTextStyles.inputHint,
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
              ),
            ),
          ),
          if (vm.query.isNotEmpty)
            GestureDetector(
              onTap: vm.clearSearch,
              child: const Icon(Icons.close, color: AppColours.textMuted, size: 18),
            ),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  final LearnViewModel vm;
  const _SearchResults({required this.vm});

  @override
  Widget build(BuildContext context) {
    if (vm.isSearching) {
      return const Padding(padding: EdgeInsets.only(top: 12), child: LoadingBox(height: 80));
    }
    final result = vm.searchResult;
    if (result == null) return const SizedBox.shrink();
    if (result.entities.isEmpty && result.tracks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Text('No results for "${vm.query}"', style: AppTextStyles.body),
      );
    }
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(border: Border.all(color: AppColours.border)),
      child: Column(
        children: [
          ...result.tracks.map((t) => _SearchResultRow(
                label: 'TRACK',
                title: t.title,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => TrackDetailScreen(trackId: t.id)),
                ),
              )),
          ...result.entities.map((e) => _SearchResultRow(
                label: 'ENTITY',
                title: e.name,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => EntityDetailScreen(slug: e.slug)),
                ),
              )),
        ],
      ),
    );
  }
}

class _SearchResultRow extends StatelessWidget {
  final String label;
  final String title;
  final VoidCallback onTap;
  const _SearchResultRow({required this.label, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColours.divider))),
        child: Row(
          children: [
            Text(label, style: AppTextStyles.label(color: AppColours.textMuted).copyWith(fontSize: 10)),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(color: AppColours.textPrimary, fontWeight: FontWeight.w700))),
            const Icon(Icons.chevron_right, color: AppColours.textMuted),
          ],
        ),
      ),
    );
  }
}

class _SportTabs extends StatelessWidget {
  final LearnViewModel vm;
  const _SportTabs({required this.vm});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: vm.sports.map((s) {
        final active = s.key == vm.selectedSportKey;
        return Expanded(
          child: GestureDetector(
            onTap: () => vm.selectSport(s),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 14),
              color: active ? AppColours.accent : Colors.transparent,
              child: Text.rich(
                TextSpan(
                  text: s.name.toUpperCase(),
                  style: AppTextStyles.label(color: active ? AppColours.accentText : AppColours.textMuted),
                  children: [
                    if (!s.isActive)
                      TextSpan(
                        text: ' SOON',
                        style: AppTextStyles.label(color: active ? AppColours.accentText : AppColours.textMuted)
                            .copyWith(fontSize: 9),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _TrackCard extends StatelessWidget {
  final LearnTrackModel track;
  const _TrackCard({required this.track});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => TrackDetailScreen(trackId: track.id)),
        );
      },
      child: Container(
        height: 220,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('TRK · ${track.id.toString().padLeft(2, '0')}', style: AppTextStyles.label(color: AppColours.accent)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(border: Border.all(color: AppColours.border)),
                  child: Text(track.level, style: AppTextStyles.label().copyWith(fontSize: 10)),
                ),
              ],
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(track.title.toUpperCase(), style: AppTextStyles.headline.copyWith(fontSize: 24)),
                      const SizedBox(height: 8),
                      Text('${track.totalSets} sets · ~${track.estimatedMinutes} min', style: AppTextStyles.body),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  color: AppColours.accent,
                  alignment: Alignment.center,
                  child: const Icon(Icons.north_east, color: AppColours.accentText, size: 18),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final List<CategoryModel> categories;
  final String sportKey;
  const _CategoryGrid({required this.categories, required this.sportKey});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
      ),
      itemBuilder: (context, i) {
        final c = categories[i];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CategoryEntitiesScreen(
                  sportKey: sportKey,
                  type: c.type,
                  categoryTitle: c.name.toUpperCase(),
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(border: Border.all(color: AppColours.border)),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('[${(i + 1).toString().padLeft(2, '0')}]', style: AppTextStyles.label(color: AppColours.textMuted)),
                const Spacer(),
                Text(c.name.toUpperCase(), style: const TextStyle(color: AppColours.textPrimary, fontWeight: FontWeight.w800, fontSize: 18)),
                const SizedBox(height: 4),
                Text('${c.setCount} SETS', style: AppTextStyles.label(color: AppColours.textMuted).copyWith(fontSize: 10)),
              ],
            ),
          ),
        );
      },
    );
  }
}
