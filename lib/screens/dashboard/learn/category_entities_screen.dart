import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zendora_app/app/app_colours.dart';
import 'package:zendora_app/app/locator.dart';
import 'package:zendora_app/core/constants/datasource/best/best_remote_data_source.dart';
import 'package:zendora_app/core/constants/datasource/sports/sports_remote_data_source.dart';
import 'package:zendora_app/core/constants/models/entity_model.dart';
import 'package:zendora_app/screens/dashboard/learn/entity_detail_screen.dart';
import 'package:zendora_app/screens/dashboard/widget/dashboard_shared.dart';

class CategoryEntitiesViewModel extends ChangeNotifier {
  final String sportKey;
  final String type;
  final SportsRemoteDataSource _sportsDs = locator<SportsRemoteDataSource>();
  final BestRemoteDataSource _bestDs = locator<BestRemoteDataSource>();

  CategoryEntitiesViewModel(this.sportKey, this.type) {
    _load();
  }

  bool isLoading = true;
  bool isLoadingMore = false;
  String? error;
  String query = '';
  int page = 1;
  int total = 0;
  List<EntitySummaryModel> entities = [];

  bool isPicking = false;
  String? pickError;

  Future<void> _load({bool reset = true}) async {
    if (reset) {
      isLoading = true;
      page = 1;
      entities = [];
    } else {
      isLoadingMore = true;
    }
    error = null;
    notifyListeners();

    final res = await _sportsDs.getEntities(sportKey, type, q: query, page: page, pageSize: 20);
    res.fold(
      (err) {
        error = err.message;
        isLoading = false;
        isLoadingMore = false;
        notifyListeners();
      },
      (p) {
        total = p.total;
        entities = reset ? p.entities : [...entities, ...p.entities];
        isLoading = false;
        isLoadingMore = false;
        notifyListeners();
      },
    );
  }

  Timer? _debounce;
  void search(String q) {
    query = q;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _load());
  }

  bool get hasMore => entities.length < total;

  void loadMore() {
    if (isLoadingMore || !hasMore) return;
    page++;
    _load(reset: false);
  }

  Future<void> retry() => _load();

  Future<bool> pick(int entityId) async {
    isPicking = true;
    pickError = null;
    notifyListeners();

    final res = await _bestDs.pickCategory(type, entityId);
    bool success = false;
    res.fold(
      (err) => pickError = err.message,
      (_) => success = true,
    );
    isPicking = false;
    notifyListeners();
    return success;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}

class CategoryEntitiesScreen extends StatelessWidget {
  final String sportKey;
  final String type;
  final String categoryTitle;
  final bool pickMode;

  const CategoryEntitiesScreen({
    super.key,
    required this.sportKey,
    required this.type,
    required this.categoryTitle,
    this.pickMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CategoryEntitiesViewModel(sportKey, type),
      child: Scaffold(
        backgroundColor: AppColours.background,
        body: Consumer<CategoryEntitiesViewModel>(
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
                        Text(
                          pickMode ? 'PICK · $categoryTitle' : categoryTitle,
                          style: AppTextStyles.label(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
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
                                hintText: 'Search $categoryTitle...',
                                hintStyle: AppTextStyles.inputHint,
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 18),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (vm.isLoading) const Expanded(child: LoadingBox(height: 300)),
                    if (!vm.isLoading && vm.error != null)
                      Expanded(child: ErrorRetryBox(message: vm.error!, onRetry: vm.retry)),
                    if (!vm.isLoading && vm.error == null)
                      Expanded(
                        child: vm.entities.isEmpty
                            ? Center(child: Text('No results', style: AppTextStyles.body))
                            : NotificationListener<ScrollNotification>(
                                onNotification: (n) {
                                  if (n.metrics.pixels >= n.metrics.maxScrollExtent - 100) {
                                    vm.loadMore();
                                  }
                                  return false;
                                },
                                child: ListView.builder(
                                  itemCount: vm.entities.length + (vm.hasMore ? 1 : 0),
                                  itemBuilder: (context, i) {
                                    if (i >= vm.entities.length) {
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 16),
                                        child: Center(
                                          child: SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColours.accent),
                                          ),
                                        ),
                                      );
                                    }
                                    final e = vm.entities[i];
                                    return GestureDetector(
                                      onTap: () async {
                                        if (pickMode) {
                                          final ok = await vm.pick(e.id);
                                          if (ok && context.mounted) Navigator.of(context).pop(true);
                                        } else {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(builder: (_) => EntityDetailScreen(slug: e.slug)),
                                          );
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        decoration: const BoxDecoration(
                                          border: Border(bottom: BorderSide(color: AppColours.divider)),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    e.name,
                                                    style: const TextStyle(
                                                      color: AppColours.textPrimary,
                                                      fontWeight: FontWeight.w800,
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                  if (e.country != null) ...[
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      e.country!,
                                                      style: AppTextStyles.label(color: AppColours.textMuted).copyWith(fontSize: 10),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                            const Icon(Icons.chevron_right, color: AppColours.textMuted),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
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
