import '../index.dart';

extension DartFileEditBuilderExt on DartFileEditBuilder {
  void formatWithPageWidth(SourceRange range, {int pageWidth = 100}) {
    format(range);
  }
}
