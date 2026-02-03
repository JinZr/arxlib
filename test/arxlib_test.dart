import 'package:arxlib/arxlib.dart';
import 'package:test/test.dart';

const _sampleFeed = '''
<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom"
      xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/"
      xmlns:arxiv="http://arxiv.org/schemas/atom">
  <opensearch:totalResults>1</opensearch:totalResults>
  <opensearch:startIndex>0</opensearch:startIndex>
  <opensearch:itemsPerPage>1</opensearch:itemsPerPage>
  <entry>
    <id>http://arxiv.org/abs/1234.5678v1</id>
    <updated>2024-01-02T00:00:00Z</updated>
    <published>2024-01-01T00:00:00Z</published>
    <title>Test Title</title>
    <summary>Test summary</summary>
    <author><name>Ada Lovelace</name></author>
    <link rel="alternate" href="http://arxiv.org/abs/1234.5678v1"/>
    <category term="cs.AI" scheme="http://arxiv.org/schemas/atom"/>
    <arxiv:primary_category term="cs.AI" scheme="http://arxiv.org/schemas/atom"/>
    <arxiv:comment>12 pages</arxiv:comment>
    <arxiv:journal_ref>Journal</arxiv:journal_ref>
    <arxiv:doi>10.1000/test</arxiv:doi>
  </entry>
</feed>
''';

class FakeClock implements ArxivClock {
  FakeClock(this._now);

  DateTime _now;
  final List<Duration> delays = [];

  @override
  DateTime now() => _now;

  @override
  Future<void> delay(Duration duration) async {
    delays.add(duration);
    _now = _now.add(duration);
  }
}

class FakeHttpClient implements ArxivHttpClient {
  FakeHttpClient(this._handler);

  final ArxivHttpResponse Function(Uri uri, Map<String, String>? headers)
      _handler;
  final List<Uri> requested = [];

  @override
  Future<ArxivHttpResponse> get(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    requested.add(uri);
    return _handler(uri, headers);
  }

  @override
  Future<void> close() async {}
}

void main() {
  test('parses a sample feed', () async {
    final fakeHttp = FakeHttpClient(
      (uri, headers) =>
          ArxivHttpResponse(statusCode: 200, body: _sampleFeed, headers: {}),
    );
    final client = ArxivClient(
      httpClient: fakeHttp,
      clock: FakeClock(DateTime.utc(2024, 1, 1)),
      config: const ArxivClientConfig(
        throttle: Duration.zero,
        cacheTtl: Duration.zero,
      ),
    );

    final page = await client.search(ArxivQuery.search('all:parse-test'));
    expect(page.totalResults, 1);
    expect(page.entries, hasLength(1));
    final entry = page.entries.first;
    expect(entry.title, 'Test Title');
    expect(entry.summary, 'Test summary');
    expect(entry.authors.first.name, 'Ada Lovelace');
    expect(entry.primaryCategory?.term, 'cs.AI');
    expect(entry.comment, '12 pages');
    expect(entry.journalRef, 'Journal');
    expect(entry.doi, '10.1000/test');
  });

  test('builds correct query parameters', () async {
    final fakeHttp = FakeHttpClient(
      (uri, headers) =>
          ArxivHttpResponse(statusCode: 200, body: _sampleFeed, headers: {}),
    );
    final clock = FakeClock(DateTime.utc(2024, 1, 1));
    final client = ArxivClient(
      httpClient: fakeHttp,
      clock: clock,
      config: const ArxivClientConfig(
        pageSize: 50,
        cacheTtl: Duration.zero,
        throttle: Duration.zero,
      ),
    );

    await client.search(
      ArxivQuery.search(
        'all:electron',
        start: 5,
        maxResults: 10,
        sortBy: ArxivSortBy.relevance,
        sortOrder: ArxivSortOrder.descending,
      ),
    );

    final uri = fakeHttp.requested.single;
    expect(uri.queryParameters['search_query'], 'all:electron');
    expect(uri.queryParameters['start'], '5');
    expect(uri.queryParameters['max_results'], '10');
    expect(uri.queryParameters['sortBy'], 'relevance');
    expect(uri.queryParameters['sortOrder'], 'descending');
  });

  test('uses cache for same-day request', () async {
    var calls = 0;
    final fakeHttp = FakeHttpClient((uri, headers) {
      calls += 1;
      return ArxivHttpResponse(statusCode: 200, body: _sampleFeed, headers: {});
    });
    final clock = FakeClock(DateTime.utc(2024, 1, 1, 10));
    final client = ArxivClient(
      httpClient: fakeHttp,
      clock: clock,
      config: const ArxivClientConfig(
        throttle: Duration.zero,
        cacheTtl: Duration(hours: 24),
      ),
    );

    final query = ArxivQuery.search('all:cache-test');
    await client.search(query);
    await client.search(query);

    expect(calls, 1);
  });

  test('applies throttle between requests', () async {
    final fakeHttp = FakeHttpClient(
      (uri, headers) =>
          ArxivHttpResponse(statusCode: 200, body: _sampleFeed, headers: {}),
    );
    final clock = FakeClock(DateTime.utc(2024, 1, 1));
    final client = ArxivClient(
      httpClient: fakeHttp,
      clock: clock,
      config: const ArxivClientConfig(
        throttle: Duration(seconds: 3),
        cacheTtl: Duration.zero,
      ),
    );

    final query = ArxivQuery.search('all:throttle-test');
    await client.search(query);
    await client.search(query);

    expect(clock.delays, [const Duration(seconds: 3)]);
  });

  test('throws on HTTP error', () async {
    final fakeHttp = FakeHttpClient(
      (uri, headers) =>
          ArxivHttpResponse(statusCode: 500, body: 'fail', headers: {}),
    );
    final client = ArxivClient(
      httpClient: fakeHttp,
      clock: FakeClock(DateTime.utc(2024, 1, 1)),
      config: const ArxivClientConfig(
        throttle: Duration.zero,
        cacheTtl: Duration.zero,
      ),
    );

    expect(
      () => client.search(ArxivQuery.search('all:error-test')),
      throwsA(isA<ArxivHttpException>()),
    );
  });

  test('builds a date range query', () {
    final from = DateTime.utc(2024, 1, 1, 0, 0);
    final to = DateTime.utc(2024, 1, 2, 23, 59);
    final query = ArxivQuery.withDateRange(from, to);
    expect(query.searchQuery, contains('submittedDate:['));
    expect(query.searchQuery, contains('TO'));
  });

  test('caps maxResults when enforcement is enabled', () async {
    final fakeHttp = FakeHttpClient(
      (uri, headers) =>
          ArxivHttpResponse(statusCode: 200, body: _sampleFeed, headers: {}),
    );
    final client = ArxivClient(
      httpClient: fakeHttp,
      clock: FakeClock(DateTime.utc(2024, 1, 1)),
      config: const ArxivClientConfig(
        throttle: Duration.zero,
        cacheTtl: Duration.zero,
        maxResultsCap: 2000,
        enforceMaxResultsCap: true,
      ),
    );

    await client.search(
      ArxivQuery.search('all:cap-test', maxResults: 5000),
    );

    final uri = fakeHttp.requested.single;
    expect(uri.queryParameters['max_results'], '2000');
  });
}
