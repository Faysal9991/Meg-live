import 'package:doyel_live/app/modules/live_streaming/models/live_streaming_gift_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('LiveStreamingGiftRequest keeps nullable media fields as null', () {
    const request = LiveStreamingGiftRequest(
      roomName: '565',
      senderUid: 111,
      receiverUids: [222, 333],
      giftType: 'normal',
      giftId: 1,
      totalDiamonds: 1000,
      diamonds: 1000,
      vat: 20,
      fullName: 'Sender',
      receiverFullName: 'Receiver',
      profileImage: null,
      level: null,
      giftImage: null,
      svga: null,
      gif: null,
      audio: null,
      vvipOrVipPreference: null,
    );

    final json = request.toJson();

    expect(json['profile_image'], isNull);
    expect(json['gift_image'], isNull);
    expect(json['svga'], isNull);
    expect(json['gif'], isNull);
    expect(json['audio'], isNull);
  });
}
