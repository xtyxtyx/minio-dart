import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:minio/minio.dart';
import 'package:minio/src/minio_helpers.dart';

const signV4Algorithm = 'AWS4-HMAC-SHA256';

String signV4(
  Minio minio,
  MinioRequest request,
  DateTime requestDate,
  String region,
) {
  final signedHeaders = getSignedHeaders(request.headers.keys);
  final canonicalRequest = getCanonicalRequest(request, signedHeaders);
  final stringToSign = getStringToSign(canonicalRequest, requestDate, region);
  final signingKey = getSigningKey(requestDate, region, minio.secretKey);
  final credential = getCredential(minio.accessKey, region, requestDate);
  final signature = hex.encode(
    Hmac(sha256, signingKey).convert(stringToSign.codeUnits).bytes,
  );
  return '$signV4Algorithm Credential=$credential, SignedHeaders=${signedHeaders.join(';').toLowerCase()}, Signature=$signature';
}

List<String> getSignedHeaders(Iterable<String> headers) {
  const ignored = {
    'authorization',
    'content-length',
    'content-type',
    'user-agent'
  };
  final result = headers.where((header) => !ignored.contains(header)).toList();
  result.sort();
  return result;
}

String getCanonicalRequest(MinioRequest request, List<String> signedHeaders) {
  final hashedPayload = request.headers['x-amz-content-sha256'];
  final requestResource = request.url.path;
  final headers = signedHeaders.map(
    (header) => '${header.toLowerCase()}:${request.headers[header]}',
  );

  final queryKeys = request.url.queryParameters.keys.toList();
  queryKeys.sort();
  final requestQuery = queryKeys.map((key) {
    final value = request.url.queryParameters[key];
    final hasValue = value != null;
    final valuePart = hasValue ? Uri.encodeQueryComponent(value) : '';
    return Uri.encodeQueryComponent(key) + '=' + valuePart;
  }).join('&');

  final canonical = [];
  canonical.add(request.method.toUpperCase());
  canonical.add(requestResource);
  canonical.add(requestQuery);
  canonical.add(headers.join('\n') + '\n');
  canonical.add(signedHeaders.join(';').toLowerCase());
  canonical.add(hashedPayload);
  return canonical.join('\n');
}

String getStringToSign(
  String canonicalRequest,
  DateTime requestDate,
  String region,
) {
  final hash = sha256Hex(canonicalRequest);
  final scope = getScope(region, requestDate);
  final stringToSign = [];
  stringToSign.add(signV4Algorithm);
  stringToSign.add(makeDateLong(requestDate));
  stringToSign.add(scope);
  stringToSign.add(hash);
  return stringToSign.join('\n');
}

String getScope(String region, DateTime date) {
  return '${makeDateShort(date)}/${region}/s3/aws4_request';
}

List<int> getSigningKey(DateTime date, String region, String secretKey) {
  final dateLine = makeDateShort(date);
  final key1 = ('AWS4' + secretKey).codeUnits;
  final hmac1 = Hmac(sha256, key1).convert(dateLine.codeUnits).bytes;
  final hmac2 = Hmac(sha256, hmac1).convert(region.codeUnits).bytes;
  final hmac3 = Hmac(sha256, hmac2).convert('s3'.codeUnits).bytes;
  return Hmac(sha256, hmac3).convert('aws4_request'.codeUnits).bytes;
}

String getCredential(String accessKey, String region, DateTime requestDate) {
  return '$accessKey/${getScope(region, requestDate)}';
}
