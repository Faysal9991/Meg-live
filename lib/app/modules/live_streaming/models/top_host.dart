import 'package:doyel_live/app/utils/model_parsers.dart';

class TopHost {
  const TopHost({
    required this.uid,
    required this.level,
    required this.vvipOrVipPreference,
    required this.fullName,
    required this.profileImage,
    required this.seconds,
    required this.liveDurationSeconds,
    required this.giftDiamonds,
    required this.diamondsContributed,
    required this.isAgent,
    required this.isReseller,
    required this.isHost,
    required this.isModerator,
  });

  final int uid;
  final dynamic level;
  final dynamic vvipOrVipPreference;
  final String fullName;
  final String? profileImage;

  final int seconds;
  final int liveDurationSeconds;

  final int giftDiamonds;
  final int diamondsContributed;

  final bool isAgent;
  final bool isReseller;
  final bool isHost;
  final bool isModerator;

  factory TopHost.fromJson(Map<String, dynamic> json) {
    final user = json['user'] is Map
        ? Map<String, dynamic>.from(json['user'])
        : <String, dynamic>{};

    return TopHost(
      uid: intFromDynamic(
        json['uid'] ?? user['uid'] ?? json['id'],
      ),
      level: json['level'],
      vvipOrVipPreference: mapFromDynamic(
        json['vvip_or_vip_preference'],
      ),
      fullName: (json['full_name'] ?? '').toString(),
      profileImage: nullableStringFromDynamic(
        json['profile_image'] ?? json['photo_url'],
      ),

      seconds: intFromDynamic(json['seconds']),

      liveDurationSeconds: intFromDynamic(
        json['live_duration_seconds'],
      ),

      giftDiamonds: intFromDynamic(
        json['gift_diamonds'],
      ),

      diamondsContributed: intFromDynamic(
        json['diamonds_contributed'],
      ),

      isAgent: boolFromDynamic(json['is_agent']),
      isReseller: boolFromDynamic(json['is_reseller']),
      isHost: boolFromDynamic(json['is_host']),
      isModerator: boolFromDynamic(json['is_moderator']),
    );
  }
}