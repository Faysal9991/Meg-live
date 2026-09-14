import 'package:doyel_live/app/utils/api_endpoints.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('top contributor URL uses the profiles API', () {
    expect(
      kTopContributorListUrl,
      '$kDomain/api/v1/profiles/top-contributor-list/',
    );
  });

  test('VIP and VVIP purchase URLs use the products API', () {
    expect(
      kVipPackagePurchaseUrl,
      '$kDomain/api/v1/products/vip-package-purchase/',
    );
    expect(
      kVvipPackagePurchaseUrl,
      '$kDomain/api/v1/products/vvip-package-purchase/',
    );
  });

  test('entry effect URLs use the products API', () {
    expect(
      kPurchasedEntryEffectPackageListUrl,
      '$kDomain/api/v1/products/purchased-entry-effect-package-list/',
    );
    expect(
      kPurchasedEntryEffectPackageUrl,
      '$kDomain/api/v1/products/purchased-entry-effect-package/',
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
    final server = Uri.parse(kDomain);
    expect(uri.scheme, server.scheme == 'https' ? 'wss' : 'ws');
    expect(uri.host, server.host);
    expect(uri.hasPort, server.hasPort);
    expect(
      uri.path,
      '/ws/livekit-streaming/livekit_streamings/device-id/Test%20Phone/',
    );
    expect(uri.query, '42');
    expect(uri.authority, server.authority);
  });

  test('chat websocket URL reuses the current server port', () {
    final url = kWebSocketChatRoomUrl(roomName: 'room-1');

    final uri = Uri.parse(url);
    final server = Uri.parse(kDomain);
    expect(uri.scheme, server.scheme == 'https' ? 'wss' : 'ws');
    expect(uri.host, server.host);
    expect(uri.hasPort, server.hasPort);
    expect(uri.path, '/ws/chat-room/room-1/');
    expect(uri.authority, server.authority);
  });
}
