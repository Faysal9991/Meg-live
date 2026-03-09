import 'package:doyel_live/app/utils/constants.dart';

// Real Device
// const host = '192.168.0.205:8000';
// Android Emulator
// const host = '10.0.2.2:8000';

// Recent
const host = 'doyellive.skyapp.name';
// const kDomain = 'http://$host';
const kDomain = 'https://$host';
const _baseUrl = '$kDomain/api/v1';

const baseUrlAppLink = 'https://applink.doyellivekit.skyapp.name';
//Auth
const kLoginUsingFirebaseUrl = '$_baseUrl/auth/login/';
const kLogoutUrl = '$_baseUrl/auth/logout/';
const kChangePasswordUpdateUrl = '$_baseUrl/auth/change-password-update/';

// Contribution
 const kTopContributorRankingListUrl =
   '$_baseUrl/balance/top-contributor-ranking-list/';

String kContributionRankingListUrl(int userId) =>
    '$_baseUrl/balance/contribution-ranking-list/$userId/';
    
String kContributionHistoryDeleteUrl =
    '$_baseUrl/balance/contribution-history-delete/';
const kWithdrawRequestListUrl = '$_baseUrl/balance/withdraw-request-list/';
const kWithdrawRequestCreateUrl = '$_baseUrl/balance/withdraw-request-create/';
const kWithdrawPackageListUrl = '$_baseUrl/balance/withdraw-package-list/';
const kPaymentMethodListUrl = '$_baseUrl/balance/payment-method-list/';
// String kContributionByContributorIdRetrieveUrl(int channelId) =>
//     '$_baseUrl/balance/contribution-by-contributor-id-retrieve/$channelId/';

// Manual Agents
const kManualAgentListUrl = '$_baseUrl/business/manual-agent-list/';
const kAgentListUrl = '$_baseUrl/business/agent-list/';
const kBannerListUrl = '$_baseUrl/business/banner-list/';

// Host Request
const kHostRequestCreateUrl = '$_baseUrl/business/host-request-create/';
const kHostRequestRetrieveUrl = '$_baseUrl/business/host-request-retrieve/';
String kSearchHostRequestRetrieveUrl(int userId) =>
    '$_baseUrl/business/search-host-request-retrieve/$userId/';
const kHostRequestListUrl = '$_baseUrl/business/host-request-list/';
const kHostListeUrl = '$_baseUrl/business/host-list/';
const kConfirmHostRequestCreateUrl =
    '$_baseUrl/business/confirm-host-request-create/';
const kHostRemoveUrl = '$_baseUrl/business/host-remove/';
const kHostRequestDeleteUrl = '$_baseUrl/business/host-request-delete/';
const kAgentForHostRetrieveUrl = '$_baseUrl/business/agent-for-host-retrieve/';
String kSearchAgentRetrieveUrl(int userId) =>
    '$_baseUrl/business/search-agent-retrieve/$userId/';

// Moderator
const kModeratorRequestCreateUrl =
    '$_baseUrl/business/moderator-request-create/';
const kModeratorRequestRetrieveUrl =
    '$_baseUrl/business/moderator-request-retrieve/';
const kModeratorRequestDeleteUrl =
    '$_baseUrl/business/moderator-request-delete/';

// Reseller
const kResellerRequestCreateUrl = '$_baseUrl/business/reseller-request-create/';
const kResellerRequestRetrieveUrl =
    '$_baseUrl/business/reseller-request-retrieve/';
const kResellerRequestDeleteUrl = '$_baseUrl/business/reseller-request-delete/';
const kResellerRechargeCreateUrl =
    '$_baseUrl/business/reseller-recharge-create/';
const kResellerRechargeHistoryListUrl =
    '$_baseUrl/business/reseller-recharge-history-list/';
const kResellerRechargeHistoryDeletetUrl =
    '$_baseUrl/business/reseller-recharge-history-delete/';

// Profile
String kProfileUpdateUrl = '$_baseUrl/profiles/self-profile-update/';
String kProfileRetrieveUrl(int userId) =>
    '$_baseUrl/profiles/profile-retrieve/$userId/';
String kProfileForUserInfoRetrieveUrl(int userId) =>
    '$_baseUrl/profiles/profile-for-user-info-retrieve/$userId/';
const kTopHostListUrl = '$_baseUrl/profiles/top-host-list/';
String kFollowerListUrl = '$_baseUrl/profiles/follower-list/';
// # Perform both add and remove
String kFollowerCreateUrl(int uid) =>
    '$_baseUrl/profiles/follower-create/$uid/';
String kBlockListUrl = '$_baseUrl/profiles/block-list/';
// # Perform both add and remove
String kBlockCreateUrl(int uid) => '$_baseUrl/profiles/block-create/$uid/';
// Broadcasting histories
const kBroadcastingHistoryListUrl =
    '$_baseUrl/profiles/broadcasting-history-list/';
String kBroadcastingHistoryAgentViewListUrl({userId}) =>
    '$_baseUrl/profiles/broadcasting-history-list-agent-view/$userId/';

// Livekit Stuffs
// const kLiveKitMoonLiveTokenCreateUrl =
//     '$_baseUrl/livekit-stuffs/livekit-doyel-live-token-v3-create/';
// String kLiveKitRoomDeleteUrl({channelName}) =>
//     '$_baseUrl/livekit-stuffs/room-delete/$channelName/';
String kLiveKitParicipantListUrl({channelName}) =>
    '$_baseUrl/livekit-stuffs/participant-v2-list/$channelName/';
// String kGroupCallerListUrl({channelName}) =>
//     '$_baseUrl/livekit-stuffs/group-caller-list/$channelName/';

// Live Room Stuffs (Live Streaming)
// const kLiveKitEngineStatusCreateUrl =
//     '$_baseUrl/livekit-stuffs/engine-status-create/';
const kLiveKitEngineCheckAndTokenCreateUrl =
    '$_baseUrl/livekit-stuffs/engine-check-and-token-create/';
const kLiveRoomListUrl = '$_baseUrl/livekit-stuffs/live-room-list/';
const kLiveRoomUpdateUrl = '$_baseUrl/livekit-stuffs/live-room-update/';
String kFollowingLiveRoomIdListUrl({userId}) =>
    '$_baseUrl/livekit-stuffs/following-live-room-id-list/$userId/';
String kGroupCallerCreateUrl({channelId}) =>
    '$_baseUrl/livekit-stuffs/group-caller-create/$channelId/';

// Messenger: Chats
String kLastChatMessageListUrl({required int userId}) =>
    '$_baseUrl/messenger/last-chat-message-list/$userId/';
String kChatMessageListUrl({required String chatId}) =>
    '$_baseUrl/messenger/chat-message-list/$chatId/';
const kChatMessageCreateUrl = '$_baseUrl/messenger/chat-message-create/';
const kChatMessageDeleteUrl = '$_baseUrl/messenger/chat-message-delete/';
String kChatBlockListUrl({required int userId}) =>
    '$_baseUrl/messenger/chat-block-list/$userId/';
const kChatBlockUpdateUrl = '$_baseUrl/messenger/chat-block-update/';

//FCM stuffs
const kFCMDeviceCreateUrl = '$_baseUrl/fcm/device-create/';
const kFCMUserTokenUpdateUrl = '$_baseUrl/fcm/token-update/';
const kFCMSinglePushCreate = '$_baseUrl/fcm/single-push-create/';

// Live Streaming
const kLiveStreamingGiftCreateUrl =
    '$_baseUrl/live-streamings/live-streaming-gift-v3-create/';
// Notify followers with FCM
const kLiveStreamingNotifyFollowersCreateUrl =
    '$_baseUrl/live-streamings/notify-followers-create/';

// VVIP
const kPurchasedVvIPPackageListUrl =
    '$_baseUrl/products/purchased-vvip-package-list/';
// VIP
const kPurchasedVIPPackageListUrl =
    '$_baseUrl/products/purchased-vip-package-list/';
const kPurchasedKingPackageListUrl =
    '$_baseUrl/products/purchased-king-package-list/';

// Gift stuffs
const kGiftListUrl = '$_baseUrl/products/gift-list/';
// Devices
const kUserDeviceInfoUpdateUrl = '$_baseUrl/devices/user-device-info-update/';
String kSearchUserDeviceInfoListUrl({required int userId}) =>
    '$_baseUrl/devices/search-user-device-info-list/$userId/';
const kUserDeviceBlockCreateUrl = '$_baseUrl/devices/user-device-block-create/';
const kUserDeviceBlockedHistoryListUrl =
    '$_baseUrl/devices/user-device-blocked-history-list/';
// Tracking
const kAppLockRetrieveUrl = '$_baseUrl/tracking/applock-retrieve/';
// // Websocket
// String kWebSocketLiveStreamingUrl(roomName) {
//   // 192.168.202.47:8000 (_domainName for example)
//   // http
//   // return 'ws://$host/ws/live-streaming/$roomName/';
//   // https
//   return 'wss://$host:8001/ws/live-streaming/$roomName/';
// }

// Websocket
String kWebSocketLivekitStreamingUrl({
  required dynamic roomName,
  required int userId,
  required String uniqueDeviceId,
  required String deviceName,
}) {
  deviceName = refineDeviceName(deviceName: deviceName);
  // 192.168.202.47:8000 (_domainName for example)
  // http
  // return 'ws://$host/ws/livekit-streaming/$roomName/$uniqueDeviceId/$deviceName/?$userId';
  // https
  return 'wss://$host:8001/ws/livekit-streaming/$roomName/$uniqueDeviceId/$deviceName/?$userId';
}

// // Live Room
// String kWebSocketLivekitLiveRoomUrl({
//   required dynamic roomName,
// }) {
//   // 192.168.202.47:8000 (_domainName for example)
//   // http
//   // return 'ws://$host/ws/livekit-live-room/$roomName/';
//   // https
//   // return 'wss://$host:8001/ws/livekit-live-room/$roomName/';
//   return 'ws://195.26.253.191/ws/livekit-live-room/$roomName/';
// }

// Chat Room
String kWebSocketChatRoomUrl({required dynamic roomName}) {
  // 192.168.202.47:8000 (_domainName for example)
  // http
  // return 'ws://$host/ws/chat-room/$roomName/';
  // https
  return 'wss://$host:8001/ws/chat-room/$roomName/';
}

// Ref: https://docs.flutter.dev/deployment/android
// /home/than/FlutterProjects/PlayStoreKeystore/doyel_live/doyel_live_keystore.jks
// flutter build appbundle --obfuscate --split-debug-info=/home/than/FlutterProjects/Mamun/doyel_live/debug
// java -jar bundletool.jar build-apks --mode=universal --bundle="app-release.aab" --output="my_app.apks"
