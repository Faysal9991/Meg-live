import 'package:doyel_live/app/utils/model_parsers.dart';

class TopHost {
  const TopHost({
    required this.uid,
    required this.level,
    required this.vvipOrVipPreference,
    required this.fullName,
    required this.profileImage,
    required this.seconds,
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
  final bool isAgent;
  final bool isReseller;
  final bool isHost;
  final bool isModerator;

  factory TopHost.fromJson(Map<String, dynamic> json) {
    return TopHost(
      uid: intFromDynamic(json['uid']),
      level: json['level'],
      vvipOrVipPreference: mapFromDynamic(json['vvip_or_vip_preference']),
      fullName: (json['full_name'] ?? '').toString(),
      profileImage: nullableStringFromDynamic(json['profile_image']),
      seconds: intFromDynamic(json['seconds']),
      isAgent: boolFromDynamic(json['is_agent']),
      isReseller: boolFromDynamic(json['is_reseller']),
      isHost: boolFromDynamic(json['is_host']),
      isModerator: boolFromDynamic(json['is_moderator']),
    );
  }
}
