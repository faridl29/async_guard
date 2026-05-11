/// Manages running task state for duplicate execution prevention.
///
/// This is an internal singleton that tracks which task IDs are currently
/// in-flight. You typically don't interact with this directly — use the
/// top-level [guard] function instead.
class GuardManager {
  GuardManager._();

  /// Shared singleton instance.
  static final GuardManager instance = GuardManager._();

  /// Map of currently running task IDs.
  final Map<String, bool> _runningTasks = {};

  /// Returns `true` if a task with the given [id] is currently running.
  bool isRunning(String id) => _runningTasks[id] == true;

  /// Marks a task [id] as running.
  void markRunning(String id) {
    _runningTasks[id] = true;
  }

  /// Marks a task [id] as completed and removes it from the map.
  void markCompleted(String id) {
    _runningTasks.remove(id);
  }

  /// Clears all tracked tasks. Useful for testing or cleanup.
  void reset() {
    _runningTasks.clear();
  }

  /// Returns the number of currently running tasks.
  int get runningCount => _runningTasks.length;
}
