/// One page of arXiv search results.
class ArxivResultPage {
  /// Creates a result page.
  ArxivResultPage({
    required this.entries,
    required this.totalResults,
    required this.startIndex,
    required this.itemsPerPage,
  });

  /// Parsed entries returned in this page.
  final List<ArxivEntry> entries;

  /// Total number of matches reported by the API.
  final int totalResults;

  /// Start offset of this page.
  final int startIndex;

  /// Number of items requested per page.
  final int itemsPerPage;
}

/// Metadata for a single arXiv entry.
class ArxivEntry {
  /// Creates an arXiv entry model.
  ArxivEntry({
    required this.id,
    required this.title,
    required this.summary,
    required this.published,
    required this.updated,
    required this.authors,
    required this.links,
    required this.categories,
    this.primaryCategory,
    this.comment,
    this.journalRef,
    this.doi,
  });

  /// Canonical entry identifier URL.
  final String id;

  /// Entry title.
  final String title;

  /// Entry abstract text.
  final String summary;

  /// Original publication timestamp.
  final DateTime published;

  /// Most recent update timestamp.
  final DateTime updated;

  /// Author list.
  final List<ArxivAuthor> authors;

  /// Associated links.
  final List<ArxivLink> links;

  /// Category tags.
  final List<ArxivCategory> categories;

  /// Primary category, when provided.
  final ArxivCategory? primaryCategory;

  /// Optional author comment.
  final String? comment;

  /// Optional journal reference.
  final String? journalRef;

  /// Optional DOI.
  final String? doi;
}

/// Author metadata for an entry.
class ArxivAuthor {
  /// Creates an author.
  ArxivAuthor({required this.name, this.affiliation});

  /// Display name.
  final String name;

  /// Optional affiliation.
  final String? affiliation;
}

/// Link metadata for an entry.
class ArxivLink {
  /// Creates a link.
  ArxivLink({required this.href, this.rel, this.type, this.title});

  /// Link URL.
  final String href;

  /// Optional link relation.
  final String? rel;

  /// Optional media type.
  final String? type;

  /// Optional link title.
  final String? title;
}

/// Category metadata for an entry.
class ArxivCategory {
  /// Creates a category.
  ArxivCategory({required this.term, this.scheme, this.label});

  /// Category term identifier.
  final String term;

  /// Optional scheme URL.
  final String? scheme;

  /// Optional display label.
  final String? label;
}
