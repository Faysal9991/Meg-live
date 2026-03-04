// import 'package:livekit_client/livekit_client.dart';

// class LivekitStuffs {
//   Future<RoomOptions> getRoomOptions({
//     String? preferredCodec,
//     int? maxBitrate,
//     int? maxFramerate,
//   }) async {
//     // maxBitrate = 1700 * 1000;
//     // maxBitrate = 800 * 1000;
//     // maxFramerate = 25;
//     var cameraEncoding = VideoEncoding(
//       maxBitrate: maxBitrate ?? 5 * 1000 * 1000,
//       maxFramerate: maxFramerate ?? 30,
//     );

//     return RoomOptions(
//       adaptiveStream: true,
//       dynacast: true,
//       // defaultAudioPublishOptions: const AudioPublishOptions(
//       //   name: 'custom_audio_track_name',
//       // ),
//       defaultCameraCaptureOptions: const CameraCaptureOptions(
//         maxFrameRate: 30,
//         params: VideoParameters(
//           // dimensions: VideoDimensions(1280, 720),
//           dimensions: VideoDimensionsPresets.h720_169,
//         ),
//       ),

//       // defaultScreenShareCaptureOptions: const ScreenShareCaptureOptions(
//       //     useiOSBroadcastExtension: true,
//       //     params: VideoParameters(
//       //       dimensions: VideoDimensionsPresets.h1080_169,
//       //     )),
//       defaultVideoPublishOptions: VideoPublishOptions(
//         simulcast: true,
//         videoCodec: preferredCodec ?? 'AV1',
//         // backupVideoCodec: backupVideoCodec,
//         backupVideoCodec: const BackupVideoCodec(
//           enabled: true,
//         ),
//         videoEncoding: cameraEncoding,
//         // screenShareEncoding: screenEncoding,
//       ),
//     );
//   }
// }
