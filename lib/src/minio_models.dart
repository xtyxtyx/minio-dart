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

class ListMultipartUploadsOutput {
  ListMultipartUploadsOutput.fromXml(XmlElement xml) {
    isTruncated = getProp(xml, 'IsLatest')?.text?.toUpperCase() == 'TRUE';
    nextKeyMarker = getProp(xml, 'NextKeyMarker')?.text;
    nextUploadIdMarker = getProp(xml, 'NextUploadIdMarker')?.text;
    uploads = xml
        .findElements('Upload')
        .map((e) => MultipartUpload.fromXml(e))
        .toList();
  }

  bool isTruncated;
  String nextKeyMarker;
  String nextUploadIdMarker;
  List<MultipartUpload> uploads;
}

class ListPartsOutput {
  ListPartsOutput.fromXml(XmlElement xml) {
    isTruncated = getProp(xml, 'IsLatest')?.text?.toUpperCase() == 'TRUE';
    nextPartNumberMarker =
        int.parse(getProp(xml, 'NextPartNumberMarker')?.text);
    parts = xml.findElements('Upload').map((e) => Part.fromXml(e)).toList();
  }

  bool isTruncated;
  int nextPartNumberMarker;
  List<Part> parts;
}

class IncompleteUpload {
  IncompleteUpload({
    this.upload,
    this.size,
  });

  final MultipartUpload upload;
  final int size;
}

class CopyConditions {
  String modified;
  String unmodified;
  String matchETag;
  String matchETagExcept;

  void setModified(DateTime date) {
    modified = date.toUtc().toIso8601String();
  }

  void setUnmodified(DateTime date) {
    unmodified = date.toUtc().toIso8601String();
  }

  void setMatchETag(String etag) {
    matchETag = etag;
  }

  void setMatchETagExcept(String etag) {
    matchETagExcept = etag;
  }
}

class StatObjectResult {
  StatObjectResult({
    this.size,
    this.etag,
    this.lastModified,
    this.metaData,
  });
  
  final int size;
  final String etag;
  final DateTime lastModified;
  final Map<String, String> metaData;
}
