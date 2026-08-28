//
//  test_state_logger.dart
//

import 'dart:async';

import 'package:movies_core/movies_core.dart';

class TestLoggerTimeout implements Exception {
  const TestLoggerTimeout();

  @override
  String toString() => 'TestLoggerTimeout';
}

/// Records every state a view model publishes so a test can await transitions
/// instead of polling.
final class TestStateLogger<State> {
  TestStateLogger() {
    _subscription = _controller.stream.listen(_buffer.add);
  }

  final _controller = StreamController<State>.broadcast();
  final _buffer = <State>[];
  late final StreamSubscription<State> _subscription;
  var _consumed = 0;

  StateLogger<State> get log => _controller.add;

  Future<void> dispose() async {
    await _subscription.cancel();
    await _controller.close();
  }

  Future<State> next() async {
    final events = await collect(count: 1);
    return events.first;
  }

  /// Waits for [count] states that have not been returned yet.
  Future<List<State>> collect({
    required int count,
    Duration timeout = const Duration(seconds: 2),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (_buffer.length - _consumed < count) {
      if (DateTime.now().isAfter(deadline)) throw const TestLoggerTimeout();
      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
    final events = _buffer.sublist(_consumed, _consumed + count);
    _consumed += count;
    return events;
  }
}
