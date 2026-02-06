class ArxivException implements Exception {
  ArxivException(this.message);

  final String message;

  @override
  String toString() => 'ArxivException: $message';
}

class ArxivHttpException extends ArxivException {
  ArxivHttpException({
    required this.statusCode,
    required this.requestUrl,
    required this.responseBody,
  }) : super('HTTP $statusCode for $requestUrl');

  final int statusCode;
  final Uri requestUrl;
  final String responseBody;

  @override
  String toString() => 'ArxivHttpException: HTTP $statusCode for $requestUrl';
}

class ArxivApiException extends ArxivException {
  ArxivApiException({
    required this.errorId,
    required this.summary,
    this.helpUrl,
  }) : super(summary);

  final String errorId;
  final String summary;
  final String? helpUrl;

  @override
  String toString() => 'ArxivApiException: $summary';
}
