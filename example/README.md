# Examples

This package follows Dart package layout conventions by placing runnable
examples in `example/`.

Run any example from the repository root:

```bash
dart run example/main.dart
dart run example/query_builders.dart
dart run example/client_configuration.dart
dart run example/error_handling.dart
```

## Files

- `main.dart`: minimal end-to-end search with typed result parsing.
- `query_builders.dart`: all core `ArxivQuery` constructors and generated query
  parameters.
- `client_configuration.dart`: fundamental `ArxivClientConfig` settings
  (headers, timeout, throttle, cache TTL, page size).
- `error_handling.dart`: handling `ArxivApiException`, `ArxivHttpException`, and
  generic `ArxivException`.
