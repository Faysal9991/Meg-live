import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:doyel_live/app/widgets/animated_media_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svga/flutter_svga.dart';
import 'package:flutter_test/flutter_test.dart';
// Use the installed player's platform contract to simulate native completion.
// ignore: depend_on_referenced_packages
import 'package:video_player_platform_interface/video_player_platform_interface.dart';

MovieEntity _fiveSecondMovie() => MovieEntity(
  params: MovieParams(
    viewBoxWidth: 40,
    viewBoxHeight: 40,
    frames: 100,
    fps: 20,
  ),
);

class _Parser extends SVGAParser {
  Completer<MovieEntity>? pending;

  @override
  Future<MovieEntity> decodeFromURL(String url) async =>
      pending == null ? _fiveSecondMovie() : pending!.future;
}

// Two one-pixel GIF frames: red for 2 seconds, then blue for 3.5 seconds.
// The file requests infinite looping; entry playback must still stop at 5.5s.
const _gif =
    'R0lGODlhAQABAIAAAP8AAAAA/yH/C05FVFNDQVBFMi4wAwEAAAAh+QQAyAAAACwAAAAA'
    'AQABAAACAkQBACH5BABeAQAALAAAAAABAAEAAAICTAEAOw==';

class _DecodedCodec extends Fake implements ui.Codec {
  _DecodedCodec(this.frames);
  final List<ui.FrameInfo> frames;
  int framesRead = 0;
  bool disposed = false;

  @override
  int get frameCount => frames.length;
  @override
  int get repetitionCount => -1;
  @override
  Future<ui.FrameInfo> getNextFrame() async => frames[framesRead++];
  @override
  void dispose() {
    disposed = true;
    for (final frame in frames.skip(framesRead)) {
      frame.image.dispose();
    }
  }
}

Future<_DecodedCodec> _decodeGif(WidgetTester tester) async {
  // Decode real metadata outside the fake clock, then test the widget's frame
  // scheduling deterministically without waiting for engine threads.
  return (await tester.runAsync(() async {
    final codec = await ui.instantiateImageCodec(base64Decode(_gif));
    final frames = <ui.FrameInfo>[];
    for (var i = 0; i < codec.frameCount; i++) {
      frames.add(await codec.getNextFrame());
    }
    codec.dispose();
    return _DecodedCodec(frames);
  }))!;
}

class _VideoPlatform extends VideoPlayerPlatform {
  final events = StreamController<VideoEvent>();
  bool disposed = false;
  bool? looping;

  @override
  Future<void> init() async {}
  @override
  Future<int> createWithOptions(VideoCreationOptions options) async {
    events.add(
      VideoEvent(
        eventType: VideoEventType.initialized,
        duration: const Duration(seconds: 8),
        size: const Size(40, 40),
      ),
    );
    return 1;
  }

  @override
  Stream<VideoEvent> videoEventsFor(int playerId) => events.stream;
  @override
  Future<void> dispose(int playerId) async {
    disposed = true;
    await events.close();
  }

  @override
  Future<void> play(int playerId) async {}
  @override
  Future<void> pause(int playerId) async {}
  @override
  Future<void> setLooping(int playerId, bool looping) async {
    this.looping = looping;
  }

  @override
  Future<void> setVolume(int playerId, double volume) async {}
  @override
  Future<void> setPlaybackSpeed(int playerId, double speed) async {}
  @override
  Future<void> seekTo(int playerId, Duration position) async {}
  @override
  Future<Duration> getPosition(int playerId) async => Duration.zero;
  @override
  Widget buildView(int playerId) => const SizedBox.expand();
}

Widget _host(Widget child) => MaterialApp(home: Center(child: child));

void main() {
  testWidgets(
    'SVGA waits for loading and its full duration; same URL replays',
    (tester) async {
      final parser = _Parser()..pending = Completer<MovieEntity>();
      var started = 0;
      var completed = 0;
      Widget entry(Object occurrence) => _host(
        AnimatedMediaWidget(
          key: ObjectKey(occurrence),
          source: AnimatedMediaSource.fromUrls(
            svga: 'https://example.com/entry.svga',
          ),
          svgaParser: parser,
          loop: false,
          onPlaybackStarted: () => started++,
          onCompleted: () => completed++,
        ),
      );

      await tester.pumpWidget(entry(Object()));
      await tester.pump(const Duration(seconds: 4));
      expect(started, 0);
      expect(completed, 0);
      parser.pending!.complete(_fiveSecondMovie());
      await tester.pump();
      await tester.pump();
      expect(started, 1);
      await tester.pump(const Duration(seconds: 3));
      expect(completed, 0);
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 16));
      expect(completed, 1);
      await tester.pump(const Duration(seconds: 8));
      expect(completed, 1);

      parser.pending = null;
      await tester.pumpWidget(entry(Object()));
      await tester.pump();
      expect(started, 2);
      await tester.pump(const Duration(seconds: 3));
      expect(completed, 1);
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(milliseconds: 16));
      expect(completed, 2);
      await tester.pumpWidget(const SizedBox.shrink());
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('SVGA failures report once and closing cancels completion', (
    tester,
  ) async {
    final parser = _Parser()..pending = Completer<MovieEntity>();
    var errors = 0;
    var completed = 0;
    Widget entry() => _host(
      AnimatedMediaWidget(
        key: UniqueKey(),
        source: AnimatedMediaSource.fromUrls(
          svga: 'https://example.com/entry.svga',
        ),
        svgaParser: parser,
        loop: false,
        onCompleted: () => completed++,
        onError: (_) => errors++,
      ),
    );
    await tester.pumpWidget(entry());
    parser.pending!.completeError(StateError('Unreadable SVGA'));
    await tester.pump();
    expect(errors, 1);
    expect(completed, 0);
    parser.pending = null;
    await tester.pumpWidget(entry());
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 10));
    expect(completed, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('GIF finishes one cycle after every frame has been displayed', (
    tester,
  ) async {
    final codec = await _decodeGif(tester);
    expect(codec.frames.map((frame) => frame.duration), [
      const Duration(seconds: 2),
      const Duration(milliseconds: 3500),
    ]);
    var started = 0;
    var completed = 0;
    await tester.pumpWidget(
      _host(
        AnimatedMediaWidget(
          source: AnimatedMediaSource.fromUrls(
            gif: 'https://example.com/entry.gif',
          ),
          loop: false,
          imageCodecLoader: (_) async => codec,
          onPlaybackStarted: () => started++,
          onCompleted: () => completed++,
        ),
      ),
    );
    await tester.pump();
    expect(started, 1);
    expect(codec.framesRead, 1);
    await tester.pump(const Duration(seconds: 2));
    expect(codec.framesRead, 2);
    await tester.pump(const Duration(seconds: 1));
    expect(completed, 0);
    await tester.pump(const Duration(milliseconds: 2499));
    expect(completed, 0);
    await tester.pump(const Duration(milliseconds: 1));
    expect(completed, 1);
    await tester.pump(const Duration(seconds: 10));
    expect(completed, 1);
    expect(codec.framesRead, 2);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(codec.disposed, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('closing during GIF loading disposes it without playing', (
    tester,
  ) async {
    final codec = await _decodeGif(tester);
    final pending = Completer<ui.Codec>();
    var callbacks = 0;
    await tester.pumpWidget(
      _host(
        AnimatedMediaWidget(
          source: AnimatedMediaSource.fromUrls(
            gif: 'https://example.com/entry.gif',
          ),
          loop: false,
          imageCodecLoader: (_) => pending.future,
          onPlaybackStarted: () => callbacks++,
          onCompleted: () => callbacks++,
          onError: (_) => callbacks++,
        ),
      ),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    pending.complete(codec);
    await tester.pump();
    expect(codec.disposed, isTrue);
    expect(codec.framesRead, 0);
    expect(callbacks, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('GIF playback errors report once', (tester) async {
    var errors = 0;
    await tester.pumpWidget(
      _host(
        AnimatedMediaWidget(
          source: AnimatedMediaSource.fromUrls(
            gif: 'https://example.com/broken.gif',
          ),
          loop: false,
          imageCodecLoader: (_) async => throw StateError('Invalid image'),
          onError: (_) => errors++,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 5));
    expect(errors, 1);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  testWidgets('video waits for native completion and reports it once', (
    tester,
  ) async {
    final previous = VideoPlayerPlatform.instance;
    final platform = _VideoPlatform();
    VideoPlayerPlatform.instance = platform;
    addTearDown(() => VideoPlayerPlatform.instance = previous);
    var completed = 0;
    var started = 0;
    await tester.pumpWidget(
      _host(
        AnimatedMediaWidget(
          source: AnimatedMediaSource.fromUrls(
            gif: 'https://example.com/entry.mp4',
          ),
          loop: false,
          onPlaybackStarted: () => started++,
          onCompleted: () => completed++,
        ),
      ),
    );
    await tester.pump();
    expect(started, 1);
    expect(platform.looping, isFalse);
    await tester.pump(const Duration(seconds: 3));
    expect(completed, 0);
    platform.events.add(VideoEvent(eventType: VideoEventType.completed));
    await tester.pump();
    expect(completed, 1);
    platform.events.add(VideoEvent(eventType: VideoEventType.completed));
    await tester.pump();
    expect(completed, 1);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    // Stream cancellation can complete in the real zone used by the platform.
    await tester.runAsync(() async {});
    await tester.pump();
    expect(platform.disposed, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('native video errors notify the queue without completing twice', (
    tester,
  ) async {
    final previous = VideoPlayerPlatform.instance;
    final platform = _VideoPlatform();
    VideoPlayerPlatform.instance = platform;
    addTearDown(() => VideoPlayerPlatform.instance = previous);
    var errors = 0;
    var completed = 0;
    await tester.pumpWidget(
      _host(
        AnimatedMediaWidget(
          source: AnimatedMediaSource.fromUrls(
            gif: 'https://example.com/entry.mp4',
          ),
          loop: false,
          onError: (_) => errors++,
          onCompleted: () => completed++,
        ),
      ),
    );
    await tester.pump();
    platform.events.addError(
      PlatformException(
        code: 'VideoError',
        message: 'The stream could not be decoded',
      ),
    );
    await tester.pump();
    expect(errors, 1);
    platform.events.add(VideoEvent(eventType: VideoEventType.completed));
    await tester.pump();
    expect(completed, 0);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
