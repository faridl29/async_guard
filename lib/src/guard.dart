import 'dart:async';

import 'guard_manager.dart';

/// Wraps an async [task] with duplicate prevention, loading state,
/// error handling, and optional timeout — all in one call.
///
/// ## Parameters
///
/// * [task] — The async function to execute.
/// * [id] — A unique identifier for this task. When [preventDuplicate] is
///   `true`, a new call with the same [id] will be ignored if one is already
///   running. If omitted, a unique ID is generated automatically.
/// * [onLoading] — Called with `true` before execution starts and `false`
///   after it completes (whether success or failure).
/// * [onSuccess] — Called with the result when [task] completes successfully.
/// * [onError] — Called when [task] throws. If omitted, errors are silently
///   swallowed and the function returns `null`.
/// * [timeout] — Maximum duration to wait for [task]. If exceeded, a
///   [TimeoutException] is triggered and forwarded to [onError].
/// * [preventDuplicate] — When `true` (default), prevents concurrent
///   execution of tasks sharing the same [id].
///
/// ## Returns
///
/// The result of [task], or `null` if the task was skipped (duplicate),
/// timed out, or threw an error.
///
/// ## Example
///
/// ```dart
/// final user = await guard(
///   () => api.login(email, password),
///   id: 'login',
///   onLoading: (v) => setState(() => isLoading = v),
///   onSuccess: (user) => navigate('/home'),
///   onError: (e) => showSnackBar('Login failed: $e'),
///   timeout: Duration(seconds: 10),
/// );
/// ```
Future<T?> guard<T>(
  Future<T> Function() task, {
  String? id,
  void Function(bool isLoading)? onLoading,
  void Function(T result)? onSuccess,
  void Function(Object error)? onError,
  Duration? timeout,
  bool preventDuplicate = true,
}) async {
  final manager = GuardManager.instance;
  final taskId =
      id ?? 'guard_${task.hashCode}_${DateTime.now().microsecondsSinceEpoch}';

  // Block duplicate execution if already running.
  if (preventDuplicate && manager.isRunning(taskId)) {
    return null;
  }

  manager.markRunning(taskId);
  onLoading?.call(true);

  try {
    Future<T> execution = task();

    // Apply timeout if specified.
    if (timeout != null) {
      execution = execution.timeout(timeout);
    }

    final result = await execution;
    onSuccess?.call(result);
    return result;
  } catch (error) {
    onError?.call(error);
    return null;
  } finally {
    manager.markCompleted(taskId);
    onLoading?.call(false);
  }
}
