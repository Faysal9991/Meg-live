import 'package:livekit_client/livekit_client.dart';

class LivekitStuffs {
  Future<RoomOptions> getRoomOptions({
    String? preferredCodec,
    // int? maxBitrate,
    // int? maxFramerate,
    bool enableHostHDRoom = false,
    bool isHost = false,
    bool allowVideoCall = true,
  }) async {
    if (!allowVideoCall) {
      // print('audioRoomOptions................................');

      return audioRoomOptions(videoCodec: preferredCodec);
    }
    if (isHost) {
      if (enableHostHDRoom) {
        // print('hostHDRoomOptions................................');
        return hostHDRoomOptions(videoCodec: preferredCodec);
      } else {
        // print('hostSDRoomOptions................................');

        return hostSDRoomOptions(videoCodec: preferredCodec);
      }
    }
    // print('participantRoomOptions................................');

    return participantRoomOptions(videoCodec: preferredCodec);

    // var cameraEncoding = VideoEncoding(
    //   maxBitrate: maxBitrate ?? 3 * 1000 * 1000,
    //   maxFramerate: maxFramerate ?? 30,
    // );

    // return RoomOptions(
    //   adaptiveStream: true,
    //   dynacast: true,
    //   // defaultAudioPublishOptions: const AudioPublishOptions(
    //   //   name: 'custom_audio_track_name',
    //   // ),
    //   defaultCameraCaptureOptions: CameraCaptureOptions(
    //     maxFrameRate: allowVideoCall ? 30 : 10,
    //     params: VideoParameters(
    //       // dimensions: VideoDimensions(1280, 720),
    //       dimensions: allowVideoCall
    //           ? VideoDimensionsPresets.h720_169
    //           : VideoDimensionsPresets.h90_169,
    //       encoding: allowVideoCall ? cameraEncoding : null,
    //     ),
    //   ),

    //   defaultVideoPublishOptions: allowVideoCall
    //       ? VideoPublishOptions(
    //           simulcast: true,
    //           videoCodec: preferredCodec ?? 'AV1',
    //           // backupVideoCodec: backupVideoCodec,
    //           backupVideoCodec: const BackupVideoCodec(enabled: true),
    //           videoEncoding: cameraEncoding,
    //           // screenShareEncoding: screenEncoding,
    //         )
    //       : VideoPublishOptions(simulcast: false),
    // );
  }
}

RoomOptions hostHDRoomOptions({String? videoCodec = 'VP9'}) => RoomOptions(
  adaptiveStream: true,
  dynacast: true,

  defaultCameraCaptureOptions: CameraCaptureOptions(
    maxFrameRate: 30,
    params: VideoParameters(
      dimensions: VideoDimensionsPresets.h720_169,
      encoding: VideoEncoding(
        maxBitrate: 1200 * 1000, // ~1.2 Mbps
        maxFramerate: 30,
      ),
    ),
  ),

  defaultVideoPublishOptions: VideoPublishOptions(
    simulcast: true,
    videoCodec: videoCodec!,
    videoSimulcastLayers: [
      VideoParameters(
        dimensions: VideoDimensionsPresets.h180_169,
        encoding: VideoEncoding(maxBitrate: 150 * 1000, maxFramerate: 15),
        description: '180p-low',
      ),
      VideoParameters(
        dimensions: VideoDimensionsPresets.h360_169,
        encoding: VideoEncoding(maxBitrate: 500 * 1000, maxFramerate: 20),
        description: '360p-mid',
      ),
      VideoParameters(
        dimensions: VideoDimensionsPresets.h720_169,
        encoding: VideoEncoding(maxBitrate: 1200 * 1000, maxFramerate: 30),
        description: '720p-high',
      ),
    ],
  ),

  defaultAudioPublishOptions: AudioPublishOptions(
    dtx: true,
    // stereo: true,
    audioBitrate: AudioPreset.music,
    red: true,
  ),
);

RoomOptions hostSDRoomOptions({String? videoCodec = 'VP9'}) => RoomOptions(
  adaptiveStream: true,
  dynacast: true,

  defaultCameraCaptureOptions: CameraCaptureOptions(
    maxFrameRate: 24, // smoother than 20fps but lighter than 30fps
    params: VideoParameters(
      dimensions: VideoDimensionsPresets.h540_169, // capture at 540p
      encoding: VideoEncoding(
        maxBitrate: 600 * 1000, // ~600 kbps
        maxFramerate: 24,
      ),
    ),
  ),

  defaultVideoPublishOptions: VideoPublishOptions(
    simulcast: true,
    videoCodec: videoCodec!,
    videoSimulcastLayers: [
      // For grid thumbnails
      VideoParameters(
        dimensions: VideoDimensionsPresets.h180_169,
        encoding: VideoEncoding(maxBitrate: 150 * 1000, maxFramerate: 15),
        description: '180p-low',
      ),
      // For spotlight / active speaker
      VideoParameters(
        dimensions: VideoDimensionsPresets.h540_169,
        encoding: VideoEncoding(maxBitrate: 600 * 1000, maxFramerate: 24),
        description: '540p-sd',
      ),
    ],
  ),

  defaultAudioPublishOptions: AudioPublishOptions(
    dtx: true,
    // stereo: true, // give host slightly better audio
    audioBitrate: AudioPreset.music,
    red: true,
  ),
);

RoomOptions participantRoomOptions({String? videoCodec = 'VP9'}) => RoomOptions(
  adaptiveStream: true,
  dynacast: true,

  defaultCameraCaptureOptions: CameraCaptureOptions(
    maxFrameRate: 20,
    params: VideoParameters(
      dimensions: VideoDimensionsPresets.h360_169,
      encoding: VideoEncoding(maxBitrate: 400 * 1000, maxFramerate: 20),
    ),
  ),

  defaultVideoPublishOptions: VideoPublishOptions(
    simulcast: true,
    videoCodec: videoCodec!,
    videoSimulcastLayers: [
      VideoParameters(
        dimensions: VideoDimensionsPresets.h180_169,
        encoding: VideoEncoding(maxBitrate: 120 * 1000, maxFramerate: 15),
        description: '180p-low',
      ),
      VideoParameters(
        dimensions: VideoDimensionsPresets.h360_169,
        encoding: VideoEncoding(maxBitrate: 400 * 1000, maxFramerate: 20),
        description: '360p-mid',
      ),
    ],
  ),

  defaultAudioPublishOptions: AudioPublishOptions(
    dtx: true,
    // stereo: false,
    audioBitrate: AudioPreset.speech,
    red: true,
  ),
);

RoomOptions audioRoomOptions({String? videoCodec = 'VP9'}) => RoomOptions(
  adaptiveStream: true,
  dynacast: true,

  defaultCameraCaptureOptions: CameraCaptureOptions(
    maxFrameRate: 5,
    params: VideoParameters(
      dimensions: VideoDimensionsPresets.h90_169,
      encoding: VideoEncoding(maxBitrate: 10 * 1000, maxFramerate: 5),
    ),
  ),

  defaultVideoPublishOptions: VideoPublishOptions(
    simulcast: false,
    videoCodec: videoCodec!,
    // videoSimulcastLayers: [
    //   VideoParameters(
    //     dimensions: VideoDimensionsPresets.h90_169,
    //     encoding: VideoEncoding(maxBitrate: 10 * 1000, maxFramerate: 5),
    //   ),
    // ],
  ),

  defaultAudioPublishOptions: AudioPublishOptions(
    dtx: true,
    // stereo: false,
    audioBitrate: AudioPreset.musicStereo,
    red: true,
  ),
);
