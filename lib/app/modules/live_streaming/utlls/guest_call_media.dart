/// Applies the initial media choice without briefly enabling an audio guest's
/// camera. Permission prompts and track publishing can finish after a call ends,
/// so recheck the call before each operation.
Future<void> applyGuestCallMedia({
  required bool cameraOff,
  required bool muted,
  required bool Function() isCurrentCall,
  required Future<bool> Function() requestCameraPermission,
  required Future<bool> Function() requestMicrophonePermission,
  required Future<void> Function(bool enabled) setCameraEnabled,
  required Future<void> Function(bool enabled) setMicrophoneEnabled,
}) async {
  if (!isCurrentCall()) return;
  if (cameraOff) {
    await setCameraEnabled(false);
  } else if (await requestCameraPermission() && isCurrentCall()) {
    await setCameraEnabled(true);
  }
  if (!isCurrentCall()) return;
  if (muted || await requestMicrophonePermission()) {
    if (isCurrentCall()) await setMicrophoneEnabled(!muted);
  }
}
