import 'cache.dart';
import 'clock.dart';
import 'errors.dart';
import 'http_client.dart';
import 'models.dart';
import 'parser.dart';
import 'parsing/atom_parser.dart';
import 'query.dart';

class ArxivClientConfig {
  const ArxivClientConfig({
    this.baseUrl = 'https://export.arxiv.org/api/query',
    this.pageSize = 100,
    this.throttle = const Duration(seconds: 3),
    this.cacheTtl = const Duration(hours: 24),
    this.maxResultsCap = 2000,
    this.enforceMaxResultsCap = true,
    this.userAgent,
    this.defaultHeaders = const {},
    this.timeout = const Duration(seconds: 30),
  });

  final String baseUrl;
  final int pageSize;
  final Duration throttle;
  final Duration cacheTtl;
  final int maxResultsCap;
  final bool enforceMaxResultsCap;
  final String? userAgent;
  final Map<String, String> defaultHeaders;
  final Duration timeout;
}

class ArxivClient {
  ArxivClient({
    ArxivClientConfig? config,
    ArxivHttpClient? httpClient,
    ArxivCache? cache,
    ArxivClock? clock,
    ArxivFeedParser? parser,
  })  : config = config ?? const ArxivClientConfig(),
        _httpClient = httpClient ?? DefaultArxivHttpClient(),
        _cache = cache ?? InMemoryArxivCache(),
        _clock = clock ?? const SystemArxivClock(),
        _parser = parser ?? AtomParser();

  final ArxivClientConfig config;
  final ArxivHttpClient _httpClient;
  final ArxivCache _cache;
  final ArxivClock _clock;
  final ArxivFeedParser _parser;

  DateTime? _lastRequestAt;

  Future<ArxivResultPage> search(ArxivQuery query) async {
    _validateQuery(query);

    final effectiveMax = _effectiveMaxResults(query.maxResults);
    final params = query.toQueryParameters(defaultMaxResults: effectiveMax);
    if (config.enforceMaxResultsCap &&
        query.maxResults != null &&
        query.maxResults! > config.maxResultsCap) {
      params['max_results'] = effectiveMax.toString();
    }
    final uri = _buildUri(params);

    final cached = await _getCached(uri);
    if (cached != null) {
      return _parser.parse(cached.payload);
    }

    await _applyThrottle();

    final headers = _buildHeaders();
    final response = await _httpClient
        .get(uri, headers: headers)
        .timeout(config.timeout);

    if (response.statusCode != 200) {
      throw ArxivHttpException(
        statusCode: response.statusCode,
        requestUrl: uri,
        responseBody: response.body,
      );
    }

    await _storeCache(uri, response.body);
    return _parser.parse(response.body);
  }

  Future<void> close() => _httpClient.close();

  void _validateQuery(ArxivQuery query) {
    final hasSearch = query.searchQuery != null && query.searchQuery!.isNotEmpty;
    final hasIds = query.idList != null && query.idList!.isNotEmpty;
    if (hasSearch && hasIds) {
      throw ArxivException('Provide either searchQuery or idList, not both.');
    }
    if (!hasSearch && !hasIds) {
      throw ArxivException('Provide either searchQuery or idList.');
    }
    if (query.start != null && query.start! < 0) {
      throw ArxivException('start must be >= 0.');
    }
    if (query.maxResults != null && query.maxResults! <= 0) {
      throw ArxivException('maxResults must be > 0.');
    }
  }

  int _effectiveMaxResults(int? requested) {
    final fallback = config.pageSize;
    final effective = requested ?? fallback;
    if (!config.enforceMaxResultsCap) {
      return effective;
    }
    if (effective > config.maxResultsCap) {
      return config.maxResultsCap;
    }
    return effective;
  }

  Uri _buildUri(Map<String, String> params) {
    final base = Uri.parse(config.baseUrl);
    final merged = <String, String>{};
    merged.addAll(base.queryParameters);
    merged.addAll(params);
    return base.replace(queryParameters: merged);
  }

  Map<String, String> _buildHeaders() {
    final headers = <String, String>{};
    headers.addAll(config.defaultHeaders);
    if (config.userAgent != null && config.userAgent!.trim().isNotEmpty) {
      headers['User-Agent'] = config.userAgent!.trim();
    }
    return headers;
  }

  Future<void> _applyThrottle() async {
    if (config.throttle <= Duration.zero) {
      _lastRequestAt = _clock.now().toUtc();
      return;
    }

    final now = _clock.now().toUtc();
    final last = _lastRequestAt;
    if (last != null) {
      final elapsed = now.difference(last);
      if (elapsed < config.throttle) {
        final delay = config.throttle - elapsed;
        await _clock.delay(delay);
      }
    }
    _lastRequestAt = _clock.now().toUtc();
  }

  Future<ArxivCacheEntry?> _getCached(Uri uri) async {
    if (config.cacheTtl <= Duration.zero) return null;
    final key = _cacheKey(uri);
    final entry = await _cache.get(key);
    if (entry == null) return null;
    final now = _clock.now().toUtc();
    if (now.difference(entry.storedAt.toUtc()) > config.cacheTtl) {
      return null;
    }
    return entry;
  }

  Future<void> _storeCache(Uri uri, String payload) async {
    if (config.cacheTtl <= Duration.zero) return;
    final key = _cacheKey(uri);
    await _cache.set(
      key,
      ArxivCacheEntry(
        storedAt: _clock.now().toUtc(),
        payload: payload,
      ),
    );
  }

  String _cacheKey(Uri uri) {
    final now = _clock.now().toUtc();
    final day = '${now.year.toString().padLeft(4, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
    return '${uri.toString()}|$day';
  }
}
