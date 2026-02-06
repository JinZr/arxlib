import 'package:arxlib/arxlib.dart';

Future<void> main() async {
  final client = ArxivClient(
    config: const ArxivClientConfig(userAgent: 'arxlib-example-main/0.0.3'),
  );

  try {
    final page = await client.search(
      ArxivQuery.latestByCategory('cs.AI', maxResults: 5),
    );

    print('Showing ${page.entries.length} of ${page.totalResults} results.');
    for (final entry in page.entries) {
      final authors = entry.authors.map((author) => author.name).join(', ');
      print('');
      print(entry.title);
      print('  id: ${entry.id}');
      print('  published: ${entry.published.toUtc().toIso8601String()}');
      print('  authors: $authors');
      print('  primary category: ${entry.primaryCategory?.term ?? 'n/a'}');
    }
  } on ArxivApiException catch (error) {
    print('API error: ${error.summary}');
    print('error id: ${error.errorId}');
    if (error.helpUrl != null) {
      print('help: ${error.helpUrl}');
    }
  } on ArxivHttpException catch (error) {
    print('HTTP error ${error.statusCode}: ${error.requestUrl}');
    print('response body: ${error.responseBody}');
  } finally {
    await client.close();
  }
}
