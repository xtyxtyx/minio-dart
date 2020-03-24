import 'package:minio/models.dart';
import 'package:xml/xml.dart';

class ListObjectsChunk {
  List<Object> objects;
  List<String> prefixes;
}

class ListObjectsOutput {
  bool isTruncated;
  String nextMarker;
  List<Object> contents;
  List<CommonPrefix> commonPrefixes;
}

class CompleteMultipartUpload {
  CompleteMultipartUpload(
    this.parts,
  );

  XmlNode toXml() {
    final builder = XmlBuilder();
    builder.element('CompleteMultipartUpload', nest: () {
      builder.element('Parts', nest: parts.map((p) => p.toXml()));
    });
    return builder.build();
  }

  /// Array of CompletedPart data types.
  List<CompletedPart> parts;
}
