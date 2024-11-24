// ignore_for_file: flutter_style_todos

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:minio/minio.dart';
import 'package:minio/models.dart';
import 'package:minio/src/minio_client.dart';
import 'package:minio/src/minio_helpers.dart';
import 'package:minio/src/utils.dart';

class MinioUploader implements StreamConsumer<Uint8List> {
  MinioUploader(
    this.minio,
    this.client,
    this.bucket,
    this.object,
    this.partSize,
    this.metadata,
    this.onProgress,
  );

  final Minio minio;
  final MinioClient client;
  final String bucket;
  final String object;
  final int partSize;
  final Map<String, String> metadata;
  final void Function(int)? onProgress;

  var _partNumber = 1;

  String? _etag;

  // Complete object upload, value is the length of the part.
  final _parts = <CompletedPart, int>{};

  Map<int?, Part>? _oldParts;

  String? _uploadId;

  // The number of bytes uploaded of the current part.
  int? bytesUploaded;

  @override
  Future addStream(Stream<Uint8List> stream) async {
    await for (var chunk in stream) {
      List<int>? md5digest;
      final headers = <String, String>{};
      headers.addAll(metadata);
      headers['Content-Length'] = chunk.length.toString();
      if (!client.enableSHA256) {
        md5digest = md5.convert(chunk).bytes;
        headers['Content-MD5'] = base64.encode(md5digest);
      }

      if (_partNumber == 1 && chunk.length < partSize) {
        _etag = await _uploadChunk(chunk, headers, null);
        return;
      }

      if (_uploadId == null) {
        await _initMultipartUpload();
      }

      final partNumber = _partNumber++;

      if (_oldParts != null) {
        final oldPart = _oldParts![partNumber];
        if (oldPart != null) {
          md5digest ??= md5.convert(chunk).bytes;
          if (hex.encode(md5digest) == oldPart.eTag) {
            final part = CompletedPart(oldPart.eTag, partNumber);
            _parts[part] = oldPart.size!;
            continue;
          }
        }
      }

      final queries = <String, String?>{
        'partNumber': '$partNumber',
        'uploadId': _uploadId,
      };

      final etag = await _uploadChunk(chunk, headers, queries);
      final part = CompletedPart(etag, partNumber);
      _parts[part] = chunk.length;
    }
  }

  @override
  Future<String?> close() async {
    if (_uploadId == null) return _etag;
    return minio.completeMultipartUpload(
      bucket,
      object,
      _uploadId!,
      _parts.keys.toList(),
    );
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

  Future<String?> _uploadChunk(
    Uint8List chunk,
    Map<String, String> headers,
    Map<String, String?>? queries,
  ) async {
    final resp = await client.request(
      method: 'PUT',
      headers: headers,
      region: minio.region,
      queries: queries,
      bucket: bucket,
      object: object,
      payload: chunk,
      onProgress: _updateProgress,
    );

    validate(resp);

    var etag = resp.headers['etag'];
    if (etag != null) etag = trimDoubleQuote(etag);

    return etag;
  }

  Future<void> _initMultipartUpload() async {
    // FIXME: this code still causes Signature Error
    // FIXME: https://github.com/xtyxtyx/minio-dart/issues/7
    // TODO: uncomment when fixed
    // uploadId = await minio.findUploadId(bucket, object);

    if (_uploadId == null) {
      _uploadId =
          await minio.initiateNewMultipartUpload(bucket, object, metadata);
      return;
    }

    final parts = minio.listParts(bucket, object, _uploadId!);
    final entries = await parts
        .asyncMap((part) => MapEntry(part.partNumber, part))
        .toList();
    _oldParts = Map.fromEntries(entries);
  }

  void _updateProgress(int bytesUploaded) {
    this.bytesUploaded = bytesUploaded;
    _reportUploadProgress();
  }

  void _reportUploadProgress() {
    if (onProgress == null || bytesUploaded == null) {
      return;
    }

    var totalBytesUploaded = bytesUploaded!;

    for (var part in _parts.keys) {
      totalBytesUploaded += _parts[part]!;
    }

    onProgress!(totalBytesUploaded);
  }
}
