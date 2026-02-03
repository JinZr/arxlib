# arxlib

A lightweight Dart client for the arXiv API. It provides a query builder,
paged results, Atom parsing into typed models, and a built-in throttle with
same-day in-memory caching.

## Features

- Query builder for `search_query` and `id_list`
- Paged search results with total counts
- Atom feed parsing into typed models
- Built-in throttling (1 request / 3 seconds by default)
- Same-day in-memory cache (configurable)

## Getting started

Add `arxlib` to your `pubspec.yaml`, then run `dart pub get`.

## Usage

```dart
import 'package:arxlib/arxlib.dart';

Future<void> main() async {
  final client = ArxivClient(
    config: const ArxivClientConfig(
      userAgent: 'myapp/0.1',
    ),
  );

  final page = await client.search(
    ArxivQuery.latestByCategory('cs.AI', maxResults: 20),
  );

  for (final entry in page.entries) {
    print('${entry.title} (${entry.published.toIso8601String()})');
  }

  await client.close();
}
```

## Additional information

Notes:
- `ArxivQuery.withDateRange` builds a `submittedDate` range query using UTC
  timestamps in `yyyyMMddHHmm` format. You can always pass a custom
  `searchQuery` string for advanced cases.
- By default, results are cached in memory for the same day and throttled to
  1 request every 3 seconds. Adjust `ArxivClientConfig` if needed.
