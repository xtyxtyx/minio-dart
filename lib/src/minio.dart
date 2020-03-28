import 'dart:convert';

import 'package:http/http.dart';
import 'package:minio/models.dart';
import 'package:minio/src/minio_errors.dart';
import 'package:minio/src/minio_helpers.dart';
import 'package:minio/src/minio_s3.dart';
import 'package:minio/src/minio_sign.dart';
import 'package:minio/src/minio_uploader.dart';
import 'package:minio/src/utils.dart';
import 'package:xml/xml.dart' as xml;

class MinioRequest extends BaseRequest {
  MinioRequest(String method, Uri url) : super(method, url);

  dynamic body;

  @override
  ByteStream finalize() {
    super.finalize();
    if (body is String) {
      return ByteStream.fromBytes(utf8.encode(body));
    }
    if (body is List<int>) {
      return ByteStream.fromBytes(body);
    }
    if (body is Stream<List<int>>) {
      return ByteStream(body);
    }
    throw UnsupportedError('unsupported body type: ${body.runtimeType}');
  }
}

class MinioClient {
  MinioClient(this.minio) {
    anonymous = minio.accessKey.isEmpty && minio.secretKey.isEmpty;
    enableSHA256 = !anonymous && !minio.useSSL;
    port = minio.port ?? implyPort(minio.useSSL);
  }

  final Minio minio;
  final String userAgent = 'MinIO (Unknown; Unknown) minio-js/0.0.1';

  bool enableSHA256;
  bool anonymous;
  int port;

  Future<StreamedResponse> _request({
    String method,
    String bucket,
    String object,
    String region,
    String resource,
    dynamic payload = '',
    Map<String, String> queries,
    Map<String, String> headers,
  }) async {
    final url = getRequestUrl(bucket, object, resource, queries);
    final request = MinioRequest(method, url);
    final date = DateTime.now().toUtc();
    final sha256sum = enableSHA256 ? sha256Hex(payload) : 'UNSIGNED-PAYLOAD';

    region ??= await minio.getBucketRegion(bucket);

    request.body = payload;

    request.headers.addAll({
      'host': url.host,
      'user-agent': userAgent,
      'x-amz-date': makeDateLong(date),
      'x-amz-content-sha256': sha256sum,
    });

    if (headers != null) {
      request.headers.addAll(headers);
    }

    final authorization = signV4(minio, request, date, 'us-east-1');
    request.headers['authorization'] = authorization;

    logRequest(request);
    final response = await request.send();
    return response;
  }

  Future<Response> request({
    String method,
    String bucket,
    String object,
    String region,
    String resource,
    dynamic payload = '',
    Map<String, String> queries,
    Map<String, String> headers,
  }) async {
    final stream = _request(
      method: method,
      bucket: bucket,
      object: object,
      region: region,
      payload: payload,
      resource: resource,
      queries: queries,
      headers: headers,
    );

    final response = await Response.fromStream(await stream);
    logResponse(response);

    return response;
  }

  Future<StreamedResponse> requestStream({
    String method,
    String bucket,
    String object,
    String region,
    String resource,
    dynamic payload = '',
    Map<String, String> queries,
    Map<String, String> headers,
  }) async {
    final response = await _request(
      method: method,
      bucket: bucket,
      object: object,
      region: region,
      payload: payload,
      resource: resource,
      queries: queries,
      headers: headers,
    );

    logResponse(response);
    return response;
  }

  Uri getRequestUrl(
    String bucket,
    String object,
    String resource,
    Map<String, String> queries,
  ) {
    var host = minio.endPoint.toLowerCase();
    var path = '/';

    if (isAmazonEndpoint(host)) {
      host = getS3Endpoint(minio.region);
    }

    if (isVirtualHostStyle(host, minio.useSSL, bucket)) {
      if (bucket != null) host = '${bucket}.${host}';
      if (object != null) path = '/${object}';
    } else {
      if (bucket != null) path = '/${bucket}';
      if (object != null) path = '/${bucket}/${object}';
    }

    final resourcePart = resource == null ? '' : '$resource&';
    final queryPart = queries == null ? '' : encodeQueries(queries);
    final query = resourcePart + queryPart;

    return Uri(
      scheme: minio.useSSL ? 'https' : 'http',
      host: host,
      port: minio.port,
      pathSegments: path.split('/'),
      query: query,
    );
  }

  static var enableTrace = true;

  static void logRequest(MinioRequest request) {
    if (!enableTrace) return;

    final buffer = StringBuffer();
    buffer.writeln('REQUEST: ${request.method} ${request.url}');
    for (var header in request.headers.entries) {
      buffer.writeln('${header.key}: ${header.value}');
    }

    if (request.body is List<int>) {
      buffer.writeln('List<int> of size ${request.body.length}');
    } else {
      buffer.writeln(request.body);
    }

    print(buffer.toString());
  }

  static void logResponse(BaseResponse response) {
    if (!enableTrace) return;

    final buffer = StringBuffer();
    buffer.writeln('RESPONSE: ${response.statusCode} ${response.reasonPhrase}');
    for (var header in response.headers.entries) {
      buffer.writeln('${header.key}: ${header.value}');
    }

    if (response is Response) {
      buffer.writeln(response.body);
    } else if (response is StreamedResponse) {
      buffer.writeln('STREAMED BODY');
    }

    print(buffer.toString());
  }
}

class Minio {
  Minio({
    this.endPoint,
    this.port,
    this.useSSL = true,
    this.accessKey = '',
    this.secretKey = '',
    this.sessionToken,
    this.region,
  })  : assert(isValidEndpoint(endPoint)),
        assert(port == null || isValidPort(port)),
        assert(useSSL != null),
        assert(accessKey != null),
        assert(secretKey != null) {
    _client = MinioClient(this);
  }

  final partSize = 64 * 1024 * 1024;
  final maximumPartSize = 5 * 1024 * 1024 * 1024;
  final maxObjectSize = 5 * 1024 * 1024 * 1024 * 1024;

  final String endPoint;
  final int port;
  final bool useSSL;
  final String accessKey;
  final String secretKey;
  final String sessionToken;
  final String region;

  MinioClient _client;
  final _regionMap = <String, String>{};

  Future<bool> bucketExists(String bucket) async {
    MinioInvalidBucketNameError.check(bucket);
    try {
      await _client.request(method: 'HEAD', bucket: bucket);
    } on MinioS3Error catch (e) {
      final code = e.error.code;
      if (code == 'NoSuchBucket' || code == 'NotFound') return false;
      rethrow;
    }
    return true;
  }

  int calculatePartSize(int size) {
    assert(size != null && size >= 0);

    if (size > maxObjectSize) {
      throw ArgumentError('size should not be more than $maxObjectSize');
    }

    if (this.partSize != null) {
      return this.partSize;
    }

    var partSize = this.partSize;
    while (true) {
      if ((partSize * 10000) > size) {
        return partSize;
      }
      partSize += 16 * 1024 * 1024;
    }
  }

  Future<String> completeMultipartUpload(
    String bucket,
    String object,
    String uploadId,
    List<CompletedPart> parts,
  ) async {
    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidObjectNameError.check(object);

    assert(uploadId != null);
    assert(parts != null);

    var queries = {'uploadId': uploadId};
    var payload = CompleteMultipartUpload(parts).toXml().toString();

    final resp = await _client.request(
      method: 'POST',
      bucket: bucket,
      object: object,
      queries: queries,
      payload: payload,
    );
    validate(resp, expect: 200);

    final node = xml.parse(resp.body);
    final errorNode = node.findAllElements('Error');
    if (errorNode.isNotEmpty) {
      final error = Error.fromXml(errorNode.first);
      throw MinioS3Error(error.message, error, resp);
    }

    final etag = node.findAllElements('ETag').first.text;
    return etag;
  }

  Future<String> findUploadID(String bucket, String object) async {
    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidObjectNameError.check(object);

    MultipartUpload latestUpload;
    String keyMarker;
    String uploadIdMarker;
    var isTruncated = false;

    do {
      final result = await listIncompleteUploadsQuery(
        bucket,
        object,
        keyMarker,
        uploadIdMarker,
        '',
      );
      for (var upload in result.uploads) {
        if (upload.key != object) continue;
        if (latestUpload == null ||
            upload.initiated.isAfter(latestUpload.initiated)) {
          latestUpload = upload;
        }
      }
      keyMarker = result.nextKeyMarker;
      uploadIdMarker = result.nextUploadIdMarker;
      isTruncated = result.isTruncated;
    } while (isTruncated);

    return latestUpload?.uploadId;
  }

  Future<String> getBucketRegion(String bucket) async {
    MinioInvalidBucketNameError.check(bucket);

    if (region != null) return region;
    if (_regionMap.containsKey(bucket)) return _regionMap[bucket];

    final resp = await _client.request(
      method: 'GET',
      bucket: bucket,
      region: 'us-east-1',
      queries: {'location': null},
    );

    validate(resp);

    final node = xml.parse(resp.body);
    final location = node.findAllElements('LocationConstraint').first.text;

    _regionMap[bucket] = location ?? 'us-east-1';
    return location;
  }

  Future<ByteStream> getObject(String bucket, String object) {
    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidObjectNameError.check(object);
    return getPartialObject(bucket, object, null, null);
  }

  Future<ByteStream> getPartialObject(
    String bucket,
    String object, [
    int offset,
    int length,
  ]) async {
    assert(offset == null || offset >= 0);
    assert(length == null || length > 0);

    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidObjectNameError.check(object);

    String range;
    if (offset != null || length != null) {
      if (offset != null) {
        range = 'bytes=$offset-';
      } else {
        range = 'bytes=0-';
        offset = 0;
      }
      if (length != null) {
        range += '${(length + offset) - 1}';
      }
    }

    final headers = range != null ? {'range': range} : null;
    final expectedStatus = range != null ? 206 : 200;

    final resp = await _client.requestStream(
      method: 'GET',
      bucket: bucket,
      object: object,
      headers: headers,
    );

    await validateStreamed(resp, expect: expectedStatus);
    return resp.stream;
  }

  Future<String> initiateNewMultipartUpload(
    String bucket,
    String object,
    Map<String, String> metaData,
  ) async {
    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidObjectNameError.check(object);

    final resp = await _client.request(
        method: 'POST',
        bucket: bucket,
        object: object,
        headers: metaData,
        resource: 'uploads');

    validate(resp, expect: 200);

    final node = xml.parse(resp.body);
    return node.findAllElements('UploadId').first.text;
  }

  Stream<IncompleteUpload> listIncompleteUploads(
    String bucket,
    String prefix, [
    bool recursive = false,
  ]) async* {
    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidPrefixError.check(prefix);

    final delimiter = recursive ? '' : '/';

    String keyMarker;
    String uploadIdMarker;
    var isTruncated = false;

    do {
      final result = await listIncompleteUploadsQuery(
        bucket,
        prefix,
        keyMarker,
        uploadIdMarker,
        delimiter,
      );
      for (var upload in result.uploads) {
        final parts = await listParts(bucket, upload.key, upload.uploadId);
        final size = await parts.fold(0, (acc, item) => acc + item.size);
        yield IncompleteUpload(upload: upload, size: size);
      }
      keyMarker = result.nextKeyMarker;
      uploadIdMarker = result.nextUploadIdMarker;
      isTruncated = result.isTruncated;
    } while (isTruncated);
  }

  Future<ListMultipartUploadsOutput> listIncompleteUploadsQuery(
    String bucket,
    String prefix,
    String keyMarker,
    String uploadIdMarker,
    String delimiter,
  ) async {
    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidPrefixError.check(prefix);

    var queries = {
      'uploads': null,
      'prefix': prefix,
      'delimiter': delimiter,
    };

    if (keyMarker != null) {
      queries['key-marker'] = keyMarker;
    }
    if (uploadIdMarker != null) {
      queries['upload-id-marker'] = uploadIdMarker;
    }

    final resp = await _client.request(
      method: 'GET',
      bucket: bucket,
      resource: 'uploads',
      queries: queries,
    );

    validate(resp);

    final node = xml.parse(resp.body);
    return ListMultipartUploadsOutput.fromXml(node.root);
  }

  Future<List<Bucket>> listBuckets() async {
    final resp = await _client.request(
      method: 'GET',
      region: 'us-east-1',
    );
    final bucketsNode = xml.parse(resp.body).findAllElements('Buckets').first;
    return bucketsNode.children.map((n) => Bucket.fromXml(n)).toList();
  }

  /// Returns all [Object]s in a bucket.
  /// If recursive is true, the returned stream may also contains [CommonPrefix]
  Stream<ListObjectsChunk> listObjects(
    String bucket, {
    String prefix = '',
    bool recursive = false,
  }) async* {
    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidPrefixError.check(prefix);
    final delimiter = recursive ? '' : '/';

    var marker = '';
    var isTruncated = false;

    do {
      final resp = await listObjectsQuery(
        bucket,
        prefix,
        marker,
        delimiter,
        1000,
      );
      isTruncated = resp.isTruncated;
      marker = resp.nextMarker;
      yield ListObjectsChunk()
        ..objects = resp.contents
        ..prefixes = resp.commonPrefixes.map((e) => e.prefix).toList();
    } while (isTruncated);
  }

  Future<ListObjectsOutput> listObjectsQuery(
    String bucket,
    String prefix,
    String marker,
    String delimiter,
    int maxKeys,
  ) async {
    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidPrefixError.check(prefix);

    final queries = <String, String>{};
    queries['prefix'] = prefix;
    queries['delimiter'] = delimiter;

    if (marker != null) {
      queries['marker'] = marker;
    }

    if (maxKeys != null) {
      maxKeys = maxKeys >= 1000 ? 1000 : maxKeys;
      queries['maxKeys'] = maxKeys.toString();
    }

    final resp = await _client.request(
      method: 'GET',
      bucket: bucket,
      queries: queries,
    );

    validate(resp);

    final node = xml.parse(resp.body);
    final isTruncated = getNodeProp(node.rootElement, 'IsTruncated')?.text;
    final nextMarker = getNodeProp(node.rootElement, 'NextMarker')?.text;
    final objs = node.findAllElements('Contents').map((c) => Object.fromXml(c));
    final prefixes = node
        .findAllElements('CommonPrefixes')
        .map((c) => CommonPrefix.fromXml(c));

    return ListObjectsOutput()
      ..contents = objs.toList()
      ..commonPrefixes = prefixes.toList()
      ..isTruncated = isTruncated.toLowerCase() == 'true'
      ..nextMarker = nextMarker;
  }

  Stream<Part> listParts(
    String bucket,
    String object,
    String uploadId,
  ) async* {
    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidObjectNameError.check(object);

    var marker = 0;
    var isTruncated = false;
    do {
      final result = await listPartsQuery(bucket, object, uploadId, marker);
      marker = result.nextPartNumberMarker;
      isTruncated = result.isTruncated;
      yield* Stream.fromIterable(result.parts);
    } while (isTruncated);
  }

  Future<ListPartsOutput> listPartsQuery(
    String bucket,
    String object,
    String uploadId,
    int marker,
  ) async {
    var queries = <String, String>{'uploadId': uploadId};

    if (marker != null && marker != 0) {
      queries['part-number-marker'] = marker.toString();
    }

    final resp = await _client.request(
      method: 'GET',
      bucket: bucket,
      object: object,
      queries: queries,
    );

    validate(resp);

    final node = xml.parse(resp.body);
    return ListPartsOutput.fromXml(node.root);
  }

  Future<void> makeBucket(String bucket, [String region]) async {
    MinioInvalidBucketNameError.check(bucket);
    if (this.region != null && region != null && this.region != region) {
      throw MinioInvalidArgumentError(
          'Configured region ${this.region}, requested $region');
    }

    region ??= this.region ?? 'us-east-1';
    final payload = region == 'us-east-1'
        ? ''
        : CreateBucketConfiguration(region).toXml().toString();

    final resp = await _client.request(
      method: 'PUT',
      bucket: bucket,
      region: region,
      payload: payload,
    );

    validate(resp);
    return resp.body;
  }

  Future<String> putObject(
    String bucket,
    String object,
    Stream<List<int>> data,
    int size, {
    Map<String, String> metadata,
  }) async {
    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidObjectNameError.check(object);

    assert(data != null);
    assert(size >= 0 || size == null);

    metadata = prependXAMZMeta(metadata ?? {});

    size ??= maxObjectSize;
    size = calculatePartSize(size);

    final chunker = BlockStream(size);
    final uploader = MinioUploader(
      this,
      _client,
      bucket,
      object,
      size,
      metadata,
    );
    final etag = await data.transform(chunker).pipe(uploader);
    return etag.toString();
  }

  Future<void> removeBucket(String bucket) async {
    MinioInvalidBucketNameError.check(bucket);

    final resp = await _client.request(
      method: 'DELETE',
      bucket: bucket,
    );

    validate(resp, expect: 204);
    _regionMap.remove(bucket);
  }
}

Future<void> validateStreamed(
  StreamedResponse streamedResponse, {
  int expect,
}) async {
  if (streamedResponse.statusCode >= 400) {
    final response = await Response.fromStream(streamedResponse);
    final body = xml.parse(response.body);
    final error = Error.fromXml(body.rootElement);
    throw MinioS3Error(error.message, error, response);
  }

  if (expect != null && streamedResponse.statusCode != expect) {
    final response = await Response.fromStream(streamedResponse);
    throw MinioS3Error(
        '$expect expected, got ${streamedResponse.statusCode}', null, response);
  }
}

void validate(Response response, {int expect}) {
  if (response.statusCode >= 400) {
    final body = xml.parse(response.body);
    final error = Error.fromXml(body.rootElement);
    throw MinioS3Error(error.message, error, response);
  }

  if (expect != null && response.statusCode != expect) {
    throw MinioS3Error(
        '$expect expected, got ${response.statusCode}', null, response);
  }
}
