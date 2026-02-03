abstract class ArxivClock {
  DateTime now();

  Future<void> delay(Duration duration);
}

class SystemArxivClock implements ArxivClock {
  const SystemArxivClock();

  @override
  DateTime now() => DateTime.now();

  @override
  Future<void> delay(Duration duration) => Future.delayed(duration);
}
