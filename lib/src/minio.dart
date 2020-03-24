import 'dart:collection';

import 'package:http/http.dart';
import 'package:minio/models.dart';
import 'package:minio/src/minio_errors.dart';
import 'package:minio/src/minio_helpers.dart';
import 'package:minio/src/minio_s3.dart';
import 'package:minio/src/minio_sign.dart';
import 'package:xml/xml.dart' as xml;

class MinioRequest extends Request {
  MinioRequest(String method, Uri url) : super(method, url);
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
    String payload = '',
    Map<String, String> queries,
    Map<String, String> headers,
  }) async {
    final url = getRequestUrl(bucket, object, queries);
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
    String payload = '',
    Map<String, String> queries,
    Map<String, String> headers,
  }) async {
    final stream = _request(
      method: method,
      bucket: bucket,
      object: object,
      region: region,
      payload: payload,
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
    String payload = '',
    Map<String, String> queries,
    Map<String, String> headers,
  }) async {
    final response = await _request(
      method: method,
      bucket: bucket,
      object: object,
      region: region,
      payload: payload,
      queries: queries,
      headers: headers,
    );

    logResponse(response);
    return response;
  }

  Uri getRequestUrl(String bucket, String object, Map<String, String> query) {
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

    return Uri(
      scheme: minio.useSSL ? 'https' : 'http',
      host: host,
      port: minio.port,
      pathSegments: path.split('/'),
      queryParameters: query,
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
    buffer.writeln(request.body);

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
    final resp = await _client.request(method: 'HEAD', bucket: bucket);
    if (resp.statusCode != 200 && resp.statusCode != 404) {
      throw MinioS3Error('bucketExists failed.');
    }
    return resp.statusCode == 200;
  }

  Future<String> completeMultipartUpload(
    String bucket,
    String object,
    int uploadId,
    List<CompletedPart> parts,
  ) async {
    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidObjectNameError.check(object);

    assert(uploadId != null);
    assert(parts != null);

    var queries = {'uploadId': 'uploadId'};
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

    _regionMap[bucket] = location;
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

  Future putObject(
    String bucket,
    String object,
    Stream data,
    int size, {
    Map<String, String> metadata,
  }) async {
    MinioInvalidBucketNameError.check(bucket);
    MinioInvalidObjectNameError.check(object);
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
