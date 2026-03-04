import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

import 'no_video.dart';
import 'participant_info.dart';

abstract class ParticipantWidget extends StatefulWidget {
  // Convenience method to return relevant widget for participant
  static ParticipantWidget widgetFor({
    required ParticipantTrack participantTrack,
    required dynamic data,
  }) {
    if (participantTrack.participant is LocalParticipant) {
      return LocalParticipantWidget(
        participantTrack.participant as LocalParticipant,
        participantTrack.videoTrack,
        participantTrack.isScreenShare,
        data,
      );
    } else if (participantTrack.participant is RemoteParticipant) {
      return RemoteParticipantWidget(
        participantTrack.participant as RemoteParticipant,
        participantTrack.videoTrack,
        participantTrack.isScreenShare,
        data,
      );
    }
    throw UnimplementedError('Unknown participant type');
  }

  // Must be implemented by child class
  abstract final Participant participant;
  abstract final VideoTrack? videoTrack;
  abstract final bool isScreenShare;
  abstract final dynamic data;
  final VideoQuality quality;

  const ParticipantWidget({
    // this.quality = VideoQuality.HIGH,
    this.quality = VideoQuality.MEDIUM,
    // this.quality = VideoQuality.LOW,
    // this.quality = VideoQuality.OFF,
    super.key,
  });
}

class LocalParticipantWidget extends ParticipantWidget {
  @override
  final LocalParticipant participant;
  @override
  final VideoTrack? videoTrack;
  @override
  final bool isScreenShare;
  @override
  final dynamic data;

  const LocalParticipantWidget(
    this.participant,
    this.videoTrack,
    this.isScreenShare,
    this.data, {
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _LocalParticipantWidgetState();
}

class RemoteParticipantWidget extends ParticipantWidget {
  @override
  final RemoteParticipant participant;
  @override
  final VideoTrack? videoTrack;
  @override
  final bool isScreenShare;
  @override
  final dynamic data;

  const RemoteParticipantWidget(
    this.participant,
    this.videoTrack,
    this.isScreenShare,
    this.data, {
    Key? key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RemoteParticipantWidgetState();
}

abstract class _ParticipantWidgetState<T extends ParticipantWidget>
    extends State<T> {
  //
  final bool _visible = true;
  VideoTrack? get activeVideoTrack;
  TrackPublication? get videoPublication;
  TrackPublication? get firstAudioPublication;
  dynamic get data;
  late LiveStreamingController _livekitStreamingController;
  // late AuthController _authController;

  @override
  void initState() {
    super.initState();
    // _authController = Get.find();
    _livekitStreamingController = Get.find();
    widget.participant.addListener(_onParticipantChanged);
    _onParticipantChanged();
  }

  @override
  void dispose() {
    widget.participant.removeListener(_onParticipantChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    oldWidget.participant.removeListener(_onParticipantChanged);
    widget.participant.addListener(_onParticipantChanged);
    _onParticipantChanged();
    super.didUpdateWidget(oldWidget);
  }

  // Notify Flutter that UI re-build is required, but we don't set anything here
  // since the updated values are computed properties.
  void _onParticipantChanged() => setState(() {});

  // Widgets to show above the info bar
  List<Widget> extraWidgets(bool isScreenShare) => [];

  @override
  Widget build(BuildContext ctx) => Container(
    // foregroundDecoration: BoxDecoration(
    //   border: widget.participant.isSpeaking && !widget.isScreenShare
    //       ? Border.all(
    //           color: Colors.red.shade600,
    //           width: 3,
    //           strokeAlign: StrokeAlign.center,
    //         )
    //       : Border.all(color: Colors.white30),
    // ),
    // decoration: const BoxDecoration(
    //   // color: Theme.of(ctx).cardColor,
    //   color: Colors.black,
    //   // color: Colors.transparent,
    //   image: DecorationImage(
    //     image: AssetImage('assets/others/loading_black.gif'),
    //     fit: BoxFit.contain,
    //   ),
    // ),
    child: activeVideoTrack != null && !activeVideoTrack!.muted
        ? Stack(
            children: [
              Container(
                color: Colors.black,
                child: VideoTrackRenderer(
                  activeVideoTrack!,
                  // fit: rtc.RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  fit: VideoViewFit.cover,
                  // fit: _livekitStreamingController.listRenderView.length > 1
                  //     ? RTCVideoViewObjectFit.RTCVideoViewObjectFitCover
                  //     : RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                  // mirrorMode: data['camera_position'] == 'back'
                  //     ? VideoViewMirrorMode.auto
                  //     : VideoViewMirrorMode.mirror,
                  // mirrorMode: (_livekitStreamingController.channelName.value ==
                  //                 _authController.profile.value.user!.uid!
                  //                     .toString() &&
                  //             _livekitStreamingController
                  //                     .cameraPosition.value.name ==
                  //                 'front') ||
                  //         (_livekitStreamingController.channelName.value ==
                  //                 data['uid'].toString() &&
                  //             _livekitStreamingController
                  //                     .liveStreamData.value['cm_pos_nm'] ==
                  //                 'front')
                  //     ? VideoViewMirrorMode.mirror
                  //     : VideoViewMirrorMode.auto,
                ),
              ),
              // TODO: For Testing purpose only
              // VideoParameters: description
              // Center(
              //   child: Text(
              //     '${_livekitStreamingController.videoDimensionsDescription}',
              //     style: TextStyle(
              //       backgroundColor: Colors.black87,
              //       color: Colors.white,
              //       fontWeight: FontWeight.w600,
              //     ),
              //   ),
              // ),
              data != null ||
                      _livekitStreamingController.listRenderView.length == 1
                  ? Container()
                  : Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: Colors.black38),
                        child: Text(
                          widget.participant.name,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
            ],
          )
        : data != null
        ? NoVideoWidget(data: data)
        : Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Theme.of(context).primaryColor],
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
              border: Border.all(color: Colors.white24, width: 2),
            ),
            child: Text(
              widget.participant.name,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
    // child: Stack(
    //   children: [
    //     // Video
    //     // InkWell(
    //     //   onTap: () => setState(() => _visible = !_visible),
    //     //   child: activeVideoTrack != null && !activeVideoTrack!.muted
    //     //       ? VideoTrackRenderer(
    //     //           activeVideoTrack!,
    //     //           fit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
    //     //         )
    //     //       : const NoVideoWidget(),
    //     // ),
    //     // activeVideoTrack != null && !activeVideoTrack!.muted
    //     activeVideoTrack != null && !activeVideoTrack!.muted
    //         ? VideoTrackRenderer(
    //             activeVideoTrack!,
    //             // fit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
    //             // Testing
    //             fit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
    //             mirrorMode: VideoViewMirrorMode.mirror,
    //           )
    //         : NoVideoWidget(
    //             data: data,
    //           ),

    //     // // Bottom bar
    //     // Align(
    //     //   alignment: Alignment.bottomCenter,
    //     //   child: Column(
    //     //     crossAxisAlignment: CrossAxisAlignment.stretch,
    //     //     mainAxisSize: MainAxisSize.min,
    //     //     children: [
    //     //       // ...extraWidgets(widget.isScreenShare),
    //     //       ParticipantInfoWidget(
    //     //         title: widget.participant.name.isNotEmpty
    //     //             ? '${widget.participant.name} (${widget.participant.identity})'
    //     //             : widget.participant.identity,
    //     //         audioAvailable: firstAudioPublication?.muted == false &&
    //     //             firstAudioPublication?.subscribed == true,
    //     //         connectionQuality: widget.participant.connectionQuality,
    //     //         isScreenShare: widget.isScreenShare,
    //     //       ),
    //     //     ],
    //     //   ),
    //     // ),
    //   ],
    // ),
  );
}

class _LocalParticipantWidgetState
    extends _ParticipantWidgetState<LocalParticipantWidget> {
  @override
  LocalTrackPublication<LocalVideoTrack>? get videoPublication => widget
      .participant
      .videoTrackPublications
      .where((element) => element.sid == widget.videoTrack?.sid)
      .firstOrNull;

  @override
  LocalTrackPublication<LocalAudioTrack>? get firstAudioPublication =>
      widget.participant.audioTrackPublications.firstOrNull;

  @override
  VideoTrack? get activeVideoTrack => widget.videoTrack;

  @override
  dynamic get data => widget.data;
}

class _RemoteParticipantWidgetState
    extends _ParticipantWidgetState<RemoteParticipantWidget> {
  @override
  RemoteTrackPublication<RemoteVideoTrack>? get videoPublication => widget
      .participant
      .videoTrackPublications
      .where((element) => element.sid == widget.videoTrack?.sid)
      .firstOrNull;

  @override
  RemoteTrackPublication<RemoteAudioTrack>? get firstAudioPublication =>
      widget.participant.audioTrackPublications.firstOrNull;

  @override
  VideoTrack? get activeVideoTrack => widget.videoTrack;

  @override
  dynamic get data => widget.data;

  @override
  List<Widget> extraWidgets(bool isScreenShare) => [
    Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Menu for RemoteTrackPublication<RemoteVideoTrack>
        if (videoPublication != null)
          RemoteTrackPublicationMenuWidget(
            pub: videoPublication!,
            icon: isScreenShare ? EvaIcons.monitor : EvaIcons.video,
          ),
        // Menu for RemoteTrackPublication<RemoteAudioTrack>
        if (firstAudioPublication != null && !isScreenShare)
          RemoteTrackPublicationMenuWidget(
            pub: firstAudioPublication!,
            icon: EvaIcons.volumeUp,
          ),
      ],
    ),
  ];
}

class RemoteTrackPublicationMenuWidget extends StatelessWidget {
  final IconData icon;
  final RemoteTrackPublication pub;
  const RemoteTrackPublicationMenuWidget({
    required this.pub,
    required this.icon,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.black.withOpacity(0.3),
    child: PopupMenuButton<Function>(
      tooltip: 'Subscribe menu',
      icon: Icon(
        icon,
        color: {
          TrackSubscriptionState.notAllowed: Colors.red,
          TrackSubscriptionState.unsubscribed: Colors.grey,
          TrackSubscriptionState.subscribed: Colors.green,
        }[pub.subscriptionState],
      ),
      onSelected: (value) => value(),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<Function>>[
        // Subscribe/Unsubscribe
        if (pub.subscribed == false)
          PopupMenuItem(
            child: const Text('Subscribe'),
            value: () => pub.subscribe(),
          )
        else if (pub.subscribed == true)
          PopupMenuItem(
            child: const Text('Un-subscribe'),
            value: () => pub.unsubscribe(),
          ),
      ],
    ),
  );
}
