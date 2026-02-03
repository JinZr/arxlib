import 'errors.dart';

enum ArxivSortBy { relevance, lastUpdatedDate, submittedDate }

extension ArxivSortByApi on ArxivSortBy {
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

enum ArxivSortOrder { ascending, descending }

extension ArxivSortOrderApi on ArxivSortOrder {
  String get apiValue {
    switch (this) {
      case ArxivSortOrder.ascending:
        return 'ascending';
      case ArxivSortOrder.descending:
        return 'descending';
    }
  }
}

class ArxivQuery {
  const ArxivQuery._({
    this.searchQuery,
    this.idList,
    this.start,
    this.maxResults,
    this.sortBy,
    this.sortOrder,
  });

  final String? searchQuery;
  final List<String>? idList;
  final int? start;
  final int? maxResults;
  final ArxivSortBy? sortBy;
  final ArxivSortOrder? sortOrder;

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

  factory ArxivQuery.idList(
    List<String> ids, {
    int start = 0,
    int? maxResults,
    ArxivSortBy? sortBy,
    ArxivSortOrder? sortOrder,
  }) {
    final cleaned = ids.map((id) => id.trim()).where((id) => id.isNotEmpty).toList();
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
    final range =
        '$trimmedField:[${_formatDate(from)} TO ${_formatDate(to)}]';
    return ArxivQuery.search(
      range,
      start: start,
      maxResults: maxResults,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );
  }

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
