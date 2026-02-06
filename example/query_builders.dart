import 'package:arxlib/arxlib.dart';

void main() {
  final search = ArxivQuery.search(
    'all:transformer',
    start: 0,
    maxResults: 25,
    sortBy: ArxivSortBy.relevance,
    sortOrder: ArxivSortOrder.descending,
  );

  final idsOnly = ArxivQuery.idList([
    '2101.00001v1',
    '2306.01234v2',
  ], maxResults: 2);

  final combined = ArxivQuery.searchWithIdFilter('cat:cs.CL', [
    '2101.00001v1',
    '2306.01234v2',
  ], maxResults: 10);

  final latest = ArxivQuery.latestByCategory('cs.LG', maxResults: 5);

  final byAuthor = ArxivQuery.byAuthor(
    'Geoffrey Hinton',
    maxResults: 10,
    sortBy: ArxivSortBy.submittedDate,
    sortOrder: ArxivSortOrder.descending,
  );

  final byDateRange = ArxivQuery.withDateRange(
    DateTime.utc(2025, 1, 1),
    DateTime.utc(2025, 1, 31, 23, 59),
    maxResults: 50,
  );

  final examples = {
    'search': search,
    'id_list only': idsOnly,
    'search + id_list': combined,
    'latest by category': latest,
    'by author': byAuthor,
    'date range': byDateRange,
  };

  for (final item in examples.entries) {
    final params = item.value.toQueryParameters(defaultMaxResults: 100);
    print('');
    print('${item.key}:');
    print('  searchQuery: ${item.value.searchQuery}');
    print('  idList: ${item.value.idList}');
    print('  query parameters: $params');
  }
}
