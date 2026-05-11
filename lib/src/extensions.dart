import 'guard.dart' as core;

/// Extension on [Future] for a fluent guard syntax.
///
/// Instead of wrapping your call with the `guard()` function:
/// ```dart
/// await guard(() => api.login());
/// ```
///
/// You can chain `.guard()` directly on any future:
/// ```dart
/// await api.login().guard(id: 'login');
/// ```
extension GuardExtension<T> on Future<T> {
  /// Wraps this future with the same protections as the top-level [guard]
  /// function: duplicate prevention, loading state, error handling, and
  /// optional timeout.
  ///
  /// See [guard] for full parameter documentation.
  Future<T?> guard({
    String? id,
    void Function(bool isLoading)? onLoading,
    void Function(T result)? onSuccess,
    void Function(Object error)? onError,
    Duration? timeout,
    bool preventDuplicate = true,
  }) {
    return core.guard<T>(
      () => this,
      id: id,
      onLoading: onLoading,
      onSuccess: onSuccess,
      onError: onError,
      timeout: timeout,
      preventDuplicate: preventDuplicate,
    );
  }
}
