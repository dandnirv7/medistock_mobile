import 'dart:async';

import 'package:get/get.dart';

import '../network/api_exception.dart';

/// Coarse view state for data-driven screens (req 7.1–7.4, 9.5).
///
/// A screen is in exactly one of these states at any time. Use
/// [DataAsyncView] to switch between the matching view automatically.
enum ViewState { loading, content, empty, error }

/// Controller-side contract for screens that load a list of items.
///
/// The mixin standardizes the data shape and lifecycle so any list view
/// can plug into [DataAsyncView] without bespoke state plumbing.
///
/// Implementers only need to provide [load] (initial / retry) and
/// [refresh] (pull-to-refresh). The mixin handles:
/// * resetting [state] to `loading` on each new load,
/// * transitioning to `content` / `empty` / `error` based on the result,
/// * tracking [isRefreshing] separately so the existing list is kept
///   visible during a pull-to-refresh.
/// * guarding against concurrent refreshes,
/// * applying a 30 second timeout to refreshes,
/// * retaining the previous [items] when a refresh fails or times out.
mixin AsyncListState<T> on GetxController {
  /// Current items. Retained across failed refreshes (req 11.4).
  final RxList<T> items = <T>[].obs;

  /// Current view state. Exactly one of {loading, content, empty, error}.
  final Rx<ViewState> state = ViewState.loading.obs;

  /// Human-readable error message, derived from an exception in [load]/
  /// [refresh]. Empty when there is no error.
  final RxString errorMessage = ''.obs;

  /// `true` while a pull-to-refresh is in flight.
  final RxBool isRefreshing = false.obs;

  /// Maximum time a pull-to-refresh can take before it is considered
  /// failed and the existing items are retained.

  Duration get refreshTimeout => const Duration(seconds: 30);

  /// Load items from scratch. Called on first display and on retry.
  Future<void> load();

  /// Pull-to-refresh: keep existing items, transition to [isRefreshing].
  /// Default implementation delegates to [load]; controllers that fetch
  /// incremental data can override.
  @override
  // ignore: annotate_overrides
  // ignore: annotate_overrides
  Future<void> refresh() => load();

  /// Helper: run [runner] and apply the standard result/error handling
  /// for an initial load. On success with non-empty result, the state
  /// becomes [ViewState.content]; on empty result, [ViewState.empty].
  /// On failure, [ViewState.error] with [errorMessage] populated.

  Future<void> runLoad(Future<List<T>> Function() runner) async {
    state.value = ViewState.loading;
    errorMessage.value = '';
    try {
      final result = await runner();
      items.assignAll(result);
      state.value =
          result.isEmpty ? ViewState.empty : ViewState.content;
    } catch (e) {
      errorMessage.value = _formatError(e);
      state.value = ViewState.error;
    }
  }

  /// Helper: run [runner] as a pull-to-refresh. The previous [items] are
  /// retained on failure/timeout.

  Future<void> runRefresh(Future<List<T>> Function() runner) async {
    if (isRefreshing.value) return; // guard against concurrent calls
    isRefreshing.value = true;
    final previous = List<T>.of(items);
    try {
      final result = await runner().timeout(refreshTimeout);
      items.assignAll(result);
      state.value =
          result.isEmpty ? ViewState.empty : ViewState.content;
      errorMessage.value = '';
    } catch (_) {
      // Refresh failed or timed out — keep prior items (req 11.4).
      items.assignAll(previous);
    } finally {
      isRefreshing.value = false;
    }
  }

  String _formatError(Object e) {
    return ApiException.messageFrom(e);
  }
}
