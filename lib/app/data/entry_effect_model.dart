import 'dart:convert';

class EntryEffect {
  const EntryEffect({
    this.id,
    this.title,
    this.svgaUrl,
    this.gifUrl,
    this.audioUrl,
    this.expiredDatetime,
  });

  final int? id;
  final String? title;
  final String? svgaUrl;
  final String? gifUrl;
  final String? audioUrl;
  final DateTime? expiredDatetime;

  bool get isActive =>
      expiredDatetime == null ||
      expiredDatetime!.toUtc().isAfter(DateTime.now().toUtc());

  static EntryEffect? fromDynamic(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      try {
        return fromDynamic(jsonDecode(value));
      } catch (_) {
        return null;
      }
    }
    if (value is! Map) {
      return null;
    }

    final data = value.map(
      (dynamic key, dynamic item) => MapEntry(key.toString(), item),
    );
    if (data.isEmpty) {
      return null;
    }

    return EntryEffect(
      id: int.tryParse(data['id']?.toString() ?? ''),
      title: _nullableText(data['title']),
      svgaUrl: normalizeMediaUrl(data['svga']),
      gifUrl: normalizeMediaUrl(data['gif']),
      audioUrl: normalizeMediaUrl(data['audio']),
      expiredDatetime: DateTime.tryParse(
        data['expired_datetime']?.toString() ?? '',
      ),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'id': id,
    'title': title,
    'svga': svgaUrl,
    'gif': gifUrl,
    'audio': audioUrl,
    'expired_datetime': expiredDatetime?.toIso8601String(),
  };

  static String? _nullableText(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty || text.toLowerCase() == 'null' ? null : text;
  }

  /// Accepts both a plain media URL and accidentally markdown-wrapped URLs.
  static String? normalizeMediaUrl(dynamic value) {
    var text = _nullableText(value);
    if (text == null) {
      return null;
    }

    final markdownMatch = RegExp(r'^\[[^\]]*\]\(([^)]+)\)$').firstMatch(text);
    if (markdownMatch != null) {
      text = markdownMatch.group(1)?.trim();
    }
    text = text?.replaceAll(r'\', '');

    final uri = Uri.tryParse(text ?? '');
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return null;
    }
    return text;
  }
}
