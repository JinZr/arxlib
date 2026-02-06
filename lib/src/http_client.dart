import 'package:http/http.dart' as http;

/// Simplified HTTP response object used by the client layer.
class ArxivHttpResponse {
  /// Creates an HTTP response wrapper.
  ArxivHttpResponse({
    required this.statusCode,
    required this.body,
    required this.headers,
  });

  /// HTTP status code.
  final int statusCode;

  /// Response body text.
  final String body;

  /// Response headers.
  final Map<String, String> headers;
}

/// Interface used by [ArxivClient] to perform HTTP requests.
abstract class ArxivHttpClient {
  /// Sends a GET request to [uri].
  Future<ArxivHttpResponse> get(
    Uri uri, {
    Map<String, String>? headers,
  });

  /// Releases underlying resources.
  Future<void> close();
}

/// Default [ArxivHttpClient] implementation backed by `package:http`.
class DefaultArxivHttpClient implements ArxivHttpClient {
  /// Creates an HTTP client using [client] or a default `http.Client`.
  DefaultArxivHttpClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<ArxivHttpResponse> get(
    Uri uri, {
    Map<String, String>? headers,
  }) async {
    final response = await _client.get(uri, headers: headers);
    return ArxivHttpResponse(
      statusCode: response.statusCode,
      body: response.body,
      headers: response.headers,
    );
  }

  @override
  Future<void> close() async {
    _client.close();
  }
}
