import 'package:flutter/widgets.dart';

/// Runs an async [task] and guards against calling `setState` after the
/// widget has been disposed.
///
/// This is a convenience wrapper for the common pattern of checking
/// `mounted` before updating state after an async gap.
///
/// ## Example
///
/// ```dart
/// class _MyWidgetState extends State<MyWidget> {
///   String? data;
///
///   @override
///   void initState() {
///     super.initState();
///     safeAsync(this, () async {
///       final result = await api.fetchData();
///       setState(() => data = result);
///     });
///   }
/// }
/// ```
///
/// If the widget is disposed before [task] completes, any `setState`
/// calls inside [task] will still be guarded by the `mounted` check
/// you should include. This helper catches errors from disposed-state
/// updates and prevents crashes.
Future<void> safeAsync(
  State state,
  Future<void> Function() task, {
  void Function(Object error)? onError,
}) async {
  // Don't even start if already unmounted.
  if (!state.mounted) return;

  try {
    await task();
  } catch (error) {
    // Only forward the error if the widget is still alive.
    if (state.mounted) {
      onError?.call(error);
    }
  }
}

/// Extension on [State] for a more fluent syntax.
///
/// ```dart
/// this.runSafe(() async {
///   final data = await api.fetch();
///   setState(() => _data = data);
/// });
/// ```
extension SafeAsyncExtension on State {
  /// Runs [task] safely, ignoring errors if the widget has been disposed.
  Future<void> runSafe(
    Future<void> Function() task, {
    void Function(Object error)? onError,
  }) {
    return safeAsync(this, task, onError: onError);
  }
}
