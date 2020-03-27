import 'dart:async';
import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:minio/minio.dart';
import 'package:minio/models.dart';

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
        return uploadInOneGo(chunk, headers);
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

      final queries = {
        'partNumber': partNumber,
        'uploadId': uploadId,
      };

      final resp = await client.request(
        method: 'PUT',
        queries: queries,
        headers: headers,
        bucket: bucket,
        object: object,
      );

      validate(resp);

      var etag = resp.headers['etag'];
      if (etag != null) {
        etag = etag.replaceAll(RegExp('^"'), '').replaceAll(RegExp(r'"$'), '');
      }
      final part = CompletedPart(etag, partNumber);
      parts.add(part);
    }
  }

  @override
  Future<String> close() async {
    if (uploadId == null) {
      return etag;
    }

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

  Future<void> uploadInOneGo(
      List<int> chunk, Map<String, String> headers) async {
    final resp = await client.request(
      method: 'PUT',
      headers: headers,
      bucket: bucket,
      object: object,
      payload: chunk,
    );

    validate(resp);

    etag = resp.headers['etag'];
    if (etag != null) {
      etag = etag.replaceAll(RegExp('^"'), '').replaceAll(RegExp(r'"$'), '');
    }
  }

  Future<void> initMultipartUpload() async {
    uploadId = await minio.findUploadID(bucket, object);

    if (uploadId == null) {
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
