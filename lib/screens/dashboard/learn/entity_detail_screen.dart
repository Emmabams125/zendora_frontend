import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zendora_app/app/app_colours.dart';
import 'package:zendora_app/app/locator.dart';
import 'package:zendora_app/core/constants/datasource/gtq/gtq_remote_data_source.dart';
import 'package:zendora_app/core/constants/datasource/sports/sports_remote_data_source.dart';
import 'package:zendora_app/core/constants/models/entity_model.dart';
import 'package:zendora_app/screens/dashboard/gtq/gtq_screen.dart';
import 'package:zendora_app/screens/dashboard/widget/dashboard_shared.dart';

class EntityDetailViewModel extends ChangeNotifier {
  final String slug;
  final SportsRemoteDataSource _ds = locator<SportsRemoteDataSource>();

  EntityDetailViewModel(this.slug) {
    _load();
  }

  bool isLoading = true;
  String? error;
  EntityDetailModel? detail;

  Future<void> _load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    final res = await _ds.getEntity(slug);
    res.fold(
      (err) {
        error = err.message;
        isLoading = false;
        notifyListeners();
      },
      (d) {
        detail = d;
        isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> retry() => _load();
}

class EntityDetailScreen extends StatelessWidget {
  final String slug;
  const EntityDetailScreen({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EntityDetailViewModel(slug),
      child: Scaffold(
        backgroundColor: AppColours.background,
        body: Consumer<EntityDetailViewModel>(
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
                        Text('ENTITY', style: AppTextStyles.label()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (vm.isLoading) const Expanded(child: LoadingBox(height: 300)),
                    if (!vm.isLoading && vm.error != null)
                      Expanded(child: ErrorRetryBox(message: vm.error!, onRetry: vm.retry)),
                    if (!vm.isLoading && vm.detail != null)
                      Expanded(child: _EntityContent(detail: vm.detail!)),
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

class _EntityContent extends StatelessWidget {
  final EntityDetailModel detail;
  const _EntityContent({required this.detail});

  @override
  Widget build(BuildContext context) {
    final entity = detail.entity;
    return ListView(
      children: [
        Container(
          width: 84,
          height: 84,
          color: AppColours.surface,
          alignment: Alignment.center,
          child: const Icon(Icons.shield_outlined, color: AppColours.textMuted, size: 32),
        ),
        const SizedBox(height: 20),
        Text(entity.name, style: AppTextStyles.headline.copyWith(fontSize: 32)),
        const SizedBox(height: 8),
        if (entity.country != null)
          Text('COUNTRY · ${entity.country}', style: AppTextStyles.label(color: AppColours.textMuted)),
        if (detail.category?['name'] != null) ...[
          const SizedBox(height: 4),
          Text('CATEGORY · ${detail.category!['name']}', style: AppTextStyles.label(color: AppColours.textMuted)),
        ],
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => GtqScreen(
                    fetcher: () => locator<GtqRemoteDataSource>().getQuestions(
                      sport: 'football',
                      entityId: entity.id,
                      count: 10,
                    ),
                    source: 'GTQ',
                    categoryLabel: entity.name.toUpperCase(),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColours.accent,
              foregroundColor: AppColours.accentText,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: const RoundedRectangleBorder(),
              elevation: 0,
            ),
            child: const Text('PRACTICE THIS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
          ),
        ),
      ],
    );
  }
}
