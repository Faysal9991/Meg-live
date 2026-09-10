import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ParticipantTrack {
  ParticipantTrack({
    required this.participant,
    required this.videoTrack,
    required this.isScreenShare,
  });
  VideoTrack? videoTrack;
  Participant participant;
  final bool isScreenShare;
}

class ParticipantInfoWidget extends StatelessWidget {
  //
  final String? title;
  final bool audioAvailable;
  final ConnectionQuality connectionQuality;
  final bool isScreenShare;

  const ParticipantInfoWidget({
    this.title,
    this.audioAvailable = true,
    this.connectionQuality = ConnectionQuality.unknown,
    this.isScreenShare = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
    color: AppColors.textPrimary.withValues(alpha: 0.3),
    padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // if (title != null)
        //   Flexible(
        //     child: Text(
        //       title!,
        //       overflow: TextOverflow.ellipsis,
        //     ),
        //   ),
        isScreenShare
            ? const Padding(
                padding: EdgeInsets.only(left: 5),
                child: Icon(
                  LucideIcons.monitor,
                  color: AppColors.surface,
                  size: 16,
                ),
              )
            : Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Icon(
                  audioAvailable ? LucideIcons.mic : LucideIcons.micOff,
                  color: audioAvailable ? AppColors.surface : AppColors.error,
                  size: 16,
                ),
              ),
        if (connectionQuality != ConnectionQuality.unknown)
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Icon(
              connectionQuality == ConnectionQuality.poor
                  ? LucideIcons.wifiOff
                  : LucideIcons.wifi,
              color: {
                ConnectionQuality.excellent: AppColors.success,
                ConnectionQuality.good: AppColors.warning,
                ConnectionQuality.poor: AppColors.error,
              }[connectionQuality],
              size: 16,
            ),
          ),
      ],
    ),
  );
}
