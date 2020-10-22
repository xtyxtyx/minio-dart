import 'dart:async';
import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:minio/minio.dart';
import 'package:minio/models.dart';
import 'package:minio/src/minio_client.dart';
import 'package:minio/src/minio_helpers.dart';
import 'package:minio/src/utils.dart';

class MinioUploader implements StreamConsumer<List<int>> {
  MinioUploader(
    this.minio,
    this.client,
    this.bucket,
    this.object,
    this.partSize,
    this.metadata,
  );

  final Minio minio;
  final MinioClient client;
  final String bucket;
  final String object;
  final int partSize;
  final Map<String, String> metadata;

  var partNumber = 1;
  String etag;
  List<CompletedPart> parts = [];
  Map<int, Part> oldParts;
  String uploadId;

  @override
  Future addStream(Stream<List<int>> stream) async {
    await for (var chunk in stream) {
      List<int> md5digest;
      final headers = <String, String>{};
      headers.addAll(metadata);
      headers['Content-Length'] = chunk.length.toString();
      if (!client.enableSHA256) {
        md5digest = md5.convert(chunk).bytes;
        headers['Content-MD5'] = base64.encode(md5digest);
      }

      if (this.partNumber == 1 && chunk.length < partSize) {
        this.etag = await upload(chunk, headers, null);
        return;
      }

      if (uploadId == null) {
        await initMultipartUpload();
      }

      final partNumber = this.partNumber++;

      if (oldParts != null) {
        final oldPart = oldParts[partNumber];
        if (oldPart != null) {
          md5digest ??= md5.convert(chunk).bytes;
          if (hex.encode(md5digest) == oldPart.eTag) {
            final part = CompletedPart(oldPart.eTag, partNumber);
            parts.add(part);
            continue;
          }
        }
      }

      final queries = <String, String>{
        'partNumber': '$partNumber',
        'uploadId': uploadId,
      };

      final etag = await upload(chunk, headers, queries);
      final part = CompletedPart(etag, partNumber);
      parts.add(part);
    }
  }

  @override
  Future<String> close() async {
    if (uploadId == null) return etag;
    return minio.completeMultipartUpload(bucket, object, uploadId, parts);
  }

  Map<String, String> getHeaders(List<int> chunk) {
    final headers = <String, String>{};
    headers.addAll(metadata);
    headers['Content-Length'] = chunk.length.toString();
    if (!client.enableSHA256) {
      final md5digest = md5.convert(chunk).bytes;
      headers['Content-MD5'] = base64.encode(md5digest);
    }
    return headers;
  }

  Future<String> upload(
    List<int> chunk,
    Map<String, String> headers,
    Map<String, String> queries,
  ) async {
    final resp = await client.request(
      method: 'PUT',
      headers: headers,
      queries: queries,
      bucket: bucket,
      object: object,
      payload: chunk,
    );

    validate(resp);

    var etag = resp.headers['etag'];
    if (etag != null) {
      etag = trimDoubleQuote(etag);
    }

    return etag;
  }

  Future<void> initMultipartUpload() async {
    //FIXME: this code still causes Signature Error
    //FIXME: https://github.com/xtyxtyx/minio-dart/issues/7
    //TODO: uncomment when fixed
    // uploadId = await minio.findUploadId(bucket, object);

    if (uploadId == null) {
      uploadId =
          await minio.initiateNewMultipartUpload(bucket, object, metadata);
      return;
    }

    final parts = await minio.listParts(bucket, object, uploadId);
    final entries = await parts
        .asyncMap((part) => MapEntry(part.partNumber, part))
        .toList();
    oldParts = Map.fromEntries(entries);
  }
}
