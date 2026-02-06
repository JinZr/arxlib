/// Abstraction for time and delays used by throttling and cache logic.
abstract class ArxivClock {
  /// Returns the current wall-clock time.
  DateTime now();

  /// Waits for the provided [duration].
  Future<void> delay(Duration duration);
}

/// Default [ArxivClock] based on `DateTime.now` and `Future.delayed`.
class SystemArxivClock implements ArxivClock {
  /// Creates a system clock.
  const SystemArxivClock();

  @override
  DateTime now() => DateTime.now();

  @override
  Future<void> delay(Duration duration) => Future.delayed(duration);
}
