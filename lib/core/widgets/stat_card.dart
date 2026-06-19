import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Animated statistic card for the dashboard (req 6.1–6.7, 13.1, 13.2, 13.5).
///
/// * Numeric value animates from the previous value to the new one in
///   at most 600 ms (req 6.5).
/// * When [value] is `null` the card renders a `—` placeholder and
///   skips the animation (req 6.6).
/// * The displayed value is always an integer in the range
///   `[min(from,to), max(from,to)]` and equals `to` at the end (Property 1).
/// * When [onTap] is provided the card renders a Material InkWell whose
///   minimum tap target is 48x48 (req 14.2).
class StatCard extends StatefulWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.icon,
    required this.accent,
    this.value,
    this.onTap,
    this.unit,
    this.duration = const Duration(milliseconds: 600),
  });

  final String label;
  final int? value;
  final IconData icon;
  final Color accent;
  final VoidCallback? onTap;
  final String? unit;
  final Duration duration;

  @override
  State<StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  /// The most recent integer shown by the counter. The next animation
  /// tweens from this value to the new [widget.value], so an in-flight
  /// update always restarts from the currently displayed value.
  int _displayed = 0;
  int? _lastTarget;

  @override
  void initState() {
    super.initState();
    _displayed = widget.value ?? 0;
    _lastTarget = widget.value;
  }

  @override
  void didUpdateWidget(covariant StatCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _lastTarget) {
      _lastTarget = widget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasTap = widget.onTap != null;
    final card = Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.border(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: widget.accent.withValues(alpha: 0.12),
                  borderRadius: AppRadii.border(AppRadii.md),
                ),
                child: Icon(widget.icon, color: widget.accent, size: 18),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  widget.label,
                  style: AppTextStyles.cardTitle.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _Counter(
            from: _displayed,
            to: widget.value,
            duration: widget.duration,
            onCommit: (v) => _displayed = v,
            style: AppTextStyles.numericMetric.copyWith(
              color: AppColors.textPrimary,
            ),
            placeholder: '—',
          ),
          if (widget.unit != null && widget.unit!.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              widget.unit!,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );

    // Enforce a 48dp minimum tap target (req 14.2) when the card is
    // tappable. The `ConstrainedBox` only applies when there's a tap,
    // so non-interactive cards stay compact.
    return Material(
      color: Colors.transparent,
      child: hasTap
          ? InkWell(
              onTap: widget.onTap,
              borderRadius: AppRadii.border(AppRadii.lg),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 48),
                child: card,
              ),
            )
          : card,
    );
  }
}

/// Integer counter that animates from [from] to [to] over [duration].
/// Skips the animation when [to] is null and shows [placeholder] instead.
class _Counter extends StatelessWidget {
  const _Counter({
    required this.from,
    required this.to,
    required this.duration,
    required this.onCommit,
    required this.style,
    required this.placeholder,
  });

  final int from;
  final int? to;
  final Duration duration;
  final ValueChanged<int> onCommit;
  final TextStyle style;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    if (to == null) {
      return Text(placeholder, style: style);
    }
    final lower = from < to! ? from : to!;
    final upper = from > to! ? from : to!;
    return TweenAnimationBuilder<double>(
      // Keying on `to` ensures the tween restarts cleanly whenever the
      // target value changes, even if the previous animation was
      // interrupted mid-flight.
      key: ValueKey<int>(to!),
      tween: Tween<double>(begin: from.toDouble(), end: to!.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      onEnd: () => onCommit(to!),
      builder: (context, value, _) {
        final clamped = value.clamp(lower.toDouble(), upper.toDouble());
        return Text(
          '${clamped.round()}',
          style: style,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }
}
