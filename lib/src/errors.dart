/// Base exception for arXiv client errors.
class ArxivException implements Exception {
  /// Creates an exception with a readable [message].
  ArxivException(this.message);

  /// Human-readable error message.
  final String message;

  @override
  String toString() => 'ArxivException: $message';
}

/// HTTP-layer failure returned by the arXiv endpoint.
class ArxivHttpException extends ArxivException {
  /// Creates an HTTP exception with request and response details.
  ArxivHttpException({
    required this.statusCode,
    required this.requestUrl,
    required this.responseBody,
  }) : super('HTTP $statusCode for $requestUrl');

  /// HTTP status code from the response.
  final int statusCode;

  /// Request URL that produced the error.
  final Uri requestUrl;

  /// Raw HTTP response body.
  final String responseBody;

  @override
  String toString() => 'ArxivHttpException: HTTP $statusCode for $requestUrl';
}

/// API-level error represented inside an otherwise valid Atom feed.
class ArxivApiException extends ArxivException {
  /// Creates an API exception from parsed feed error fields.
  ArxivApiException({
    required this.errorId,
    required this.summary,
    this.helpUrl,
  }) : super(summary);

  /// Error identifier value from the feed.
  final String errorId;

  /// Error summary provided by the API.
  final String summary;

  /// Optional URL with additional help text.
  final String? helpUrl;

  @override
  String toString() => 'ArxivApiException: $summary';
}
