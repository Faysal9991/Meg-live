import 'dart:async';
import 'package:doyel_live/app/modules/live_streaming/utlls/guest_call_media.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final cameraOff in [true, false]) {
    test(
      '${cameraOff ? 'audio' : 'video'} starts with the chosen camera state',
      () async {
        final calls = <String>[];
        await applyGuestCallMedia(
          cameraOff: cameraOff,
          muted: false,
          isCurrentCall: () => true,
          requestCameraPermission: () async {
            calls.add('camera permission');
            return true;
          },
          requestMicrophonePermission: () async => true,
          setCameraEnabled: (enabled) async => calls.add('camera $enabled'),
          setMicrophoneEnabled: (enabled) async =>
              calls.add('microphone $enabled'),
        );
        expect(
          calls,
          cameraOff
              ? ['camera false', 'microphone true']
              : ['camera permission', 'camera true', 'microphone true'],
        );
      },
    );
  }

  test(
    'ending a call during the permission prompt cannot enable media',
    () async {
      final permission = Completer<bool>();
      final calls = <bool>[];
      var active = true;
      final pending = applyGuestCallMedia(
        cameraOff: false,
        muted: false,
        isCurrentCall: () => active,
        requestCameraPermission: () => permission.future,
        requestMicrophonePermission: () async => true,
        setCameraEnabled: (enabled) async => calls.add(enabled),
        setMicrophoneEnabled: (enabled) async => calls.add(enabled),
      );
      active = false;
      permission.complete(true);
      await pending;
      expect(calls, isEmpty);
    },
  );

  test('camera denial still allows the microphone to join', () async {
    final calls = <String>[];
    await applyGuestCallMedia(
      cameraOff: false,
      muted: false,
      isCurrentCall: () => true,
      requestCameraPermission: () async => false,
      requestMicrophonePermission: () async => true,
      setCameraEnabled: (enabled) async => calls.add('camera'),
      setMicrophoneEnabled: (enabled) async => calls.add('microphone'),
    );
    expect(calls, ['microphone']);
  });
}
