import 'dart:async';
import 'dart:io';

import 'package:doyel_live/app/widgets/animated_media_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svga/flutter_svga.dart';
import 'package:flutter_test/flutter_test.dart';

MovieEntity _movie(String name) =>
    MovieEntity(
        params: MovieParams(
          viewBoxWidth: 46,
          viewBoxHeight: 46,
          frames: 20,
          fps: 20,
        ),
      )
      ..mergeFromProto3Json({
        'audios': [
          {'audioKey': name, 'startFrame': 0, 'endFrame': 19},
        ],
      })
      ..audiosData[name] = Uint8List.fromList([73, 68, 51]);

class _Parser extends SVGAParser {
  final decoded = <MovieEntity>[];
  Completer<MovieEntity>? pending;

  @override
  Future<MovieEntity> decodeFromURL(String url) async {
    final movie = pending == null
        ? _movie(Uri.parse(url).pathSegments.last)
        : await pending!.future;
    decoded.add(movie);
    return movie;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final calls = <MethodCall>[];
  final playing = <String>{};
  final eventChannels = <String>{};
  late Directory cache;
  int peakPlaying = 0;

  setUp(() {
    calls.clear();
    playing.clear();
    peakPlaying = 0;
    cache = Directory.systemTemp.createTempSync('doyel-svga-audio-test-');
    for (final name in ['a.svga', 'b.svga']) {
      File('${cache.path}/temp_$name.mp3').writeAsBytesSync([73, 68, 51]);
    }
    messenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (_) async => cache.path,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (_) async => null,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global/events'),
      (_) async => null,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (call) async {
        calls.add(call);
        final id = call.arguments['playerId'] as String;
        if (call.method == 'create') {
          final channel = 'xyz.luan/audioplayers/events/$id';
          eventChannels.add(channel);
          messenger.setMockMethodCallHandler(
            MethodChannel(channel),
            (_) async => null,
          );
        } else if (call.method == 'setSourceUrl') {
          await messenger.handlePlatformMessage(
            'xyz.luan/audioplayers/events/$id',
            const StandardMethodCodec().encodeSuccessEnvelope({
              'event': 'audio.onPrepared',
              'value': true,
            }),
            (_) {},
          );
        } else if (call.method == 'resume') {
          playing.add(id);
          if (playing.length > peakPlaying) peakPlaying = playing.length;
        } else if ([
          'stop',
          'pause',
          'release',
          'dispose',
        ].contains(call.method)) {
          playing.remove(id);
        }
        return ['getCurrentPosition', 'getDuration'].contains(call.method)
            ? 0
            : null;
      },
    );
  });

  tearDown(() {
    for (final channel in [
      ...eventChannels,
      'plugins.flutter.io/path_provider',
      'xyz.luan/audioplayers',
      'xyz.luan/audioplayers.global',
    ]) {
      messenger.setMockMethodCallHandler(MethodChannel(channel), null);
    }
    eventChannels.clear();
    cache.deleteSync(recursive: true);
  });

  Widget previews(_Parser parser, String? selected) => MaterialApp(
    home: Scaffold(
      body: Row(
        children: [
          for (final name in ['a.svga', 'b.svga'])
            SizedBox.square(
              dimension: 46,
              child: AnimatedMediaWidget(
                source: AnimatedMediaSource.fromUrls(
                  svga: 'https://example.test/$name',
                ),
                svgaParser: parser,
                enableSvgaAudio: selected == name,
              ),
            ),
        ],
      ),
    ),
  );

  Future<void> tick(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
  }

  testWidgets(
    'browsing is silent; changing selection keeps only one embedded soundtrack',
    (tester) async {
      final parser = _Parser();
      await tester.pumpWidget(previews(parser, null));
      await tick(tester);
      expect(calls.where((call) => call.method == 'create'), isEmpty);
      expect(parser.decoded.every((movie) => movie.audios.isEmpty), isTrue);
      expect(find.byType(SVGAImage), findsNWidgets(2));

      await tester.pumpWidget(previews(parser, 'a.svga'));
      await tick(tester);
      expect(playing, hasLength(1));
      final firstPlayer = playing.single;

      await tester.pumpWidget(previews(parser, 'b.svga'));
      await tick(tester);
      expect(playing, hasLength(1));
      expect(playing, isNot(contains(firstPlayer)));
      expect(peakPlaying, 1);

      await tester.pumpWidget(previews(parser, null));
      await tick(tester);
      expect(playing, isEmpty);
      await tester.pumpWidget(previews(parser, 'a.svga'));
      await tick(tester);
      expect(playing, hasLength(1));
      await tester.pumpWidget(const SizedBox.shrink());
      await tick(tester);
      expect(playing, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('closing during decode cannot start a late soundtrack', (
    tester,
  ) async {
    final pending = Completer<MovieEntity>();
    final parser = _Parser()..pending = pending;
    await tester.pumpWidget(
      MaterialApp(
        home: AnimatedMediaWidget(
          source: AnimatedMediaSource.fromUrls(
            svga: 'https://example.test/a.svga',
          ),
          svgaParser: parser,
        ),
      ),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    pending.complete(_movie('a.svga'));
    await tick(tester);
    expect(calls.where((call) => call.method == 'create'), isEmpty);
    expect(playing, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
