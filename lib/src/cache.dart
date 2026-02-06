/// Stores a cached arXiv response payload with its write timestamp.
class ArxivCacheEntry {
  /// Creates a cache entry.
  ArxivCacheEntry({
    required this.storedAt,
    required this.payload,
  });

  /// UTC timestamp when the payload was stored.
  final DateTime storedAt;

  /// Raw XML response payload.
  final String payload;
}

/// Interface for cache backends used by [ArxivClient].
abstract class ArxivCache {
  /// Returns a cached entry for [key], or `null` if absent.
  Future<ArxivCacheEntry?> get(String key);

  /// Stores [entry] under [key], replacing any existing value.
  Future<void> set(String key, ArxivCacheEntry entry);
}

/// In-memory [ArxivCache] implementation backed by a map.
class InMemoryArxivCache implements ArxivCache {
  final Map<String, ArxivCacheEntry> _store = {};

  @override
  Future<ArxivCacheEntry?> get(String key) async => _store[key];

  @override
  Future<void> set(String key, ArxivCacheEntry entry) async {
    _store[key] = entry;
  }
}
