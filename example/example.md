# arxlib example

`arxlib` provides a typed Dart client for the arXiv API.

```dart
import 'package:arxlib/arxlib.dart';

Future<void> main() async {
  final client = ArxivClient(
    config: const ArxivClientConfig(
      userAgent: 'my-app/1.0.0',
    ),
  );

  try {
    final page = await client.search(
      ArxivQuery.latestByCategory('cs.AI', maxResults: 5),
    );

    for (final entry in page.entries) {
      print(entry.title);
    }
  } finally {
    await client.close();
  }
}
```

More runnable examples are in this folder:

- `example/main.dart`
- `example/query_builders.dart`
- `example/client_configuration.dart`
- `example/error_handling.dart`
