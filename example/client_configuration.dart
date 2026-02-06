import 'package:arxlib/arxlib.dart';

Future<void> main() async {
  final config = ArxivClientConfig(
    userAgent: 'arxlib-example-config/0.0.3',
    pageSize: 20,
    throttle: Duration.zero,
    cacheTtl: const Duration(minutes: 30),
    timeout: const Duration(seconds: 15),
    defaultHeaders: const {'Accept': 'application/atom+xml'},
  );

  final client = ArxivClient(config: config);

  try {
    final query = ArxivQuery.search(
      'cat:math.PR AND all:bayesian',
      sortBy: ArxivSortBy.submittedDate,
      sortOrder: ArxivSortOrder.descending,
    );

    final firstPage = await client.search(query);
    final secondPage = await client.search(query);

    print('First request entries: ${firstPage.entries.length}');
    print('Second request entries: ${secondPage.entries.length}');
    print('Configured fallback page size: ${config.pageSize}');
    print('Cache TTL: ${config.cacheTtl}');
  } finally {
    await client.close();
  }
}
