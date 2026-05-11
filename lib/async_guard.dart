/// A lightweight Flutter package that prevents duplicate async calls,
/// handles loading & errors in one line, and provides safe lifecycle helpers.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:async_guard/async_guard.dart';
///
/// // Basic usage
/// final result = await guard(() => api.login());
///
/// // With loading state
/// await guard(
///   () => api.login(),
///   onLoading: (v) => setState(() => loading = v),
/// );
///
/// // Extension syntax
/// await api.login().guard(id: 'login');
/// ```
library;

export 'src/guard.dart';
export 'src/guard_manager.dart';
export 'src/safe_async.dart';
export 'src/guarded_button.dart';
export 'src/extensions.dart';
