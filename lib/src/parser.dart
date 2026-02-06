import 'models.dart';

/// Parses arXiv Atom XML into structured models.
abstract class ArxivFeedParser {
  /// Parses [xml] into an [ArxivResultPage].
  ArxivResultPage parse(String xml);
}
