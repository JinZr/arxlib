import 'errors.dart';

/// Sort keys supported by the arXiv API.
enum ArxivSortBy {
  /// Sort by arXiv relevance score.
  relevance,

  /// Sort by last update timestamp.
  lastUpdatedDate,

  /// Sort by submission timestamp.
  submittedDate,
}

/// Converts [ArxivSortBy] values to API parameter strings.
extension ArxivSortByApi on ArxivSortBy {
  /// API value used in the `sortBy` query parameter.
  String get apiValue {
    switch (this) {
      case ArxivSortBy.relevance:
        return 'relevance';
      case ArxivSortBy.lastUpdatedDate:
        return 'lastUpdatedDate';
      case ArxivSortBy.submittedDate:
        return 'submittedDate';
    }
  }
}

/// Sort direction supported by the arXiv API.
enum ArxivSortOrder {
  /// Sort in ascending order.
  ascending,

  /// Sort in descending order.
  descending,
}

/// Converts [ArxivSortOrder] values to API parameter strings.
extension ArxivSortOrderApi on ArxivSortOrder {
  /// API value used in the `sortOrder` query parameter.
  String get apiValue {
    switch (this) {
      case ArxivSortOrder.ascending:
        return 'ascending';
      case ArxivSortOrder.descending:
        return 'descending';
    }
  }
}

/// Immutable query object for arXiv API requests.
class ArxivQuery {
  const ArxivQuery._({
    this.searchQuery,
    this.idList,
    this.start,
    this.maxResults,
    this.sortBy,
    this.sortOrder,
  });

  /// Raw `search_query` string for the API.
  final String? searchQuery;

  /// IDs for the `id_list` API parameter.
  final List<String>? idList;

  /// Zero-based start offset.
  final int? start;

  /// Maximum number of results to request.
  final int? maxResults;

  /// Optional sort field.
  final ArxivSortBy? sortBy;

  /// Optional sort direction.
  final ArxivSortOrder? sortOrder;

  /// Creates a query from an arXiv search expression.
  factory ArxivQuery.search(
    String searchQuery, {
    int start = 0,
    int? maxResults,
    ArxivSortBy? sortBy,
    ArxivSortOrder? sortOrder,
  }) {
    if (searchQuery.trim().isEmpty) {
      throw ArxivException('searchQuery must not be empty.');
    }
    return ArxivQuery._(
      searchQuery: searchQuery.trim(),
      idList: null,
      start: start,
      maxResults: maxResults,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }

  /// Creates a query that fetches by explicit arXiv IDs.
  factory ArxivQuery.idList(
    List<String> ids, {
    int start = 0,
    int? maxResults,
    ArxivSortBy? sortBy,
    ArxivSortOrder? sortOrder,
  }) {
    final cleaned = ids
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toList();
    if (cleaned.isEmpty) {
      throw ArxivException('idList must not be empty.');
    }
    return ArxivQuery._(
      searchQuery: null,
      idList: cleaned,
      start: start,
      maxResults: maxResults,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }

  /// Creates a query combining a search expression with an ID filter.
  factory ArxivQuery.searchWithIdFilter(
    String searchQuery,
    List<String> ids, {
    int start = 0,
    int? maxResults,
    ArxivSortBy? sortBy,
    ArxivSortOrder? sortOrder,
  }) {
    final trimmed = searchQuery.trim();
    if (trimmed.isEmpty) {
      throw ArxivException('searchQuery must not be empty.');
    }
    final cleaned = ids
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toList();
    if (cleaned.isEmpty) {
      throw ArxivException('idList must not be empty.');
    }
    return ArxivQuery._(
      searchQuery: trimmed,
      idList: cleaned,
      start: start,
      maxResults: maxResults,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }

  /// Creates a latest-first query for a given arXiv category.
  factory ArxivQuery.latestByCategory(
    String category, {
    int start = 0,
    int? maxResults,
  }) {
    final trimmed = category.trim();
    if (trimmed.isEmpty) {
      throw ArxivException('category must not be empty.');
    }
    final query = 'cat:$trimmed';
    return ArxivQuery.search(
      query,
      start: start,
      maxResults: maxResults,
      sortBy: ArxivSortBy.submittedDate,
      sortOrder: ArxivSortOrder.descending,
    );
  }

  /// Creates a query for papers by a specific author.
  factory ArxivQuery.byAuthor(
    String author, {
    int start = 0,
    int? maxResults,
    ArxivSortBy? sortBy,
    ArxivSortOrder? sortOrder,
  }) {
    final trimmed = author.trim();
    if (trimmed.isEmpty) {
      throw ArxivException('author must not be empty.');
    }
    final query = 'au:${_quote(trimmed)}';
    return ArxivQuery.search(
      query,
      start: start,
      maxResults: maxResults,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }

  /// Creates a query constrained to a date range.
  ///
  /// [field] defaults to `submittedDate` and can be changed to supported
  /// date fields accepted by the arXiv search syntax.
  factory ArxivQuery.withDateRange(
    DateTime from,
    DateTime to, {
    String field = 'submittedDate',
    int start = 0,
    int? maxResults,
    ArxivSortBy? sortBy,
    ArxivSortOrder? sortOrder,
  }) {
    final trimmedField = field.trim();
    if (trimmedField.isEmpty) {
      throw ArxivException('field must not be empty.');
    }
    if (to.isBefore(from)) {
      throw ArxivException('Date range end must not be before start.');
    }
    final range = '$trimmedField:[${_formatDate(from)} TO ${_formatDate(to)}]';
    return ArxivQuery.search(
      range,
      start: start,
      maxResults: maxResults,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }

  /// Serializes the query into HTTP query parameters.
  ///
  /// If [defaultMaxResults] is provided, it is used when [maxResults] is null.
  Map<String, String> toQueryParameters({int? defaultMaxResults}) {
    final params = <String, String>{};
    if (searchQuery != null && searchQuery!.trim().isNotEmpty) {
      params['search_query'] = searchQuery!;
    }
    if (idList != null && idList!.isNotEmpty) {
      params['id_list'] = idList!.join(',');
    }
    if (start != null) {
      params['start'] = start!.toString();
    }
    final effectiveMax = maxResults ?? defaultMaxResults;
    if (effectiveMax != null) {
      params['max_results'] = effectiveMax.toString();
    }
    if (sortBy != null) {
      params['sortBy'] = sortBy!.apiValue;
    }
    if (sortOrder != null) {
      params['sortOrder'] = sortOrder!.apiValue;
    }
    return params;
  }
}

String _quote(String value) {
  final escaped = value.replaceAll('"', r'\"').trim();
  if (escaped.contains(' ')) {
    return '"$escaped"';
  }
  return escaped;
}

String _formatDate(DateTime value) {
  final utc = value.toUtc();
  final y = utc.year.toString().padLeft(4, '0');
  final m = utc.month.toString().padLeft(2, '0');
  final d = utc.day.toString().padLeft(2, '0');
  final hh = utc.hour.toString().padLeft(2, '0');
  final mm = utc.minute.toString().padLeft(2, '0');
  return '$y$m$d$hh$mm';
}
