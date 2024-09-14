import 'dart:io';

import 'package:html/dom.dart' show Element;
import 'package:html/parser.dart' show parse;
import 'package:http/http.dart' as http;

void main() async {
  final urls = await getAllModelUrls();
  // print(await getModel(urls.first));
  final models = await Future.wait(urls.map(getModel));

  final result = '''
// ignore_for_file: require_trailing_commas
// ignore_for_file: deprecated_member_use
// ignore_for_file: empty_constructor_bodies

import 'package:xml/xml.dart';

XmlElement? getProp(XmlElement? xml, String name) {
  if (xml == null) return null;
  final result = xml.findElements(name);
  return result.isNotEmpty ? result.first : null;
}

T? getPropValueOrNull<T>(XmlElement? xml, String name) {
  final propValue = getProp(xml, name)?.value;
  if (propValue == null) return null;

  switch (T) {
    case const (String):
      return propValue as T?;
    case const (int):
      return int.tryParse(propValue) as T?;
    case const (bool):
      return (propValue.toUpperCase() == 'TRUE') as T?;
    case const (DateTime):
      return DateTime.parse(propValue) as T;
    default:
      return propValue as T;
  }
}

T getPropValue<T>(XmlElement? xml, String name) {
  final propValue = getPropValueOrNull<T>(xml, name);
  return propValue as T;
}

${models.join('\n')}
  ''';

  final file = File('lib/src/minio_models_generated.dart');
  await file.writeAsString(result);
  Process.runSync('dart', ['format', file.path]);
}

const baseUrl = 'https://docs.aws.amazon.com/AmazonS3/latest/API';

Future<List<String>> getAllModelUrls() async {
  print('Getting Index.');
  const url = '$baseUrl/API_Types_Amazon_Simple_Storage_Service.html';
  final page = await http.get(Uri.parse(url));
  final document = parse(page.body);
  final urls = document.querySelectorAll('.listitem a');
  return urls
      .map<String>((a) => a.attributes['href']!.substring(2))
      .map((a) => '$baseUrl/$a')
      .toList();
}

Future<String> getModel(String url) async {
  print('Getting: $url.');
  final page = await http.get(Uri.parse(url));
  final document = parse(page.body);

  final name = document.querySelector('h1')!.text;
  final description = document
      .querySelector('#main-col-body p')!
      .text
      .replaceAll(RegExp(r'\s+'), ' ');

  final fields = <FieldSpec>[];
  for (var dt in document.querySelectorAll('dt')) {
    final name = dt.text.trim();
    final spec = parseField(name, dt.nextElementSibling!);
    fields.add(spec);
  }

  final buffer = StringBuffer();
  buffer.writeln('/// $description');
  buffer.writeln('class $name {');

  buffer.writeln('  $name(');
  for (var field in fields) {
    buffer.writeln('    this.${field.dartName},');
  }
  buffer.writeln('  );');
  buffer.writeln('');

  buffer.writeln('  $name.fromXml(XmlElement? xml) {');
  for (var field in fields) {
    switch (field.type.name) {
      case 'String':
      case 'int':
      case 'bool':
      case 'DateTime':
        String methodName =
            field.isRequired ? 'getPropValue' : 'getPropValueOrNull';
        buffer.writeln(
          "    ${field.dartName} = $methodName<${field.type.dartName ?? field.type.name}>(xml, '${field.name}');",
        );
        break;
      default:
        if (field.type.isArray) {
          buffer.writeln(
            "    ${field.dartName} = getProp(xml, '${field.name}')${field.isRequired ? '!' : '?'}.children.map((c) => ${field.type.name}.fromXml(c as XmlElement)).toList();",
          );
        } else {
          buffer.writeln(
            "    ${field.dartName} = ${field.type.name}.fromXml(getProp(xml, '${field.name}'));",
          );
        }
    }
  }
  buffer.writeln('  }');
  buffer.writeln('');

  buffer.writeln('  XmlNode toXml() {');
  buffer.writeln('    final builder = XmlBuilder();');
  buffer.writeln("    builder.element('$name', nest: () {");
  for (var field in fields) {
    switch (field.type.name) {
      case 'String':
        buffer.writeln(
          "      builder.element('${field.name}', nest: ${field.dartName});",
        );
        break;
      case 'int':
        buffer.writeln(
          "      builder.element('${field.name}', nest: ${field.dartName}.toString());",
        );
        break;
      case 'bool':
        buffer.writeln(
          "      builder.element('${field.name}', nest: ${field.dartName} == true ? 'TRUE' : 'FALSE');",
        );

        break;
      case 'DateTime':
        buffer.writeln(
          "      builder.element('${field.name}', nest: ${field.dartName}${field.nullable}.toIso8601String());",
        );
        break;
      default:
        if (field.type.isArray) {
          buffer.writeln(
            "      builder.element('${field.name}', nest: ${field.dartName}${field.nullable}.map((e) => e.toXml()));",
          );
        } else {
          buffer.writeln(
            "      builder.element('${field.name}', nest: ${field.dartName}${field.nullable}.toXml());",
          );
        }
    }
  }
  buffer.writeln('    });');
  buffer.writeln('    return builder.buildDocument();');
  buffer.writeln('  }');
  buffer.writeln('');

  for (var field in fields) {
    buffer.writeln('  /// ${field.description}');
    buffer.writeln(
      '  ${field.isRequired ? 'late ' : ''}${field.type.dartName ?? field.type.name}${field.nullable} ${field.dartName};',
    );
    // buffer.writeln(
    //   [
    //     '  ',
    //     if (field.isRequired) 'late ',
    //     (field.type.name),
    //     if (!field.isRequired) '?',
    //     ' ${field.dartName};',
    //   ].join(''),
    // );
    buffer.writeln('');
  }
  buffer.writeln('}');

  return buffer.toString();
}

class FieldSpec {
  FieldSpec({
    required this.name,
    required this.dartName,
    this.source,
    this.description,
    this.isRequired = false,
    required this.type,
  });

  final String name;
  final String dartName;
  final String? source;
  final String? description;
  final bool isRequired;
  final TypeSpec type;

  String get nullable => isRequired ? '' : '?';

  @override
  String toString() {
    return '<Field $name>';
  }
}

class TypeSpec {
  TypeSpec({
    required this.name,
    this.dartName,
    this.isObject = false,
    this.isArray = false,
  });

  final String name;
  final String? dartName;
  final bool isObject;
  final bool isArray;

  @override
  String toString() {
    return '<TypeSpec $name>';
  }
}

String toCamelCase(String name) {
  return name.substring(0, 1).toLowerCase() + name.substring(1);
}

FieldSpec parseField(String name, Element dd) {
  final source = dd.text;
  final description =
      dd.querySelector('p')!.text.replaceAll(RegExp(r'\s+'), ' ');
  final isRequired = dd.text.contains('Required: Yes');
  final type = parseType(source);

  return FieldSpec(
    name: name,
    dartName: toCamelCase(name),
    source: source,
    description: description,
    isRequired: isRequired,
    type: type,
  );
}

TypeSpec parseType(String source) {
  if (source.contains('Type: Base64-encoded binary data object')) {
    return TypeSpec(name: 'String');
  }

  const typeMap = {
    'Integer': 'int',
    'Long': 'int',
    'String': 'String',
    'strings': 'String',
    'Timestamp': 'DateTime',
    'Boolean': 'bool',
  };
  final pattern = RegExp(r'Type: (Array of |)(\w+)( data type|)');
  final match = pattern.firstMatch(source)!;

  final isArray = match.group(1)!.trim().isNotEmpty;
  final isObject = match.group(3)!.trim().isNotEmpty;
  final type = match.group(2);

  final dartType = isObject ? type : typeMap[type!];
  final dartName = isArray ? 'List<$dartType>' : dartType;

  return TypeSpec(
    name: dartType!,
    dartName: dartName,
    isObject: isObject,
    isArray: isArray,
  );
}
