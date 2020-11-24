import 'package:minio/minio.dart';
import 'package:test/test.dart';

void main() {
  group('listBuckets', () {
    test('listBuckets() succeeds', () async {
      final minio = _getClient();

      expect(() async => await minio.listBuckets(), returnsNormally);
    });

    test('listBuckets() fails due to wrong access key', () async {
      final minio = _getClient(accessKey: 'incorrect-access-key');

      expect(
        () async => await minio.listBuckets(),
        throwsA(
          isA<MinioError>().having(
            (e) => e.message,
            'message',
            'The Access Key Id you provided does not exist in our records.',
          ),
        ),
      );
    });

    test('listBuckets() fails due to wrong secret key', () async {
      final minio = _getClient(secretKey: 'incorrect-secret-key');

      expect(
        () async => await minio.listBuckets(),
        throwsA(
          isA<MinioError>().having(
            (e) => e.message,
            'message',
            'The request signature we calculated does not match the signature you provided. Check your key and signing method.',
          ),
        ),
      );
    });
  });
}

/// Initializes an instance of [Minio] with per default valid configuration.
///
/// Don't worry, these credentials for MinIO are publicly available and
/// connect only to the MinIO demo server at `play.minio.io`.
Minio _getClient({
  String endpoint = 'play.minio.io',
  int port = 443,
  bool useSSL = true,
  String accessKey = 'Q3AM3UQ867SPQQA43P2F',
  String secretKey = 'zuf+tfteSlswRu7BJ86wekitnifILbZam1KYY3TG',
  String sessionToken = '',
  String region = 'us-east-1',
  bool enableTrace = false,
}) =>
    Minio(
      endPoint: endpoint,
      port: port,
      useSSL: useSSL,
      accessKey: accessKey,
      secretKey: secretKey,
      sessionToken: sessionToken,
      region: region,
      enableTrace: enableTrace,
    );
