class ArxivResultPage {
  ArxivResultPage({
    required this.entries,
    required this.totalResults,
    required this.startIndex,
    required this.itemsPerPage,
  });

  final List<ArxivEntry> entries;
  final int totalResults;
  final int startIndex;
  final int itemsPerPage;
}

class ArxivEntry {
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

  final String id;
  final String title;
  final String summary;
  final DateTime published;
  final DateTime updated;
  final List<ArxivAuthor> authors;
  final List<ArxivLink> links;
  final List<ArxivCategory> categories;
  final ArxivCategory? primaryCategory;
  final String? comment;
  final String? journalRef;
  final String? doi;
}

class ArxivAuthor {
  ArxivAuthor({required this.name, this.affiliation});

  final String name;
  final String? affiliation;
}

class ArxivLink {
  ArxivLink({required this.href, this.rel, this.type, this.title});

  final String href;
  final String? rel;
  final String? type;
  final String? title;
}

class ArxivCategory {
  ArxivCategory({required this.term, this.scheme, this.label});

  final String term;
  final String? scheme;
  final String? label;
}
