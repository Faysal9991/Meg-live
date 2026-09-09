import 'dart:convert';

/// Room routes may wrap a preference, while profiles/socket events pass it
/// directly (or as JSON). Missing membership is a normal, empty preference.
Map<String, dynamic> normalizeVipPreference(dynamic value) {
  if (value is String) {
    try {
      value = jsonDecode(value);
    } on FormatException {
      return const {};
    }
  }
  if (value is! Map) return const {};
  if (value.containsKey('vvip_or_vip_preference')) {
    return normalizeVipPreference(value['vvip_or_vip_preference']);
  }
  return Map<String, dynamic>.from(value);
}
