import 'package:flutter/material.dart';
import 'package:zendora_app/app/app_colours.dart';

/// "• LIVE · MATCHDAY 14   HUB / 01" header used on every tab screen.
class DashboardTopBar extends StatelessWidget {
  final String left;
  final String right;
  final bool showDot;

  const DashboardTopBar({
    super.key,
    required this.left,
    required this.right,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            if (showDot) ...[
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColours.accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
            ],
            Text(left, style: AppTextStyles.label()),
            const Spacer(),
            Text(right, style: AppTextStyles.label()),
          ],
        ),
        const SizedBox(height: 16),
        Container(height: 1, color: AppColours.divider),
      ],
    );
  }
}

/// "[A]  DAILY CHALLENGE" section marker used to open every section.
class SectionLabel extends StatelessWidget {
  final String tag;
  final String title;

  const SectionLabel({super.key, required this.tag, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('[$tag]', style: AppTextStyles.label(color: AppColours.textMuted)),
        const SizedBox(width: 10),
        Text(title, style: AppTextStyles.label()),
      ],
    );
  }
}

/// Thin lime-on-dark progress bar reused across XP bars, track cards,
/// mastery rows, and the quiz question progress line.
class ProgressTrack extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final double height;

  const ProgressTrack({super.key, required this.progress, this.height = 4});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Stack(
        children: [
          Container(height: height, color: AppColours.border),
          Container(
            height: height,
            width: constraints.maxWidth * progress.clamp(0.0, 1.0),
            color: AppColours.accent,
          ),
        ],
      ),
    );
  }
}

/// Bordered loading placeholder used while a screen's first fetch is in flight.
class LoadingBox extends StatelessWidget {
  final double height;
  const LoadingBox({super.key, this.height = 200});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(border: Border.all(color: AppColours.border)),
      child: const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2, color: AppColours.accent),
      ),
    );
  }
}

/// Bordered error state with a retry action, used whenever a fetch fails.
class ErrorRetryBox extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const ErrorRetryBox({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(border: Border.all(color: AppColours.danger)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('SOMETHING WENT WRONG', style: AppTextStyles.label(color: AppColours.danger)),
          const SizedBox(height: 8),
          Text(message, style: AppTextStyles.body),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(border: Border.all(color: AppColours.border)),
              child: Text('RETRY', style: AppTextStyles.label(color: AppColours.textPrimary)),
            ),
          ),
        ],
      ),
    );
  }
}

/// 5-tab bottom nav: HUB / LEARN / GTQ / BEST / ZCP.
class DashboardBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const DashboardBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const List<({IconData icon, String label})> _items = [
    (icon: Icons.home_rounded, label: 'HUB'),
    (icon: Icons.menu_book_rounded, label: 'LEARN'),
    (icon: Icons.track_changes_rounded, label: 'GTQ'),
    (icon: Icons.emoji_events_rounded, label: 'BEST'),
    (icon: Icons.person_rounded, label: 'ZCP'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColours.background,
        border: Border(top: BorderSide(color: AppColours.divider)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: List.generate(_items.length, (i) {
          final active = i == currentIndex;
          final item = _items[i];
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onTap(i),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 2,
                    margin: const EdgeInsets.only(bottom: 10),
                    color: active ? AppColours.accent : Colors.transparent,
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: active ? AppColours.accent : Colors.transparent,
                      border: Border.all(
                        color: active ? AppColours.accent : AppColours.border,
                      ),
                    ),
                    child: Icon(
                      item.icon,
                      size: 20,
                      color: active ? AppColours.accentText : AppColours.textMuted,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.label,
                    style: AppTextStyles.label(
                      color: active ? AppColours.accent : AppColours.textMuted,
                    ).copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}