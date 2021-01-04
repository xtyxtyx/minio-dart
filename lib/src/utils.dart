import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:buffer/buffer.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:intl/intl.dart';
import 'package:xml/xml.dart';

String sha256Hex(dynamic data) {
  if (data is String) {
    data = utf8.encode(data);
  } else if (data is List<int>) {
    data = data;
  } else {
    throw ArgumentError('unsupported data type: ${data.runtimeType}');
  }

  return hex.encode(sha256.convert(data).bytes);
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

XmlElement getNodeProp(XmlElement xml, String name) {
  final result = xml.findElements(name);
  return result.isNotEmpty ? result.first : null;
}

String encodeQuery(String rawKey, String rawValue) {
  final pair = [rawKey];
  if (rawValue != null) {
    pair.add(Uri.encodeQueryComponent(rawValue));
  }
  return pair.join('=');
}

String encodeQueries(Map<String, dynamic> queries) {
  final pairs = <String>[];
  for (var key in queries.keys) {
    final value = queries[key];
    if (value is String || value == null) {
      pairs.add(encodeQuery(key, value));
    } else if (value is Iterable<String>) {
      for (var val in value) {
        pairs.add(encodeQuery(key, val));
      }
    } else {
      throw ArgumentError('unsupported value: $value');
    }
  }
  return pairs.join('&');
}

class BlockStream extends StreamTransformerBase<List<int>, List<int>> {
  BlockStream(this.size);

  final int size;

  @override
  Stream<List<int>> bind(Stream<List<int>> stream) async* {
    var buffer = BytesBuffer();

    await for (var chunk in stream) {
      buffer.add(chunk);
      if (buffer.length >= size) {
        final block = buffer.toBytes();
        yield block.sublist(0, size);
        buffer = BytesBuffer();
        buffer.add(block.sublist(size));
      }
    }

    yield buffer.toBytes();
  }
}

String trimDoubleQuote(String str) {
  return str.replaceAll(RegExp('^"'), '').replaceAll(RegExp(r'"$'), '');
}

DateTime parseRfc7231Time(String time) {
  final format = DateFormat('EEE, dd MMM yyyy hh:mm:ss zzz');
  return format.parse(time);
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
