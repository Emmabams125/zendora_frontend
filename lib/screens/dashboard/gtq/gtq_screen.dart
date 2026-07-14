import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zendora_app/app/app_colours.dart';
import 'package:zendora_app/app/locator.dart';
import 'package:zendora_app/core/constants/datasource/gtq/gtq_remote_data_source.dart';
import 'package:zendora_app/core/constants/datasource/learn/learn_remote_data_source.dart';
import 'package:zendora_app/core/constants/models/app_error.dart';
import 'package:zendora_app/core/constants/models/gtq_model.dart';
import 'package:zendora_app/screens/dashboard/widget/dashboard_shared.dart';
import 'package:zendora_app/core/widgets/app_primary_button.dart';

typedef GtqQuestionsFetcher = Future<Either<AppError, List<GtqQuestionModel>>> Function();

const int kGtqQuestionSeconds = 18;

class GtqViewModel extends ChangeNotifier {
  final GtqQuestionsFetcher fetcher;
  final String source;
  final String categoryLabel;
  final int? trackId;
  final int? completedSetsToReport;

  final GtqRemoteDataSource _gtqDs = locator<GtqRemoteDataSource>();
  final LearnRemoteDataSource _learnDs = locator<LearnRemoteDataSource>();

  GtqViewModel({
    required this.fetcher,
    required this.source,
    this.categoryLabel = 'GTQ',
    this.trackId,
    this.completedSetsToReport,
  }) {
    _load();
  }

  bool isLoading = true;
  String? error;

  List<GtqQuestionModel> questions = [];
  int currentIndex = 0;
  int? selectedOptionId;
  bool usedHint = false;
  bool hintRevealed = false;
  bool timedOut = false;
  GtqAnswerResultModel? result;
  bool isSubmitting = false;

  int correctCount = 0;
  int totalXp = 0;
  bool sessionComplete = false;

  int _secondsLeft = kGtqQuestionSeconds;
  int get secondsLeft => _secondsLeft;
  Timer? _timer;

  GtqQuestionModel get currentQuestion => questions[currentIndex];
  int get questionNumber => currentIndex + 1;
  int get totalQuestions => questions.length;

  Future<void> _load() async {
    isLoading = true;
    error = null;
    notifyListeners();

    final res = await fetcher();
    res.fold(
      (err) {
        error = err.message;
        isLoading = false;
        notifyListeners();
      },
      (q) {
        questions = q;
        isLoading = false;
        if (questions.isEmpty) {
          error = 'No questions available right now.';
        } else {
          _startTimer();
        }
        notifyListeners();
      },
    );
  }

  Future<void> retry() => _load();

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = kGtqQuestionSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) {
        t.cancel();
        if (result == null && !timedOut) {
          timedOut = true;
          notifyListeners();
        }
        return;
      }
      _secondsLeft--;
      notifyListeners();
    });
  }

  void selectOption(int optionId) {
    if (result != null || timedOut) return;
    selectedOptionId = optionId;
    notifyListeners();
  }

  void revealHint() {
    if (result != null || timedOut) return;
    usedHint = true;
    hintRevealed = true;
    notifyListeners();
  }

  Future<void> confirmAnswer() async {
    if (selectedOptionId == null || result != null || isSubmitting) return;
    _timer?.cancel();
    isSubmitting = true;
    notifyListeners();

    final res = await _gtqDs.submitAnswer(
      questionId: currentQuestion.id,
      optionId: selectedOptionId!,
      usedHint: usedHint,
      source: source,
    );

    res.fold(
      (err) {
        error = err.message;
        isSubmitting = false;
        notifyListeners();
      },
      (r) {
        result = r;
        isSubmitting = false;
        if (r.isCorrect) correctCount++;
        totalXp += r.xpAwarded;
        notifyListeners();
      },
    );
  }

  Future<void> nextQuestion() async {
    if (currentIndex + 1 < questions.length) {
      currentIndex++;
      selectedOptionId = null;
      usedHint = false;
      hintRevealed = false;
      timedOut = false;
      result = null;
      notifyListeners();
      _startTimer();
    } else {
      sessionComplete = true;
      notifyListeners();
      if (trackId != null && completedSetsToReport != null) {
        await _learnDs.updateProgress(trackId!, completedSetsToReport!);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class GtqScreen extends StatelessWidget {
  final GtqQuestionsFetcher fetcher;
  final String source;
  final String categoryLabel;
  final int? trackId;
  final int? completedSetsToReport;

  const GtqScreen({
    super.key,
    required this.fetcher,
    required this.source,
    this.categoryLabel = 'GTQ',
    this.trackId,
    this.completedSetsToReport,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GtqViewModel(
        fetcher: fetcher,
        source: source,
        categoryLabel: categoryLabel,
        trackId: trackId,
        completedSetsToReport: completedSetsToReport,
      ),
      child: Scaffold(
        backgroundColor: AppColours.background,
        body: Consumer<GtqViewModel>(
          builder: (context, vm, _) {
            if (vm.isLoading) {
              return const SafeArea(child: Center(child: LoadingBox(height: 120)));
            }
            if (vm.sessionComplete) {
              return _SessionSummary(vm: vm);
            }
            if (vm.error != null && vm.questions.isEmpty) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: ErrorRetryBox(message: vm.error!, onRetry: vm.retry),
                ),
              );
            }

            final minutes = (vm.secondsLeft ~/ 60).toString().padLeft(2, '0');
            final seconds = (vm.secondsLeft % 60).toString().padLeft(2, '0');

            return SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.maybePop(context),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(border: Border.all(color: AppColours.border)),
                            alignment: Alignment.center,
                            child: const Icon(Icons.close, size: 16, color: AppColours.textPrimary),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            const Icon(Icons.local_fire_department, size: 16, color: AppColours.accent),
                            const SizedBox(width: 6),
                            Text(
                              '+${vm.totalXp} XP',
                              style: AppTextStyles.label(color: AppColours.accent),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text('$minutes:$seconds', style: AppTextStyles.label()),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  ProgressTrack(progress: vm.questionNumber / vm.totalQuestions, height: 2),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Q ${vm.questionNumber.toString().padLeft(2, '0')} / ${vm.totalQuestions}',
                              style: AppTextStyles.label(color: AppColours.accent),
                            ),
                            Text('CATEGORY · ${vm.categoryLabel}', style: AppTextStyles.label()),
                            Text('+${vm.currentQuestion.xpReward} XP', style: AppTextStyles.label(color: AppColours.accent)),
                          ],
                        ),
                        const SizedBox(height: 28),
                        Text('[ GUESS THE QUESTION ]', style: AppTextStyles.label(color: AppColours.textMuted)),
                        const SizedBox(height: 16),
                        Text(vm.currentQuestion.text, style: AppTextStyles.headline.copyWith(fontSize: 28)),
                        const SizedBox(height: 20),
                        if (vm.currentQuestion.hintText != null)
                          GestureDetector(
                            onTap: vm.revealHint,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(border: Border.all(color: AppColours.border)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.lightbulb_outline, size: 16, color: AppColours.accent),
                                  const SizedBox(width: 8),
                                  Text(
                                    vm.hintRevealed
                                        ? vm.currentQuestion.hintText!
                                        : 'HINT · -${vm.currentQuestion.hintCost} XP',
                                    style: AppTextStyles.label(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                        if (vm.timedOut)
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(border: Border.all(color: AppColours.danger)),
                            child: Text("TIME'S UP", style: AppTextStyles.label(color: AppColours.danger)),
                          ),
                        if (vm.result != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: vm.result!.isCorrect ? AppColours.accent : AppColours.danger,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vm.result!.isCorrect ? 'CORRECT · +${vm.result!.xpAwarded} XP' : 'INCORRECT',
                                  style: AppTextStyles.label(
                                    color: vm.result!.isCorrect ? AppColours.accent : AppColours.danger,
                                  ),
                                ),
                                if (vm.result!.explanation != null) ...[
                                  const SizedBox(height: 8),
                                  Text(vm.result!.explanation!, style: AppTextStyles.body),
                                ],
                              ],
                            ),
                          ),
                        ...List.generate(vm.currentQuestion.options.length, (i) {
                          final opt = vm.currentQuestion.options[i];
                          final selected = vm.selectedOptionId == opt.id;
                          final showGrading = vm.result != null;
                          final isCorrectOption = showGrading && opt.id == vm.result!.correctOptionId;
                          final isWrongSelected = showGrading && selected && !isCorrectOption;

                          Color borderColor = AppColours.border;
                          Color fillColor = Colors.transparent;
                          Color textColor = AppColours.textPrimary;
                          if (showGrading) {
                            if (isCorrectOption) {
                              borderColor = AppColours.accent;
                              fillColor = AppColours.accent;
                              textColor = AppColours.accentText;
                            } else if (isWrongSelected) {
                              borderColor = AppColours.danger;
                              textColor = AppColours.danger;
                            }
                          } else if (selected) {
                            borderColor = AppColours.accent;
                            fillColor = AppColours.accent;
                            textColor = AppColours.accentText;
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: GestureDetector(
                              onTap: () => vm.selectOption(opt.id),
                              child: Container(
                                decoration: BoxDecoration(color: fillColor, border: Border.all(color: borderColor)),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(border: Border.all(color: borderColor)),
                                      child: Text(
                                        opt.label,
                                        style: TextStyle(color: textColor, fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Text(
                                        opt.text,
                                        style: TextStyle(color: textColor, fontWeight: FontWeight.w800, fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColours.divider))),
                    child: Column(
                      children: [
                        AppPrimaryButton(
                          onPressed: vm.result != null || vm.timedOut
                              ? vm.nextQuestion
                              : (vm.selectedOptionId == null ? null : vm.confirmAnswer),
                          loading: vm.result == null && !vm.timedOut && vm.isSubmitting,
                          label: vm.result != null || vm.timedOut
                              ? (vm.questionNumber == vm.totalQuestions ? 'FINISH' : 'NEXT QUESTION')
                              : 'CONFIRM ANSWER',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SessionSummary extends StatelessWidget {
  final GtqViewModel vm;
  const _SessionSummary({required this.vm});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('SESSION COMPLETE', style: AppTextStyles.eyebrow()),
              const SizedBox(height: 16),
              Text(
                '${vm.correctCount} / ${vm.totalQuestions}',
                style: AppTextStyles.headline.copyWith(fontSize: 44),
              ),
              const SizedBox(height: 8),
              Text('CORRECT ANSWERS', style: AppTextStyles.label(color: AppColours.textMuted)),
              const SizedBox(height: 24),
              Text('+${vm.totalXp} XP', style: const TextStyle(color: AppColours.accent, fontWeight: FontWeight.w800, fontSize: 28)),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColours.accent,
                    foregroundColor: AppColours.accentText,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: const RoundedRectangleBorder(),
                    elevation: 0,
                  ),
                  child: const Text('DONE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
