import 'dart:convert';

int intFromDynamic(dynamic value, {int defaultValue = 0}) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value) ?? defaultValue;
  }
  return defaultValue;
}

double doubleFromDynamic(dynamic value, {double defaultValue = 0}) {
  if (value is double) {
    return value;
  }
  if (value is num) {
    return value.toDouble();
  }
  if (value is String) {
    return double.tryParse(value) ?? defaultValue;
  }
  return defaultValue;
}

bool boolFromDynamic(dynamic value, {bool defaultValue = false}) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    switch (value.toLowerCase()) {
      case 'true':
      case '1':
      case 'yes':
        return true;
      case 'false':
      case '0':
      case 'no':
        return false;
      default:
        return defaultValue;
    }
  }
  return defaultValue;
}

String? nullableStringFromDynamic(dynamic value) {
  if (value == null) {
    return null;
  }
  final stringValue = value.toString().trim();
  if (stringValue.isEmpty || stringValue.toLowerCase() == 'null') {
    return null;
  }
  return stringValue;
}

Map<String, dynamic> mapFromDynamic(dynamic value) {
  if (value is Map<String, dynamic>) {
    return Map<String, dynamic>.from(value);
  }
  if (value is Map) {
    return value.map((key, dynamic item) => MapEntry(key.toString(), item));
  }
  if (value is String && value.trim().isNotEmpty) {
    try {
      final decoded = jsonDecode(value);
      if (decoded is Map<String, dynamic>) {
        return Map<String, dynamic>.from(decoded);
      }
      if (decoded is Map) {
        return decoded.map(
          (key, dynamic item) => MapEntry(key.toString(), item),
        );
      }
    } catch (_) {
      return <String, dynamic>{};
    }
  }
  return <String, dynamic>{};
}

List<Map<String, dynamic>> mapListFromDynamic(dynamic value, {String? key}) {
  final dynamic source = key != null && value is Map ? value[key] : value;
  if (source is! List) {
    return const <Map<String, dynamic>>[];
  }
  return source.map<Map<String, dynamic>>((dynamic item) {
    return mapFromDynamic(item);
  }).toList();
}

DateTime? dateTimeFromDynamic(dynamic value) {
  final stringValue = nullableStringFromDynamic(value);
  if (stringValue == null) {
    return null;
  }
  return DateTime.tryParse(stringValue);
}

String firstStringFromKeys(
  Map<String, dynamic> json,
  List<String> keys, {
  String defaultValue = '',
}) {
  for (final key in keys) {
    final value = nullableStringFromDynamic(json[key]);
    if (value != null) {
      return value;
    }
  }
  return defaultValue;
}
