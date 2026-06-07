import 'package:minio/src/minio_helpers.dart';
import 'package:test/test.dart';

void main() {
  group('helpers', () {
    test('should validate for s3 endpoint', () {
      expect(isValidEndpoint('s3.amazonaws.com'), isTrue);
    });
    test('should validate for s3 china', () {
      expect(isValidEndpoint('s3.cn-north-1.amazonaws.com.cn'), isTrue);
    });
    test('should validate for us-west-2', () {
      expect(isValidEndpoint('s3-us-west-2.amazonaws.com'), isTrue);
    });
    test('should fail for invalid endpoint characters', () {
      expect(isValidEndpoint('111.#2.11'), isFalse);
    });
    test('should validate for valid ip', () {
      expect(isValidIPv4('1.1.1.1'), isTrue);
    });
    test('should fail for invalid ip', () {
      expect(isValidIPv4('1.1.1'), isFalse);
    });
    test('should make date short', () {
      final date = DateTime.parse('2012-12-03T17:25:36.331Z');
      expect(makeDateShort(date), '20121203');
    });
    test('should make date long', () {
      final date = DateTime.parse('2017-08-11T17:26:34.935Z');
      expect(makeDateLong(date), '20170811T172634Z');
    });
  });

  group('encodePath', () {
    // The signed canonical URI must match what S3/MinIO compute from the wire
    // URL: a space is %20, a literal '+' is %2B (not %20). The leading empty
    // segment mirrors how MinioClient builds the path ("/bucket/obj".split('/')).
    test('encodes a space as %20', () {
      expect(encodePath(Uri(pathSegments: ['', 'b', 'a b.txt'])), '/b/a%20b.txt');
    });
    test('encodes a literal plus as %2B', () {
      expect(encodePath(Uri(pathSegments: ['', 'b', 'a+b.txt'])), '/b/a%2Bb.txt');
      expect(
        encodePath(Uri(pathSegments: ['', 'b', 'C++ notes.txt'])),
        '/b/C%2B%2B%20notes.txt',
      );
    });
    test('keeps the slash separator between segments', () {
      expect(
        encodePath(Uri(pathSegments: ['', 'b', 'dir', 'sub', 'x.txt'])),
        '/b/dir/sub/x.txt',
      );
    });
  });

  group('encodeCopySource', () {
    test('keeps unreserved chars and the slash', () {
      expect(encodeCopySource('bucket/a-_.~b.txt'), 'bucket/a-_.~b.txt');
    });
    test('percent-encodes space and plus', () {
      expect(encodeCopySource('bucket/a b+c.txt'), 'bucket/a%20b%2Bc.txt');
    });
    test('double-encodes a literal percent so it survives the round trip', () {
      // A key literally named "a%2Bb" must not be decoded back to "a+b".
      expect(encodeCopySource('bucket/a%2Bb.txt'), 'bucket/a%252Bb.txt');
    });
  });
}
