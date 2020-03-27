import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';
import 'package:xml/xml.dart';

String sha256Hex(String data) {
  return hex.encode(sha256.convert(utf8.encode(data)).bytes);
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
