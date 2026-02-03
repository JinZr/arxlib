import 'package:http/http.dart' as http;

class ArxivHttpResponse {
  ArxivHttpResponse({
    required this.statusCode,
    required this.body,
    required this.headers,
  });

  final int statusCode;
  final String body;
  final Map<String, String> headers;
}

abstract class ArxivHttpClient {
  Future<ArxivHttpResponse> get(
    Uri uri, {
    Map<String, String>? headers,
  });

  Future<void> close();
}

class DefaultArxivHttpClient implements ArxivHttpClient {
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
