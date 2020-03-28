import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:buffer/buffer.dart';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:xml/xml.dart';

String sha256Hex(Object data) {
  if (data is String) {
    data = utf8.encode(data);
  } else if (data is List<int>) {
    data = data;
  } else {
    throw ArgumentError('unsupported data type: ${data.runtimeType}');
  }

  return hex.encode(sha256.convert(data).bytes);
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

String encodeQueries(Map<String, String> queries) {
  final pairs = <String>[];
  for (var key in queries.keys) {
    final value = queries[key];
    pairs.add(encodeQuery(key, value));
  }
  return pairs.join('=');
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

    if (buffer.length != 0) {
      yield buffer.toBytes();
    }
  }
}

String trimDoubleQuote(String str) {
  return str.replaceAll(RegExp('^"'), '').replaceAll(RegExp(r'"$'), '');
}