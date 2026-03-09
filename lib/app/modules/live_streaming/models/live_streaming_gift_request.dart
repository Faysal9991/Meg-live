class LiveStreamingGiftRequest {
  const LiveStreamingGiftRequest({
    required this.roomName,
    required this.senderUid,
    required this.receiverUids,
    required this.giftType,
    required this.giftId,
    required this.totalDiamonds,
    required this.diamonds,
    required this.vat,
    required this.fullName,
    required this.receiverFullName,
    required this.profileImage,
    required this.level,
    required this.giftImage,
    required this.gif,
    required this.audio,
    required this.vvipOrVipPreference,
  });

  final String roomName;
  final int senderUid;
  final List<int> receiverUids;
  final String giftType;
  final int giftId;
  final int totalDiamonds;
  final int diamonds;
  final int vat;
  final String fullName;
  final String receiverFullName;
  final String? profileImage;
  final dynamic level;
  final String? giftImage;
  final String? gif;
  final String? audio;
  final dynamic vvipOrVipPreference;

  Map<String, dynamic> toJson() {
    return {
      'room_name': roomName,
      'sender_uid': senderUid,
      'receiver_uids': receiverUids,
      'gift_type': giftType,
      'gift_id': giftId,
      'total_diamonds': totalDiamonds,
      'diamonds': diamonds,
      'vat': vat,
      'full_name': fullName,
      'receiver_full_name': receiverFullName,
      'profile_image': profileImage,
      'level': level,
      'gift_image': giftImage,
      'gif': gif,
      'audio': audio,
      'vvip_or_vip_preference': vvipOrVipPreference,
    };
  }
}
