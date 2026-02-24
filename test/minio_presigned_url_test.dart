import 'package:minio/minio.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  test('Minio.presignedGetObject() works', () async {
    final minio = getMinioClient();
    await minio.presignedGetObject('bucket', 'object');
  });

  test('Minio.presignedGetObject() throws when [expires] < 0', () async {
    final minio = getMinioClient();
    expect(
      () => minio.presignedGetObject('bucket', 'object', expires: -1),
      throwsA(isA<MinioError>()),
    );
  });

  test('Minio.presignedGetObject() uses overrideHost in URL', () async {
    final minio = getMinioClient();
    final url = await minio.presignedGetObject(
      'bucket',
      'object',
      overrideHost: 'public.example.com',
    );
    expect(Uri.parse(url).host, equals('public.example.com'));
  });

  test('Minio.presignedGetObject() uses overrideScheme in URL', () async {
    final minio = getMinioClient(useSSL: false, port: 80);
    final url = await minio.presignedGetObject(
      'bucket',
      'object',
      overrideScheme: 'https',
    );
    expect(Uri.parse(url).scheme, equals('https'));
  });

  test('Minio.presignedGetObject() uses overridePort in URL', () async {
    final minio = getMinioClient();
    final url = await minio.presignedGetObject(
      'bucket',
      'object',
      overridePort: 9000,
    );
    expect(Uri.parse(url).port, equals(9000));
  });

  test('Minio.presignedGetObject() applies all overrides together', () async {
    final minio = getMinioClient();
    final url = await minio.presignedGetObject(
      'bucket',
      'object',
      overrideHost: 'public.example.com',
      overridePort: 9000,
      overrideScheme: 'http',
    );
    final uri = Uri.parse(url);
    expect(uri.host, equals('public.example.com'));
    expect(uri.port, equals(9000));
    expect(uri.scheme, equals('http'));
  });

  test('Minio.presignedPutObject() works', () async {
    final minio = getMinioClient();
    await minio.presignedPutObject('bucket', 'object');
  });

  test('Minio.presignedPutObject() throws when [expires] < 0', () async {
    final minio = getMinioClient();
    expect(
      () => minio.presignedPutObject('bucket', 'object', expires: -1),
      throwsA(isA<MinioError>()),
    );
  });

  test('Minio.presignedPutObject() uses overrideHost in URL', () async {
    final minio = getMinioClient();
    final url = await minio.presignedPutObject(
      'bucket',
      'object',
      overrideHost: 'public.example.com',
    );
    expect(Uri.parse(url).host, equals('public.example.com'));
  });

  test('Minio.presignedPutObject() applies all overrides together', () async {
    final minio = getMinioClient();
    final url = await minio.presignedPutObject(
      'bucket',
      'object',
      overrideHost: 'public.example.com',
      overridePort: 9000,
      overrideScheme: 'http',
    );
    final uri = Uri.parse(url);
    expect(uri.host, equals('public.example.com'));
    expect(uri.port, equals(9000));
    expect(uri.scheme, equals('http'));
  });
}
