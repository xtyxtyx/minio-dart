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

  Future<Response> request({
    String method,
    String bucket,
    String object,
    String region,
    String payload = '',
    Map<String, String> query,
  }) async {
    final url = getRequestUrl(bucket, object, query);
    final request = MinioRequest(method, url);
    final date = DateTime.now().toUtc();
    final sha256sum = enableSHA256 ? sha256Hex(payload) : 'UNSIGNED-PAYLOAD';

    request.headers.addAll({
      'host': url.host,
      'user-agent': userAgent,
      'x-amz-date': makeDateLong(date),
      'x-amz-content-sha256': sha256sum,
    });

    final authorization = signV4(minio, request, date, 'us-east-1');
    request.headers['authorization'] = authorization;
    logRequest(request);

    final response = await Response.fromStream(await request.send());
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

  static var enableTrace = false;

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

  static void logResponse(Response response) {
    if (!enableTrace) return;

    final buffer = StringBuffer();
    buffer.writeln('RESPONSE: ${response.statusCode} ${response.reasonPhrase}');
    for (var header in response.headers.entries) {
      buffer.writeln('${header.key}: ${header.value}');
    }
    buffer.writeln(response.body);

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

  Future<bool> bucketExists(String bucket) async {
    MinioInvalidBucketNameError.check(bucket);
    final resp = await _client.request(method: 'HEAD', bucket: bucket);
    if (resp.statusCode != 200 && resp.statusCode != 404) {
      throw MinioS3Error('bucketExists failed.');
    }
    return resp.statusCode == 200;
  }

  Future<String> getBucketRegion(String bucket) async {
    MinioInvalidBucketNameError.check(bucket);
    if (region != null) return region;

    final resp = await _client.request(
      method: 'GET',
      bucket: bucket,
      region: 'us-east-1',
      query: {'location': null},
    );

    validate(resp);
    return resp.body;
  }
}

void validate(Response response) {
  if (response.statusCode >= 400) {
    final body = xml.parse(response.body);
    final error = Error.fromXml(body.rootElement);
    throw MinioS3Error(error.message, error, response);
  }
}
