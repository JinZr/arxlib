import 'models.dart';

abstract class ArxivFeedParser {
  ArxivResultPage parse(String xml);
}
