import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/ui_state.dart';
import 'empty_state.dart';
import 'error_view.dart';
import 'skeleton_loader.dart';

/// Renders exactly one of {skeleton, content, empty, error} for a
/// screen whose controller exposes a `Rx<ViewState>` and an item list
/// (req 7.1–7.4, 9.1, 9.5, 9.6, 10.3, 10.5, 10.6).
///
/// * Renders the skeleton within 100 ms of the `loading` state.
/// * Never co-renders empty/error with the skeleton (Property 7).
/// * `onRetry` is wired to the controller's `load()`.
/// * `emptyActionLabel` + `onEmptyAction` render a primary action
///   in the empty state (req 9.3, 9.4).
///
/// The component takes a `RxString` for the error message so updates
/// flow back into the error view automatically.
class DataAsyncView<T> extends StatelessWidget {
  const DataAsyncView({
    super.key,
    required this.state,
    required this.items,
    required this.builder,
    this.onRetry,
    this.errorMessage,
    this.isRetrying = false,
    this.emptyTitle,
    this.emptySubtitle,
    this.emptyIcon,
    this.emptyActionLabel,
    this.onEmptyAction,
    this.skeleton,
  });

  /// Current view state (req 7.1).
  final Rx<ViewState> state;

  /// The list of items to render in the `content` state.
  final RxList<T> items;

  /// Builder for the content view.
  final Widget Function(BuildContext context, List<T> items) builder;

  /// Optional retry handler (req 10.1).
  final Future<void> Function()? onRetry;

  /// Error message displayed when [state] is [ViewState.error].
  final RxString? errorMessage;

  /// When `true`, the error view's retry button shows a spinner.
  final bool isRetrying;

  /// Optional empty-state copy (req 9.2).
  final String? emptyTitle;
  final String? emptySubtitle;
  final IconData? emptyIcon;

  /// Optional empty-state primary action (req 9.3, 9.4).
  final String? emptyActionLabel;
  final VoidCallback? onEmptyAction;

  /// Optional skeleton widget override.
  final Widget? skeleton;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final s = state.value;
      final msg = errorMessage?.value ?? '';
      switch (s) {
        case ViewState.loading:
          return skeleton ?? const _DefaultSkeleton();
        case ViewState.content:
          // Defensive: a controller that reports `content` with no
          // items should fall back to empty rather than render a blank
          // surface (req 7.2 / 9.5).
          if (items.isEmpty) {
            return _buildEmpty(context);
          }
          return builder(context, items.toList());
        case ViewState.empty:
          return _buildEmpty(context);
        case ViewState.error:
          return ErrorView(
            message: msg.isEmpty
                ? 'Terjadi kesalahan. Coba lagi.'
                : msg,
            onRetry: onRetry == null ? null : () => onRetry!(),
            isRetrying: isRetrying,
          );
      }
    });
  }

  Widget _buildEmpty(BuildContext context) {
    return EmptyState(
      title: emptyTitle ?? 'Belum ada data',
      subtitle: emptySubtitle,
      icon: emptyIcon,
      primaryActionLabel: emptyActionLabel,
      onPrimaryAction: onEmptyAction,
    );
  }
}

class _DefaultSkeleton extends StatelessWidget {
  const _DefaultSkeleton();
  @override
  Widget build(BuildContext context) {
    return const ListSkeleton();
  }
}
