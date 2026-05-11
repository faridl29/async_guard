# Changelog

## 0.0.1

* Initial release.
* `guard()` — top-level async wrapper with duplicate prevention, loading state, error handling, and timeout.
* `GuardManager` — singleton for tracking running tasks.
* `safeAsync()` — lifecycle-safe async execution for `State` objects.
* `SafeAsyncExtension` on `State` — fluent `runSafe()` syntax.
* `GuardedButton` — widget with built-in double-tap protection and loading indicator.
* `GuardExtension` on `Future` — chain `.guard()` on any future.
