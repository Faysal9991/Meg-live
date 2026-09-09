import 'package:doyel_live/app/widgets/animated_media_widget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnimatedMediaSource', () {
    test('uses the actual URL extension when gif contains MP4', () {
      final source = AnimatedMediaSource.fromUrls(
        gif: 'https://example.com/effects/car.mp4?version=2',
      );

      expect(source.type, AnimatedMediaType.video);
      expect(source.url, contains('car.mp4'));
    });

    test('prefers an explicit SVGA source', () {
      final source = AnimatedMediaSource.fromUrls(
        svga: 'https://example.com/effects/entry.svga',
        gif: 'https://example.com/effects/fallback.gif',
      );

      expect(source.type, AnimatedMediaType.svga);
      expect(source.url, endsWith('.svga'));
    });

    test('accepts a markdown-wrapped image URL', () {
      final source = AnimatedMediaSource.fromUrls(
        gif: '[preview](https://example.com/effects/gift.gif)',
      );

      expect(source.type, AnimatedMediaType.image);
      expect(source.url, 'https://example.com/effects/gift.gif');
    });

    test('falls back when an earlier API field is not playable', () {
      final source = AnimatedMediaSource.fromUrls(
        svga: 'https://example.com/effects/no-extension',
        gif: 'https://example.com/effects/fallback.gif',
      );

      expect(source.type, AnimatedMediaType.image);
      expect(source.url, endsWith('.gif'));
    });
  });
}
