import 'dart:async';

import 'package:minio/minio.dart';

class MinioUploader implements StreamConsumer<List<int>> {
  MinioUploader(
    this.client,
    this.bucket,
    this.object,
    this.partSize,
    this.metaData,
  );

  final Minio client;
  final String bucket;
  final String object;
  final int partSize;
  final Map<String, String> metaData;

  var emptyStream = true;
  var partNumber = 1;
  var etags = [];
  List oldParts;
  String id;

  @override
  Future addStream(Stream<List<int>> stream) {
    // TODO: implement addStream
    throw UnimplementedError();
  }

  @override
  Future close() {
    // TODO: implement close
    throw UnimplementedError();
  }
}
