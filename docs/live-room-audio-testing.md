# Live-room headphone verification

The room must prefer a connected wired or Bluetooth headset, with the phone
speaker as the default fallback. Android uses WebRTC's headset-priority method;
iOS uses LiveKit's non-forced speaker preference so its audio-session management
continues to handle transitions between listening and publishing a microphone.

Run these checks on physical Android and iOS devices with both wired/USB
headphones and Bluetooth earbuds. A simulator or mocked plugin cannot verify
Bluetooth audio profiles or the microphone/output hardware.

| Scenario | Expected result |
| --- | --- |
| Connect headphones before entering a room as viewer or host | Room audio stays in the headphones. |
| Viewer is accepted into an audio call or video call | Audio stays in the headphones; the other participant can hear the microphone. |
| Mute/unmute, end the call, then join again | Headphones remain selected. |
| Connect headphones while already in a room | Audio moves to the headphones. |
| Disconnect and reconnect headphones during a call | Audio returns to the headphones after reconnection. |
| Network reconnect while in a call | Headphones remain selected. |
| Leave and re-enter a room with headphones connected | The new room uses the headphones. |
| Join with no headphones | Audio plays through the phone speaker. |
| Android 12+: grant Nearby devices access on first entry | Bluetooth headphones are available for call audio. |

Also play a gift/entry sound during a call to check for interference from other
audio plugins. Check both directions of audio with a second device. A brief
Bluetooth media-to-call-profile transition can occur when the microphone starts;
the final output must remain in the headset.

Automated routing checks: `flutter test test/live_room_audio_routing_test.dart`.
