<p align="center">
  <h1 align="center">async_guard</h1>
  <p align="center">
    Prevent duplicate async calls, handle loading & errors in one line.
    <br />
    <em>No more boilerplate. No more bugs. Just guard it.</em>
  </p>
</p>

<p align="center">
  <a href="https://pub.dev/packages/async_guard"><img src="https://img.shields.io/pub/v/async_guard.svg" alt="pub version"></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-3-0175C2.svg?logo=dart" alt="Dart 3"></a>
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-3.10+-02569B.svg?logo=flutter" alt="Flutter"></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="License: MIT"></a>
</p>

---

## What is this?

`async_guard` is a **lightweight utility** that wraps any async call with production-ready protections — in a single line:

- 🛡️ **Duplicate prevention** — block concurrent calls with the same ID
- ⏳ **Loading state** — one callback, automatic start/stop
- 🚨 **Error handling** — built-in try-catch, no boilerplate
- ⏱️ **Timeout support** — auto-cancel long-running tasks
- 🧬 **Lifecycle safe** — guards against `setState` after `dispose`
- 🔘 **GuardedButton** — drop-in widget with double-tap protection & loading indicator
- 🪄 **Extension syntax** — chain `.guard()` on any `Future`

> Every Flutter developer writes the same 15 lines of loading/error/duplicate boilerplate.
> `async_guard` replaces all of it with **one function call**.

---

## Getting Started

### Installation

```yaml
dependencies:
  async_guard: ^0.0.1
```

```bash
flutter pub get
```

### Minimal Example

```dart
import 'package:async_guard/async_guard.dart';

// That's it. Errors caught, duplicates blocked.
final result = await guard(() => api.login());
```

---

## Usage

### Basic

```dart
final result = await guard(() => api.login());
```

If `login()` throws, the error is caught. If the same call is already running, the duplicate is ignored.

### With loading state

```dart
await guard(
  () => api.login(),
  onLoading: (isLoading) => setState(() => loading = isLoading),
);
```

`onLoading(true)` fires before execution, `onLoading(false)` fires after — regardless of success or failure.

### With error handling

```dart
await guard(
  () => api.login(),
  onError: (e) => showSnackBar('Failed: $e'),
);
```

### Full example

```dart
final user = await guard<User>(
  () => api.login(email, password),
  id: 'login',
  onLoading: (v) => setState(() => isLoading = v),
  onSuccess: (user) => navigateTo('/home'),
  onError: (e) => showSnackBar('Error: $e'),
  timeout: Duration(seconds: 10),
);
```

---

## GuardedButton

A drop-in widget that handles everything automatically:

```dart
GuardedButton(
  onTap: () => api.submit(data),
  child: Text('Submit'),
)
```

- ✅ Disables itself while running
- ✅ Shows a loading indicator
- ✅ Prevents double-tap
- ✅ Zero configuration needed

Customize the loading indicator:

```dart
GuardedButton(
  onTap: () => api.submit(data),
  loadingIndicator: CircularProgressIndicator(color: Colors.white),
  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
  child: Text('Submit'),
)
```

---

## Extension Syntax

Chain `.guard()` on any `Future`:

```dart
final token = await api.login(email, password).guard(id: 'login');
```

With callbacks:

```dart
await api.login(email, password).guard(
  id: 'login',
  onLoading: (v) => setState(() => loading = v),
  onError: (e) => showError(e),
);
```

---

## Lifecycle-Safe Async

Prevent `setState` after `dispose` crashes:

```dart
@override
void initState() {
  super.initState();
  safeAsync(this, () async {
    final data = await api.fetchData();
    setState(() => _data = data);
  });
}
```

Or use the extension on `State`:

```dart
this.runSafe(() async {
  final data = await api.fetchData();
  setState(() => _data = data);
});
```

---

## API Reference

### `guard<T>()`

| Parameter | Type | Default | Description |
|---|---|---|---|
| `task` | `Future<T> Function()` | — | The async function to execute |
| `id` | `String?` | auto | Unique ID for duplicate prevention |
| `onLoading` | `void Function(bool)?` | — | Loading state callback |
| `onSuccess` | `void Function(T)?` | — | Success callback |
| `onError` | `void Function(Object)?` | — | Error callback |
| `timeout` | `Duration?` | — | Max execution duration |
| `preventDuplicate` | `bool` | `true` | Block concurrent duplicate calls |

### `safeAsync()`

| Parameter | Type | Description |
|---|---|---|
| `state` | `State` | The widget's `State` object |
| `task` | `Future<void> Function()` | The async function to run |
| `onError` | `void Function(Object)?` | Error callback (lifecycle-safe) |

### `GuardedButton`

| Parameter | Type | Default | Description |
|---|---|---|---|
| `onTap` | `Future<void> Function()` | — | Async callback on press |
| `child` | `Widget` | — | Button content |
| `loadingIndicator` | `Widget?` | — | Custom loading widget |
| `disabledWhileLoading` | `bool` | `true` | Disable button while running |
| `style` | `ButtonStyle?` | — | Optional button style |

### Extensions

| Extension | On | Method | Description |
|---|---|---|---|
| `GuardExtension<T>` | `Future<T>` | `.guard()` | Same params as `guard<T>()` |
| `SafeAsyncExtension` | `State` | `.runSafe()` | Shorthand for `safeAsync(this, task)` |

---

## Why This Package?

Flutter async code is **repetitive and error-prone**:

```dart
// ❌ What you write today — every single time
bool _isLoading = false;

Future<void> _submit() async {
  if (_isLoading) return;           // prevent double tap
  setState(() => _isLoading = true);
  try {
    await api.submit();
  } catch (e) {
    showError(e);
  } finally {
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}
```

```dart
// ✅ With async_guard
await guard(
  () => api.submit(),
  id: 'submit',
  onLoading: (v) => setState(() => _isLoading = v),
  onError: (e) => showError(e),
);
```

**15 lines → 5 lines.** No bugs, no forgetting `mounted`, no duplicate calls.

---

## Architecture

```
lib/
 ├── async_guard.dart          ← Barrel export
 └── src/
      ├── guard.dart           ← Core guard() function
      ├── guard_manager.dart   ← Singleton task tracker
      ├── safe_async.dart      ← Lifecycle-safe async helpers
      ├── guarded_button.dart  ← Double-tap-proof button widget
      └── extensions.dart      ← Future<T>.guard() extension
```

Zero dependencies beyond Flutter SDK. Lightweight, tree-shakeable, and fully tested.

---

## Requirements

| Requirement | Version |
|---|---|
| Dart SDK | `>=3.0.0 <4.0.0` |
| Flutter | `>=3.10.0` |
| Null safety | ✅ |
| Dependencies | **None** (Flutter SDK only) |

---

## 💖 Support

If this package helps you build better Flutter apps, consider supporting the development:

<a href="https://sociabuzz.com/faridl29/support">
  <img src="https://img.shields.io/badge/Support_on-SociaBuzz-ff6b6b?style=for-the-badge" alt="Support on SociaBuzz">
</a>

Your support helps keep this package maintained and up-to-date. Every contribution is greatly appreciated! 🙏

---

## License

MIT — see [LICENSE](LICENSE) for details.
# async_guard
