import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

bool isValidBucketName(String bucket) {
  if (bucket == null) return false;

  if (bucket.length < 3 || bucket.length > 63) {
    return false;
  }
  if (bucket.contains('..')) {
    return false;
  }

  if (RegExp(r'[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+').hasMatch(bucket)) {
    return false;
  }

  if (RegExp(r'^[a-z0-9][a-z0-9.-]+[a-z0-9]$').hasMatch(bucket)) {
    return true;
  }

  return false;
}

bool isAmazonEndpoint(String endpoint) {
  return endpoint == 's3.amazonaws.com' ||
      endpoint == 's3.cn-north-1.amazonaws.com.cn';
}

bool isVirtualHostStyle(String endpoint, bool useSSL, String bucket) {
  if (bucket == null) {
    return false;
  }

  if (useSSL && bucket.contains('.')) {
    return false;
  }

  return isAmazonEndpoint(endpoint);
}

bool isValidEndpoint(endpoint) {
  return isValidDomain(endpoint) || isValidIPv4(endpoint);
}

bool isValidIPv4(String ip) {
  if (ip == null) return false;
  return RegExp(r'^(\d{1,3}\.){3,3}\d{1,3}$').hasMatch(ip);
}

bool isValidDomain(String host) {
  if (host == null) return false;

  if (host.isEmpty || host.length > 255) {
    return false;
  }

  if (host.startsWith('-') || host.endsWith('-')) {
    return false;
  }

  if (host.startsWith('_') || host.endsWith('_')) {
    return false;
  }

  if (host.startsWith('.') || host.endsWith('.')) {
    return false;
  }

  final alphaNumerics = '`~!@#\$%^&*()+={}[]|\\"\';:><?/'.split('');
  for (var char in alphaNumerics) {
    if (host.contains(char)) return false;
  }

  return true;
}

bool isValidPort(int port) {
  if (port == null) return false;
  if (port < 0) return false;
  if (port == 0) return true;
  const minPort = 1;
  const maxPort = 65535;
  return port >= minPort && port <= maxPort;
}

int implyPort(bool ssl) {
  return ssl ? 443 : 80;
}

String makeDateLong(DateTime date) {
  final isoDate = date.toIso8601String();

  // 'YYYYMMDDTHHmmss' + Z
  return isoDate.substring(0, 4) +
      isoDate.substring(5, 7) +
      isoDate.substring(8, 13) +
      isoDate.substring(14, 16) +
      isoDate.substring(17, 19) +
      'Z';
}

String makeDateShort(DateTime date) {
  final isoDate = date.toIso8601String();

  // 'YYYYMMDD'
  return isoDate.substring(0, 4) +
      isoDate.substring(5, 7) +
      isoDate.substring(8, 10);
}

String sha256Hex(String data) {
  return hex.encode(sha256.convert(utf8.encode(data)).bytes);
}
