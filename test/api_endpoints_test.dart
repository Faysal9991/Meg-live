import 'package:doyel_live/app/utils/api_endpoints.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('VIP and VVIP purchase URLs use the products API', () {
    expect(
      kVipPackagePurchaseUrl,
      'http://169.58.127.58:8085/api/v1/products/vip-package-purchase/',
    );
    expect(
      kVvipPackagePurchaseUrl,
      'http://169.58.127.58:8085/api/v1/products/vvip-package-purchase/',
    );
  });

  test('entry effect URLs use the products API', () {
    expect(
      kPurchasedEntryEffectPackageListUrl,
      'http://169.58.127.58:8085/api/v1/products/purchased-entry-effect-package-list/',
    );
    expect(
      kPurchasedEntryEffectPackageUrl,
      'http://169.58.127.58:8085/api/v1/products/purchased-entry-effect-package/',
    );
  });

  test('live streaming websocket URL reuses the current server port', () {
    final url = kWebSocketLivekitStreamingUrl(
      roomName: 'livekit_streamings',
      userId: 42,
      uniqueDeviceId: 'device-id',
      deviceName: 'Test Phone',
    );

    final uri = Uri.parse(url);
    expect(uri.scheme, 'ws');
    expect(uri.host, '169.58.127.58');
    expect(uri.port, 8085);
    expect(
      uri.path,
      '/ws/livekit-streaming/livekit_streamings/device-id/Test%20Phone/',
    );
    expect(uri.query, '42');
    expect(url, isNot(contains('8085:8001')));
  });

  test('chat websocket URL reuses the current server port', () {
    final url = kWebSocketChatRoomUrl(roomName: 'room-1');

    final uri = Uri.parse(url);
    expect(uri.scheme, 'ws');
    expect(uri.host, '169.58.127.58');
    expect(uri.port, 8085);
    expect(uri.path, '/ws/chat-room/room-1/');
    expect(url, isNot(contains('8085:8001')));
  });
}
