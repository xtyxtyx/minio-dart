import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:minio/minio.dart';
import 'package:test/test.dart';

/// Size of the object used by the transfer tests.
const _size = 4 * 1024 * 1024;

/// Number of bytes moved per chunk.
const _chunkSize = 64 * 1024;

/// A local S3 endpoint that moves the response/request body slowly, so a
/// transfer stays in flight long enough to be aborted.
class _SlowS3Server {
  _SlowS3Server(this._server) {
    _server.listen(_handle);
  }

  final HttpServer _server;
  int receivedBytes = 0;

  int get port => _server.port;

  Future<void> _handle(HttpRequest request) async {
    try {
      switch (request.method) {
        case 'PUT':
          await for (final chunk in request) {
            receivedBytes += chunk.length;
            await Future<void>.delayed(const Duration(milliseconds: 50));
          }
          request.response
            ..statusCode = HttpStatus.ok
            ..headers.set('etag', '"fake-etag"');
          await request.response.close();
        case 'GET':
          final response = request.response;
          response.contentLength = _size;
          final chunk = Uint8List(_chunkSize);
          var sent = 0;
          while (sent < _size) {
            final length = _size - sent < _chunkSize ? _size - sent : _chunkSize;
            response.add(
              length == _chunkSize
                  ? chunk
                  : Uint8List.sublistView(chunk, 0, length),
            );
            await response.flush();
            sent += length;
            await Future<void>.delayed(const Duration(milliseconds: 50));
          }
          await response.close();
        default:
          request.response.statusCode = HttpStatus.ok;
          await request.response.close();
      }
    } catch (_) {
      // The client may close the connection while the body is being moved.
    }
  }

  Future<void> close() => _server.close(force: true);
}

Minio _createMinio(_SlowS3Server server) {
  return Minio(
    endPoint: '127.0.0.1',
    port: server.port,
    useSSL: false,
    accessKey: 'key',
    secretKey: 'secret',
    // A configured region skips the bucket location lookup.
    region: 'us-east-1',
  );
}

Stream<Uint8List> _payloadStream() async* {
  final payload = Uint8List(_size)..fillRange(0, _size, 7);
  for (var offset = 0; offset < payload.length; offset += _chunkSize) {
    final end = offset + _chunkSize < payload.length
        ? offset + _chunkSize
        : payload.length;
    yield Uint8List.sublistView(payload, offset, end);
  }
}

/// Waits for [future] and returns either its error or null when it succeeds.
Future<Object?> _captureError<T>(Future<T> future) {
  return future.then<Object?>((_) => null, onError: (Object error) => error);
}

void main() {
  late _SlowS3Server server;

  setUp(() async {
    server = _SlowS3Server(
      await HttpServer.bind(InternetAddress.loopbackIPv4, 0),
    );
  });

  tearDown(() => server.close());

  test('putObject aborts the upload when abortTrigger completes', () async {
    final minio = _createMinio(server);
    final abortTrigger = Completer<void>();
    final upload = minio.putObject(
      'bucket',
      'big.bin',
      _payloadStream(),
      size: _size,
      abortTrigger: abortTrigger.future,
    );

    await Future<void>.delayed(const Duration(milliseconds: 200));
    final abortedAt = DateTime.now();
    abortTrigger.complete();
    final error = await _captureError(upload);
    final elapsedMs = DateTime.now().difference(abortedAt).inMilliseconds;

    expect(error, isA<http.RequestAbortedException>());
    expect(elapsedMs, lessThan(1500));
    expect(server.receivedBytes, lessThan(_size));
  }, timeout: const Timeout(Duration(seconds: 30)));

  test('putObject uploads the whole object when abortTrigger does not complete',
      () async {
    final minio = _createMinio(server);
    final abortTrigger = Completer<void>();

    await minio.putObject(
      'bucket',
      'big.bin',
      _payloadStream(),
      size: _size,
      abortTrigger: abortTrigger.future,
    );

    expect(server.receivedBytes, _size);
  }, timeout: const Timeout(Duration(seconds: 60)));

  test('getObject aborts the download when abortTrigger completes', () async {
    final minio = _createMinio(server);
    final abortTrigger = Completer<void>();
    final stream = await minio.getObject(
      'bucket',
      'big.bin',
      abortTrigger: abortTrigger.future,
    );

    final errors = <Object>[];
    final done = Completer<void>();
    stream.listen(
      (_) {},
      onError: (Object error) => errors.add(error),
      onDone: () {
        if (!done.isCompleted) {
          done.complete();
        }
      },
    );
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final abortedAt = DateTime.now();
    abortTrigger.complete();
    await done.future;
    final elapsedMs = DateTime.now().difference(abortedAt).inMilliseconds;

    expect(errors.single, isA<http.RequestAbortedException>());
    expect(elapsedMs, lessThan(1500));
  }, timeout: const Timeout(Duration(seconds: 30)));

  test('getObject reads the whole object when abortTrigger does not complete',
      () async {
    final minio = _createMinio(server);
    final abortTrigger = Completer<void>();
    final stream = await minio.getObject(
      'bucket',
      'big.bin',
      abortTrigger: abortTrigger.future,
    );

    var received = 0;
    await for (final chunk in stream) {
      received += chunk.length;
    }

    expect(received, _size);
  }, timeout: const Timeout(Duration(seconds: 60)));
}
