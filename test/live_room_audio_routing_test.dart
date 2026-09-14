import 'dart:async';

import 'package:doyel_live/app/modules/live_streaming/utlls/live_room_audio_routing.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livekit_client/livekit_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('FlutterWebRTC.Method');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final calls = <MethodCall>[];
  const speaker = MediaDevice('speakerphone', 'Speaker', 'audiooutput', null);
  const bluetooth = MediaDevice('bluetooth', 'Headphones', 'audiooutput', null);
  const wired = MediaDevice('headset', 'Wired headset', 'audiooutput', null);
  late LiveRoomAudioRouting routing;
  Object? nextRouteError;
  Completer<void>? routeBlocked;

  Iterable<MethodCall> getRouteCalls() =>
      calls.where((call) => call.method.startsWith('enableSpeakerphone'));

  Future<void> devicesChanged(List<MediaDevice> devices) async {
    Hardware.instance.onDeviceChange.add(devices);
    // Drain the broadcast event and the queued native route operation.
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);
  }

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    calls.clear();
    nextRouteError = null;
    routeBlocked = null;
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (call.method == 'getSources') {
        return {'sources': <dynamic>[]};
      }
      if (call.method.startsWith('enableSpeakerphone')) {
        final error = nextRouteError;
        nextRouteError = null;
        if (error != null) throw error;
        await routeBlocked?.future;
      }
      return null;
    });
    routing = LiveRoomAudioRouting();
  });

  tearDown(() async {
    await routing.dispose();
    messenger.setMockMethodCallHandler(channel, null);
    debugDefaultTargetPlatformOverride = null;
  });

  test(
    'joining uses headset priority instead of forcing the speaker',
    () async {
      await routing.start(speakerPreferred: true);
      expect(getRouteCalls().map((call) => call.method), [
        'enableSpeakerphoneButPreferBluetooth',
      ]);

      // Starting the microphone or reconnecting must keep the same policy.
      await routing.refresh();
      expect(
        getRouteCalls().every(
          (call) => call.method == 'enableSpeakerphoneButPreferBluetooth',
        ),
        isTrue,
      );
    },
  );

  test('headset attach, removal and reconnection refresh the route', () async {
    await routing.start(speakerPreferred: true);
    await devicesChanged([speaker]);
    calls.clear();

    await devicesChanged([speaker, bluetooth]);
    await devicesChanged([speaker]);
    await devicesChanged([speaker, wired]);
    await devicesChanged([speaker]);
    await devicesChanged([speaker, bluetooth]);

    expect(getRouteCalls(), hasLength(5));
    expect(
      getRouteCalls().every(
        (call) => call.method == 'enableSpeakerphoneButPreferBluetooth',
      ),
      isTrue,
    );
  });

  test('route notifications and camera changes do not cause a loop', () async {
    await routing.start(speakerPreferred: true);
    await devicesChanged([speaker, bluetooth]);
    calls.clear();

    await devicesChanged([bluetooth, speaker]);
    await devicesChanged([
      speaker,
      bluetooth,
      const MediaDevice('front', 'Front camera', 'videoinput', null),
    ]);
    expect(getRouteCalls(), isEmpty);
  });

  test('changing the phone fallback never forces speaker output', () async {
    await routing.start(speakerPreferred: true);
    calls.clear();
    await routing.setSpeakerPreferred(false);
    expect(getRouteCalls().single.method, 'enableSpeakerphone');
    expect(getRouteCalls().single.arguments, {'enable': false});

    calls.clear();
    await routing.setSpeakerPreferred(true);
    expect(
      getRouteCalls().single.method,
      'enableSpeakerphoneButPreferBluetooth',
    );
  });

  test('a device failure does not poison subsequent route updates', () async {
    nextRouteError = PlatformException(code: 'device_unavailable');
    await routing.start(speakerPreferred: true);
    await devicesChanged([speaker, bluetooth]);
    expect(getRouteCalls(), hasLength(2));
  });

  test(
    'leaving cancels queued routing and removes the device listener',
    () async {
      await routing.start(speakerPreferred: true);
      calls.clear();
      final blocker = Completer<void>();
      routeBlocked = blocker;
      final running = routing.refresh();
      await Future<void>.delayed(Duration.zero);
      final queued = routing.refresh();
      final disposed = routing.dispose();
      blocker.complete();
      await Future.wait([running, queued, disposed]);
      expect(getRouteCalls(), hasLength(1));

      calls.clear();
      await devicesChanged([speaker, wired]);
      await routing.refresh();
      await routing.start(speakerPreferred: true);
      expect(getRouteCalls(), isEmpty);
    },
  );
}
