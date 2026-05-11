import 'package:flutter/material.dart';

/// A button widget that automatically prevents double-tap and shows a
/// loading indicator while an async operation is in progress.
///
/// ## Example
///
/// ```dart
/// GuardedButton(
///   onTap: () async {
///     await api.submitForm(data);
///   },
///   child: Text('Submit'),
/// )
/// ```
///
/// Optionally customize the loading indicator:
///
/// ```dart
/// GuardedButton(
///   onTap: () => api.submit(),
///   loadingIndicator: CircularProgressIndicator(color: Colors.white),
///   child: Text('Submit'),
/// )
/// ```
class GuardedButton extends StatefulWidget {
  /// Creates a [GuardedButton].
  ///
  /// [onTap] is the async callback invoked when the button is pressed.
  /// [child] is the default content of the button.
  const GuardedButton({
    super.key,
    required this.onTap,
    required this.child,
    this.loadingIndicator,
    this.disabledWhileLoading = true,
    this.style,
  });

  /// The async operation to perform on tap.
  final Future<void> Function() onTap;

  /// The button's default content (shown when not loading).
  final Widget child;

  /// Optional custom loading indicator. Defaults to a small
  /// [CircularProgressIndicator] sized to match typical button text.
  final Widget? loadingIndicator;

  /// Whether to disable the button while the task is running.
  /// Defaults to `true`.
  final bool disabledWhileLoading;

  /// Optional [ButtonStyle] applied to the underlying [ElevatedButton].
  final ButtonStyle? style;

  @override
  State<GuardedButton> createState() => _GuardedButtonState();
}

class _GuardedButtonState extends State<GuardedButton> {
  bool _isLoading = false;

  Future<void> _handleTap() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      await widget.onTap();
    } catch (_) {
      // Errors are intentionally swallowed — the caller should handle
      // errors inside onTap or use the guard() function for error handling.
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = _isLoading && widget.disabledWhileLoading;

    return ElevatedButton(
      onPressed: isDisabled ? null : _handleTap,
      style: widget.style,
      child: _isLoading
          ? widget.loadingIndicator ??
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
          : widget.child,
    );
  }
}
