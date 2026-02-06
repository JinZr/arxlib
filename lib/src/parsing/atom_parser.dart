import 'package:xml/xml.dart';

import '../errors.dart';
import '../models.dart';
import '../parser.dart';

/// Atom feed parser implementation for arXiv API responses.
class AtomParser implements ArxivFeedParser {
  @override
  ArxivResultPage parse(String xml) {
    final document = XmlDocument.parse(xml);
    final feed = document.rootElement;
    if (feed.name.local != 'feed') {
      throw ArxivException('Unexpected root element: ${feed.name.local}');
    }

    final entries = _childrenByLocalName(
      feed,
      'entry',
    ).map(_parseEntry).toList(growable: false);

    if (entries.length == 1 && _isApiErrorEntry(entries.first)) {
      final errorEntry = entries.first;
      final summary = errorEntry.summary.trim().isEmpty
          ? 'arXiv API returned an error response.'
          : errorEntry.summary.trim();
      final helpUrl = errorEntry.links.isEmpty
          ? null
          : errorEntry.links.first.href;
      throw ArxivApiException(
        errorId: errorEntry.id,
        summary: summary,
        helpUrl: helpUrl,
      );
    }

    final totalResults =
        _intFromElement(feed, 'totalResults') ?? entries.length;
    final startIndex = _intFromElement(feed, 'startIndex') ?? 0;
    final itemsPerPage =
        _intFromElement(feed, 'itemsPerPage') ?? entries.length;

    return ArxivResultPage(
      entries: entries,
      totalResults: totalResults,
      startIndex: startIndex,
      itemsPerPage: itemsPerPage,
    );
  }

  ArxivEntry _parseEntry(XmlElement entry) {
    final id = _textOf(entry, 'id') ?? '';
    final title = _normalizeWhitespace(_textOf(entry, 'title') ?? '');
    final summary = _normalizeWhitespace(_textOf(entry, 'summary') ?? '');

    final published = _parseDate(_textOf(entry, 'published'));
    final updated = _parseDate(_textOf(entry, 'updated'));

    final authors = _childrenByLocalName(entry, 'author')
        .map(
          (author) => ArxivAuthor(
            name: _textOf(author, 'name') ?? '',
            affiliation: _optionalTrimmedText(_textOf(author, 'affiliation')),
          ),
        )
        .toList(growable: false);

    final links = _childrenByLocalName(entry, 'link')
        .map(
          (link) => ArxivLink(
            href: link.getAttribute('href') ?? '',
            rel: link.getAttribute('rel'),
            type: link.getAttribute('type'),
            title: link.getAttribute('title'),
          ),
        )
        .where((link) => link.href.isNotEmpty)
        .toList(growable: false);

    final categories = _childrenByLocalName(entry, 'category')
        .map(
          (category) => ArxivCategory(
            term: category.getAttribute('term') ?? '',
            scheme: category.getAttribute('scheme'),
            label: category.getAttribute('label'),
          ),
        )
        .where((category) => category.term.isNotEmpty)
        .toList(growable: false);

    final primaryCategoryElement = _firstChildByLocalName(
      entry,
      'primary_category',
    );
    final primaryCategory = primaryCategoryElement == null
        ? null
        : ArxivCategory(
            term: primaryCategoryElement.getAttribute('term') ?? '',
            scheme: primaryCategoryElement.getAttribute('scheme'),
            label: primaryCategoryElement.getAttribute('label'),
          );

    final comment = _textOf(entry, 'comment');
    final journalRef = _textOf(entry, 'journal_ref');
    final doi = _textOf(entry, 'doi');

    return ArxivEntry(
      id: id,
      title: title,
      summary: summary,
      published: published,
      updated: updated,
      authors: authors,
      links: links,
      categories: categories,
      primaryCategory: primaryCategory,
      comment: comment?.trim().isEmpty == true ? null : comment?.trim(),
      journalRef: journalRef?.trim().isEmpty == true
          ? null
          : journalRef?.trim(),
      doi: doi?.trim().isEmpty == true ? null : doi?.trim(),
    );
  }

  bool _isApiErrorEntry(ArxivEntry entry) {
    final normalizedTitle = entry.title.trim().toLowerCase();
    final normalizedId = entry.id.trim().toLowerCase();
    return normalizedTitle == 'error' &&
        (normalizedId.contains('/api/errors#') ||
            normalizedId.contains('/help/api/errors#'));
  }

  DateTime _parseDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }
    return DateTime.parse(value);
  }

  int? _intFromElement(XmlElement parent, String localName) {
    final text = _textOf(parent, localName);
    if (text == null) return null;
    return int.tryParse(text.trim());
  }

  String? _textOf(XmlElement parent, String localName) {
    final element = _firstChildByLocalName(parent, localName);
    return element?.innerText;
  }

  XmlElement? _firstChildByLocalName(XmlElement parent, String localName) {
    for (final child in parent.children) {
      if (child is XmlElement && child.name.local == localName) {
        return child;
      }
    }
    return null;
  }

  Iterable<XmlElement> _childrenByLocalName(
    XmlElement parent,
    String localName,
  ) sync* {
    for (final child in parent.children) {
      if (child is XmlElement && child.name.local == localName) {
        yield child;
      }
    }
  }

  String _normalizeWhitespace(String value) {
    return value.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  String? _optionalTrimmedText(String? value) {
    if (value == null) {
      return null;
    }
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
