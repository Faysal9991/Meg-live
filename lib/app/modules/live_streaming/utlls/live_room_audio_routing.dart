import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;
import 'package:livekit_client/livekit_client.dart';

/// Keeps headsets ahead of the phone's speaker/earpiece fallback.
class LiveRoomAudioRouting {
  StreamSubscription<List<MediaDevice>>? _deviceSubscription;
  Set<String>? _audioOutputIds;
  Future<void> _pendingUpdate = Future<void>.value();
  bool _speakerPreferred = true;
  bool _disposed = false;

  Future<void> start({required bool speakerPreferred}) async {
    if (_disposed || kIsWeb) return;
    _speakerPreferred = speakerPreferred;
    if (defaultTargetPlatform == TargetPlatform.android) {
      _deviceSubscription ??= Hardware.instance.onDeviceChange.stream.listen(
        _onDevicesChanged,
      );
    }
    await refresh();
  }

  void _onDevicesChanged(List<MediaDevice> devices) {
    final outputIds = devices
        .where((device) => device.kind == 'audiooutput')
        .map((device) => device.deviceId)
        .toSet();
    // WebRTC also emits this event when our own route selection changes.
    // Only react to devices being added/removed, avoiding a routing loop.
    if (setEquals(_audioOutputIds, outputIds)) return;
    _audioOutputIds = outputIds;
    unawaited(refresh());
  }

  Future<void> setSpeakerPreferred(bool preferred) {
    _speakerPreferred = preferred;
    return refresh();
  }

  Future<void> refresh() {
    // Serialize join, microphone and device events so older work cannot win.
    _pendingUpdate = _pendingUpdate.then((_) async {
      if (_disposed || kIsWeb) return;
      try {
        if (defaultTargetPlatform == TargetPlatform.android) {
          if (_speakerPreferred) {
            // In WebRTC 1.2.x, setSpeakerphoneOn(true) forces the speaker.
            // This API checks BOTH Bluetooth and wired headsets first.
            await rtc.Helper.setSpeakerphoneOnButPreferBluetooth();
          } else {
            // Headsets still take priority; the earpiece is the fallback.
            await rtc.Helper.setSpeakerphoneOn(false);
          }
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          // LiveKit preserves Bluetooth category options as listeners become
          // callers. Bypassing it with WebRTC's speaker override breaks that.
          await Hardware.instance.setSpeakerphoneOn(
            _speakerPreferred,
            forceSpeakerOutput: false,
          );
        }
      } catch (error) {
        // A temporarily unavailable device must not abort the room connection
        // or prevent the next device event from retrying the route.
        debugPrint('[LIVE-ROOM] Could not update audio route: $error');
      }
    });
    return _pendingUpdate;
  }

  Future<void> dispose() async {
    _disposed = true;
    await _deviceSubscription?.cancel();
    _deviceSubscription = null;
    await _pendingUpdate;
  }
}
