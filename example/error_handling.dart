import 'package:arxlib/arxlib.dart';

Future<void> main() async {
  final client = ArxivClient(
    config: const ArxivClientConfig(userAgent: 'arxlib-example-errors/0.0.3'),
  );

  try {
    await client.search(
      ArxivQuery.searchWithIdFilter('all:quantum', [
        'not-a-valid-arxiv-id',
      ], maxResults: 1),
    );
  } on ArxivApiException catch (error) {
    print('Arxiv API returned a structured error feed.');
    print('  errorId: ${error.errorId}');
    print('  summary: ${error.summary}');
    print('  helpUrl: ${error.helpUrl ?? '(none)'}');
  } on ArxivHttpException catch (error) {
    print('HTTP transport error: ${error.statusCode}');
    print('  requestUrl: ${error.requestUrl}');
    print('  body: ${error.responseBody}');
  } on ArxivException catch (error) {
    print('Library validation/runtime error: ${error.message}');
  } finally {
    await client.close();
  }
}
