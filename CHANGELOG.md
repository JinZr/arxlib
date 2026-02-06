## 0.0.2

* Added `ArxivQuery.searchWithIdFilter` to support combined
  `search_query` + `id_list`.
* Aligned validation with API semantics by allowing `max_results = 0`.
* Enforced a single in-flight request per client while preserving throttle.
* Added parsing support for `arxiv:affiliation` on authors.
* Added `ArxivApiException` when arXiv returns an Atom error feed.

## 0.0.1

* Initial release with arXiv API client, query builder, Atom parsing,
  built-in throttle, and same-day cache.
