import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:async_guard/async_guard.dart';

void main() {
  setUp(() {
    // Reset the singleton state before each test.
    GuardManager.instance.reset();
  });

  group('GuardManager', () {
    test('isRunning returns false for unknown task', () {
      expect(GuardManager.instance.isRunning('unknown'), isFalse);
    });

    test('markRunning and isRunning work correctly', () {
      GuardManager.instance.markRunning('task_1');
      expect(GuardManager.instance.isRunning('task_1'), isTrue);
    });

    test('markCompleted removes task', () {
      GuardManager.instance.markRunning('task_1');
      GuardManager.instance.markCompleted('task_1');
      expect(GuardManager.instance.isRunning('task_1'), isFalse);
    });

    test('reset clears all tasks', () {
      GuardManager.instance.markRunning('a');
      GuardManager.instance.markRunning('b');
      expect(GuardManager.instance.runningCount, 2);
      GuardManager.instance.reset();
      expect(GuardManager.instance.runningCount, 0);
    });

    test('runningCount returns correct count', () {
      expect(GuardManager.instance.runningCount, 0);
      GuardManager.instance.markRunning('x');
      expect(GuardManager.instance.runningCount, 1);
      GuardManager.instance.markRunning('y');
      expect(GuardManager.instance.runningCount, 2);
    });
  });

  group('guard()', () {
    test('returns result on success', () async {
      final result = await guard<int>(
        () async => 42,
        id: 'success_test',
      );
      expect(result, 42);
    });

    test('returns null on error', () async {
      final result = await guard<int>(
        () async => throw Exception('fail'),
        id: 'error_test',
      );
      expect(result, isNull);
    });

    test('calls onSuccess with result', () async {
      int? captured;
      await guard<int>(
        () async => 99,
        id: 'on_success',
        onSuccess: (v) => captured = v,
      );
      expect(captured, 99);
    });

    test('calls onError with exception', () async {
      Object? captured;
      await guard<int>(
        () async => throw const FormatException('bad'),
        id: 'on_error',
        onError: (e) => captured = e,
      );
      expect(captured, isA<FormatException>());
    });

    test('calls onLoading true then false on success', () async {
      final loadingStates = <bool>[];
      await guard<int>(
        () async => 1,
        id: 'loading_success',
        onLoading: (v) => loadingStates.add(v),
      );
      expect(loadingStates, [true, false]);
    });

    test('calls onLoading true then false on error', () async {
      final loadingStates = <bool>[];
      await guard<int>(
        () async => throw Exception('err'),
        id: 'loading_error',
        onLoading: (v) => loadingStates.add(v),
      );
      expect(loadingStates, [true, false]);
    });

    test('prevents duplicate execution with same id', () async {
      int callCount = 0;
      final completer = Completer<int>();

      // First call — will hang until we complete it.
      final future1 = guard<int>(
        () {
          callCount++;
          return completer.future;
        },
        id: 'dup',
      );

      // Second call with same id — should be ignored.
      final result2 = await guard<int>(
        () async {
          callCount++;
          return 2;
        },
        id: 'dup',
      );

      // Complete the first call.
      completer.complete(1);
      final result1 = await future1;

      expect(callCount, 1);
      expect(result1, 1);
      expect(result2, isNull);
    });

    test('allows duplicate when preventDuplicate is false', () async {
      int callCount = 0;
      final completer = Completer<int>();

      // First call.
      final future1 = guard<int>(
        () {
          callCount++;
          return completer.future;
        },
        id: 'allow_dup',
      );

      // Second call with preventDuplicate = false.
      final future2 = guard<int>(
        () async {
          callCount++;
          return 2;
        },
        id: 'allow_dup',
        preventDuplicate: false,
      );

      completer.complete(1);
      await future1;
      await future2;

      expect(callCount, 2);
    });

    test('cleans up running state after completion', () async {
      await guard<int>(
        () async => 1,
        id: 'cleanup',
      );
      expect(GuardManager.instance.isRunning('cleanup'), isFalse);
    });

    test('cleans up running state after error', () async {
      await guard<int>(
        () async => throw Exception('err'),
        id: 'cleanup_err',
      );
      expect(GuardManager.instance.isRunning('cleanup_err'), isFalse);
    });

    test('supports timeout — completes before deadline', () async {
      final result = await guard<String>(
        () async {
          await Future.delayed(const Duration(milliseconds: 50));
          return 'done';
        },
        id: 'timeout_ok',
        timeout: const Duration(seconds: 2),
      );
      expect(result, 'done');
    });

    test('supports timeout — exceeds deadline', () async {
      Object? caughtError;
      final result = await guard<String>(
        () async {
          await Future.delayed(const Duration(seconds: 10));
          return 'too late';
        },
        id: 'timeout_fail',
        timeout: const Duration(milliseconds: 50),
        onError: (e) => caughtError = e,
      );
      expect(result, isNull);
      expect(caughtError, isA<TimeoutException>());
    });

    test('auto-generates id when not provided', () async {
      // Should not throw and should complete normally.
      final result = await guard<int>(() async => 7);
      expect(result, 7);
    });
  });

  group('GuardExtension', () {
    test('.guard() returns result', () async {
      final result = await Future.value(42).guard(id: 'ext_test');
      expect(result, 42);
    });

    test('.guard() catches errors', () async {
      Object? captured;
      final result = await Future<int>.error(Exception('ext_err')).guard(
        id: 'ext_err_test',
        onError: (e) => captured = e,
      );
      expect(result, isNull);
      expect(captured, isA<Exception>());
    });
  });
}
