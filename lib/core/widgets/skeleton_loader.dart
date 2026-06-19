import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// In-house skeleton placeholder (req 7.1, 8.3).
///
/// A single animated box that loops a subtle gradient sweep. The full
/// sweep cycle lives in the 100–400 ms range (Property 9).
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.radius,
  });

  final double? width;
  final double height;
  final double? radius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      // Looping duration lives in the micro-animation band.
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.radius ?? AppRadii.sm;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        // Sweep the gradient back and forth across [0, 1] for a soft
        // pulse effect.
        final shift = (t * 2 - 1).abs(); // 0..1..0
        final alignment = Alignment(-1 + 2 * shift, 0);
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(r),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [
                AppColors.border,
                Color(0xFFF0F2F5),
                AppColors.border,
              ],
              stops: const [0.0, 0.5, 1.0],
              transform: _GradientTransform(alignment),
            ),
          ),
        );
      },
    );
  }
}

class _GradientTransform extends GradientTransform {
  const _GradientTransform(this.alignment);
  final Alignment alignment;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    final dx = (alignment.x + 1) / 2; // 0..1
    // translateByDouble avoids the deprecated translate helper.
    return Matrix4.identity()..translateByDouble(dx * bounds.width, 0.0, 0.0, 1.0);
  }
}

/// Skeleton list placeholder. `itemCount` is clamped to [1, 10]
/// so it never overflows the layout (req 7.1, 8.3).
class ListSkeleton extends StatelessWidget {
  const ListSkeleton({
    super.key,
    this.itemCount = 6,
    this.itemBuilder,
    this.padding = const EdgeInsets.symmetric(vertical: AppSpacing.md),
  });

  final int itemCount;
  final Widget Function(BuildContext context, int index)? itemBuilder;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final count = itemCount.clamp(1, 10);
    return ListView.separated(
      padding: padding,
      itemCount: count,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
      itemBuilder: itemBuilder ?? _defaultItem,
    );
  }

  static Widget _defaultItem(BuildContext context, int index) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.border(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          SkeletonBox(width: 40, height: 40, radius: 10),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 160, height: 14),
                SizedBox(height: AppSpacing.sm),
                SkeletonBox(width: 96, height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton variant that mirrors a [StatCard]'s visual rhythm.
class StatCardSkeleton extends StatelessWidget {
  const StatCardSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.border(AppRadii.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SkeletonBox(width: 36, height: 36, radius: 10),
              SizedBox(width: AppSpacing.md),
              Expanded(child: SkeletonBox(height: 14, width: 96)),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          SkeletonBox(height: 28, width: 72),
        ],
      ),
    );
  }
}

/// Skeleton variant that mirrors a typical form layout.
class FormSkeleton extends StatelessWidget {
  const FormSkeleton({super.key, this.fieldCount = 4});
  final int fieldCount;

  @override
  Widget build(BuildContext context) {
    final count = fieldCount.clamp(1, 10);
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        for (var i = 0; i < count; i++) ...[
          const SkeletonBox(width: 120, height: 12),
          const SizedBox(height: AppSpacing.sm),
          const SkeletonBox(height: 48, radius: 10),
          SizedBox(height: i == count - 1 ? 0 : AppSpacing.lg),
        ],
        const SizedBox(height: AppSpacing.xl),
        const SkeletonBox(height: 48, radius: 10),
      ],
    );
  }
}
