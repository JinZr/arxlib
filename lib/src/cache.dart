class ArxivCacheEntry {
  ArxivCacheEntry({
    required this.storedAt,
    required this.payload,
  });

  final DateTime storedAt;
  final String payload;
}

abstract class ArxivCache {
  Future<ArxivCacheEntry?> get(String key);
  Future<void> set(String key, ArxivCacheEntry entry);
}

class InMemoryArxivCache implements ArxivCache {
  final Map<String, ArxivCacheEntry> _store = {};

  @override
  Future<ArxivCacheEntry?> get(String key) async => _store[key];

  @override
  Future<void> set(String key, ArxivCacheEntry entry) async {
    _store[key] = entry;
  }
}
