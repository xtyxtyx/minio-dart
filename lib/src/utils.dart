import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

String sha256Hex(dynamic data) {
  List<int> cData;
  if (data is String) {
    cData = utf8.encode(data);
  } else if (data is List<int>) {
    cData = data;
  } else {
    throw ArgumentError('unsupported data type: ${data.runtimeType}');
  }

  return hex.encode(sha256.convert(cData).bytes);
}

String sha256HmacHex(String data, List<int> signingKey) => hex
    .encode(Hmac(sha256, signingKey).convert(utf8.encode(data)).bytes)
    .toLowerCase();

String md5Base64(String source) {
  final md5digest = md5.convert(utf8.encode(source)).bytes;
  return base64.encode(md5digest);
}

String jsonBase64(Map<String, dynamic> jsonObject) {
  return base64.encode(utf8.encode(json.encode(jsonObject)));
}

XmlElement? getNodeProp(XmlElement xml, String name) {
  final result = xml.findElements(name);
  return result.isNotEmpty ? result.first : null;
}

String encodeQuery(String rawKey, String? rawValue) {
  final pair = [rawKey];
  if (rawValue != null) {
    pair.add(Uri.encodeQueryComponent(rawValue));
  }
  return pair.join('=');
}

String encodeQueries(Map<String, dynamic> queries) {
  final pairs = <String>[];
  for (final key in queries.keys) {
    final value = queries[key];
    if (value is String || value == null) {
      pairs.add(encodeQuery(key, value as String?));
    } else if (value is Iterable<String>) {
      for (final val in value) {
        pairs.add(encodeQuery(key, val));
      }
    } else {
      throw ArgumentError('unsupported value: $value');
    }
  }
  return pairs.join('&');
}

class MaxChunkSize extends StreamTransformerBase<Uint8List, Uint8List> {
  MaxChunkSize(this.size);

  final int size;

  @override
  Stream<Uint8List> bind(Stream<Uint8List> stream) async* {
    await for (final chunk in stream) {
      if (chunk.length < size) {
        yield chunk;
        continue;
      }

      final blocks = chunk.length ~/ size;

      for (var i = 0; i < blocks; i++) {
        yield Uint8List.sublistView(chunk, i * size, (i + 1) * size);
      }

      if (blocks * size < chunk.length) {
        yield Uint8List.sublistView(chunk, blocks * size);
      }
    }
  }
}

class MinChunkSize extends StreamTransformerBase<Uint8List, Uint8List> {
  MinChunkSize(this.size);

  final int size;

  var _yielded = false;

  @override
  Stream<Uint8List> bind(Stream<Uint8List> stream) async* {
    final buffer = BytesBuilder(copy: false);

    await for (final chunk in stream) {
      buffer.add(chunk);

      if (buffer.length < size) {
        continue;
      }

      yield buffer.takeBytes();
      _yielded = true;
    }

    if (buffer.isNotEmpty || !_yielded) {
      yield buffer.takeBytes();
    }
  }
}

String trimDoubleQuote(String str) {
  return str.replaceAll(RegExp('^"'), '').replaceAll(RegExp(r'"$'), '');
}

DateTime parseRfc7231Time(String time) {
  final format = DateFormat('EEE, dd MMM yyyy HH:mm:ss');
  final isUtc = time.endsWith('GMT');
  return format.parse(time, isUtc);
}

String toRfc7231Time(DateTime time) {
  final format = DateFormat('EEE, dd MMM yyyy HH:mm:ss');
  final result = format.format(time);
  return time.isUtc ? '$result GMT' : result;
}

List<List<T>> groupList<T>(List<T> list, int maxMembers) {
  final groups = (list.length / maxMembers).ceil();
  final result = <List<T>>[];
  for (var i = 0; i < groups; i++) {
    final start = i * maxMembers;
    final end = math.min(start + maxMembers, list.length);
    result.add(list.sublist(start, end));
  }
  return result;
}
