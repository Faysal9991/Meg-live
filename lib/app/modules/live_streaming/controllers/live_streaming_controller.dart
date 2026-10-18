import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:doyel_live/app/modules/live_streaming/services/live_room_session.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:audioplayers/audioplayers.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:doyel_live/app/data/profile_model.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/models/home_banner.dart';
import 'package:doyel_live/app/modules/live_streaming/models/live_room_update_models.dart';
import 'package:doyel_live/app/modules/live_streaming/models/live_streaming_gift_request.dart';
import 'package:doyel_live/app/modules/live_streaming/models/top_host.dart';
import 'package:doyel_live/app/modules/live_streaming/views/livekit/widgets/participant_info.dart';
import 'package:doyel_live/app/modules/messenger/controllers/messenger_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/utlls/live_room_update_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:livekit_client/livekit_client.dart';
import 'package:doyel_live/app/routes/app_pages.dart';
import 'package:doyel_live/app/utils/api_client.dart';
import 'package:doyel_live/app/utils/api_endpoints.dart';
import 'package:doyel_live/app/utils/constants.dart';
import 'package:doyel_live/app/utils/drf_api_key.dart';
import 'package:doyel_live/app/widgets/reusable_widgets.dart';
import 'package:doyel_live/app/widgets/animated_media_widget.dart';
// import 'package:web_socket_channel/io.dart';
// import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_client/web_socket_client.dart';

enum HomeTabEnum {
  NEW_USERS,
  ALL_LIVES,
  FOLLOWING,
  PK_LIVES,
  GAMES,
  AUDIO_LIVES,
  VIDEO_LIVES,
}

class LiveStreamingController extends GetxController {
  LiveStreamingController({Dio? dio})
    : _dio = dio == null ? createApiDio() : configureApiDio(dio);

  final AuthController _authController = Get.find();
  final Dio _dio;
  final liveSession = LiveRoomSession();
  final roomAdminIds = <int>{}.obs;
  Future<bool> Function(int uid, bool enabled)? updateRoomAdmin;
  // Set by the open live room; runs the confirm + transfer + leave flow.
  void Function(int uid, String? fullName)? requestHostTransfer;

  bool get isRoomAdmin =>
      roomAdminIds.contains(_authController.profile.value.user?.uid);

  bool applyRoomAdmins({
    required String? senderIdentity,
    required dynamic ids,
  }) {
    if (senderIdentity != currentHostId.value.toString() || ids is! List) {
      return false;
    }
    final parsed = ids.map((id) => int.tryParse(id.toString())).toList();
    if (parsed.any((id) => id == null || id <= 0)) return false;
    roomAdminIds.assignAll(parsed.cast<int>());
    return true;
  }

  // final loadingCommentSend = false.obs;
  final loadingLiveRoomList = false.obs;
  final loadingGfitList = false.obs;
  final loadingGiftSend = (-1).obs;
  final loadingParticipantList = false.obs;
  final loadingContributionRankingList = false.obs;
  final loadingBannerList = false.obs;
  final loadingTopHostList = false.obs;
  final loadingTopContributorList = false.obs;

  final countryName = ''.obs;
  final phoneCode = ''.obs;
  final RxList<HomeBanner> bannerList = <HomeBanner>[].obs;
  final RxList<TopHost> topHostList = <TopHost>[].obs;
  final RxList<TopHost> topContributorList = <TopHost>[].obs;
  final RxList<dynamic> listNormalGift = <dynamic>[].obs;
  final RxList<dynamic> listAnimatedGift = <dynamic>[].obs;

  final userInteractTab = 'gifts'.obs;
  final showViewersTab = false.obs;
  final callTabName = 'views'.obs;
  final showCommentField = false.obs;
  final muted = false.obs, videoDisabled = false.obs, needsScroll = true.obs;
  // Speaker is a fallback; connected headsets always take priority.
  final loudSpeaker = true.obs;
  final isBroadcaster = false.obs,
      allowVideoCall = false.obs,
      allowCommentAndEmojiSend = true.obs,
      pkState = false.obs,
      busyConnectingEngine = true.obs;

  final callType = ''.obs;
  final RxList<dynamic> listRequestedCall = <dynamic>[].obs;
  final RxList<dynamic> listActiveCall = <dynamic>[].obs;
  Timer? _animatedGiftLoadTimer,
      _timerShowingMarqueeText,
      _timerTopContributorList,
      _liveRoomListRefreshTimer;

  final showUserJoinedAnimation = false.obs,
      showGiftSendAnimation = false.obs,
      expandMediaController = false.obs;
  // Gift stuffs
  final RxList<dynamic> listNormalGiftSend = <dynamic>[].obs;
  final RxList<dynamic> listAnimatedGiftSend = <dynamic>[].obs;
  final animatedGiftPlaybackId = 0.obs;
  dynamic _activeAnimatedGift;
  bool _animatedGiftStarted = false;
  bool _animatedGiftFinishing = false;
  AudioPlayer? _animatedGiftAudioPlayer;
  final RxList<dynamic> listLiveHeadlines = <dynamic>[].obs;

  final liveRunningDuration = '00:00:00'.obs;
  // Live Broadcast Stuffs
  final channelName = '0'.obs;

  /// User ID of the live's current host. [channelName] stays the room ID after
  /// a host handover, so host controls and host-targeted actions (profile,
  /// follow, gifts) must use this instead.
  final currentHostId = 0.obs;
  final transferringHost = false.obs;
  // Bumped on every authoritative host change so slower, older room snapshots
  // (list polls, isolate results) cannot roll the host back.
  int _hostEpoch = 0;
  // Dashboard rooms removed by `delete_live`, keyed by channel ID, so an
  // in-flight list snapshot taken before the removal cannot restore the card.
  final Map<String, int> _deletedLiveRoomSeq = <String, int>{};
  int _liveRoomDeleteSeq = 0;

  int get myUid => _authController.profile.value.user?.uid ?? 0;
  bool get isCurrentHost =>
      currentHostId.value > 0 && currentHostId.value == myUid;
  final broadcastingTitle = ''.obs;
  final broadcasterFullname = ''.obs;
  final broadcasterProfileImage = ''.obs;
  final marqueeText = ''.obs;
  dynamic level;
  String videoDimensionsDescription = 'HD(1280x720)';

  // User Joined
  final RxList<dynamic> listUserJoinedAnimation = <dynamic>[].obs;
  final RxList<dynamic> listCommentLiveStream = <dynamic>[].obs;

  final RxList<dynamic> activeGroupCalls = <dynamic>[].obs;
  final RxList<dynamic> viewers = <dynamic>[].obs;
  final RxList<dynamic> viewersTemp = <dynamic>[].obs;

  final RxList<dynamic> followers = <dynamic>[].obs;
  final RxList<dynamic> blocks = <dynamic>[].obs;
  final List<dynamic> contributionRankingList = [];
  final RxList<dynamic> topSlidingAgentRankingList = [].obs;

  final RxInt viewersCount = 0.obs;
  final broadcasterDiamonds = 0.obs;
  final loveReacts = 0.obs;
  final isFromSharedLink = false.obs;
  bool _isDisposed = false, _fromLiveRoom = false;

  // Live Streaming Stuffs
  // IOWebSocketChannel? webSocketChannelForStreaming;
  // IOWebSocketChannel? webSocketChannelForGaming;

  WebSocket? webSocketClientForStreaming;
  final isStreamingWebSocketConnected = false.obs;
  final webSocketConnectionState = "".obs;
  final RxList<dynamic> listLiveStreams = <dynamic>[].obs;
  final List<dynamic> listLiveRoom = <dynamic>[];

  final RxList<dynamic> listFilterLiveStreams = <dynamic>[].obs;
  final RxList<ParticipantTrack> listRenderView = <ParticipantTrack>[].obs;
  final liveStreamData = {}.obs;

  String liveRoomSocketBaseUrl = '';

  Rx<CameraPosition> cameraPosition = CameraPosition.front.obs;

  final loadingRoom = 0.obs;
  int topContributorsIntervalMinutes = -1;
  Timer? _liveRoomHeartbeatTimer;
  bool _heartbeatInFlight = false;

  final selectedGift = {
    'gift_type': '',
    'id': 0,
    'diamonds': 0,
    'vat': 0,
    'gift_image': null,
    'svga': null,
    'gif': null,
    'audio': null,
  }.obs;

  Rx<HomeTabEnum> selectedHomeTabEnum = HomeTabEnum.ALL_LIVES.obs;
  final MessengerController _messengerController =
      Get.isRegistered<MessengerController>()
      ? Get.find<MessengerController>()
      : Get.put(MessengerController());

  void setHomeTabEnumSelection({required HomeTabEnum homeTabEnum}) {
    selectedHomeTabEnum.value = homeTabEnum;
  }

  void setCountryName(String name) {
    countryName.value = name;
  }

  void setPhoneCode(String code) {
    phoneCode.value = code;
  }

  void setSelectedGift({
    giftType,
    id,
    diamonds,
    vat,
    String? giftImage,
    String? svga,
    String? gif,
    String? audio,
  }) {
    selectedGift.value = {
      'gift_type': giftType,
      'id': id,
      'diamonds': diamonds ?? 0,
      'vat': vat ?? 0,
      'gift_image': giftImage,
      'svga': svga,
      'gif': gif,
      'audio': audio,
    };
  }

  void setLiveRunningDurationFormat(String durationFormat) {
    liveRunningDuration.value = durationFormat;
  }

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  initTopAgentRankingList() {
    _useIsolateToFetchTopRatedAgentList(0);
    _timerTopContributorList = Timer.periodic(const Duration(minutes: 10), (
      timer,
    ) {
      _useIsolateToFetchTopRatedAgentList(10);
    });
  }

  disposetopContributorRankingList() {
    if (_timerTopContributorList != null) {
      _timerTopContributorList?.cancel();
    }
  }

  @override
  void onClose() {
    webSocketClientForStreaming?.close();
    stopLiveRoomListAutoRefresh();
    stopLiveRoomHeartbeat();
    setClearAnimationStuffs();
    if (_timerShowingMarqueeText != null) {
      _timerShowingMarqueeText?.cancel();
    }
    _isDisposed = true;
    disposetopContributorRankingList();

    super.onClose();
  }

  Map<String, String> _publicHeaders() {
    return {
      'accept': '*/*',
      'Authorization': 'Token ${_authController.token.value}',
      'X-Api-Key': DRF_API_KEY,
    };
  }

  Map<String, String> _authHeaders() {
    return {
      'accept': '*/*',
      'Authorization': 'Token ${_authController.token.value}',
      'X-Api-Key': DRF_API_KEY,
    };
  }

  Future<LiveRoomUpdateResult> sendLiveRoomUpdate(
    LiveRoomUpdateRequest request,
  ) async {
    return sendLiveRoomUpdateRequest(
      dio: _dio,
      request: request,
      authToken: _authController.token.value,
    );
  }

  void setCurrentHost(int hostId) {
    if (hostId <= 0) return;
    currentHostId.value = hostId;
    isBroadcaster.value = hostId == myUid;
  }

  /// Applies a confirmed host change for the active room ([room] is the
  /// server's live-room object when available).
  void applyHostChange({
    required dynamic channelId,
    required int hostId,
    Map<String, dynamic>? room,
  }) {
    if (channelId?.toString() != channelName.value || hostId <= 0) return;
    _hostEpoch++;
    setCurrentHost(hostId);
    if (room != null && room['channel_id'] != null) {
      _useIsolateLoadLiveStreamingList(liveData: room);
    }
  }

  void _syncActiveRoomHost(dynamic room, {required int hostEpoch}) {
    if (hostEpoch != _hostEpoch || room is! Map) return;
    if (room['channel_id']?.toString() != channelName.value) return;
    final hostId = liveRoomHostId(room);
    if (hostId != null && hostId != currentHostId.value) {
      setCurrentHost(hostId);
    }
  }

  /// Hands the active live to [newHostId]. Resolves timeouts and 403s against
  /// the room list so the caller knows who is host before anyone disconnects.
  Future<LiveRoomTransferResult> transferLiveHost({
    required int newHostId,
  }) async {
    final channelId = int.tryParse(channelName.value) ?? 0;
    if (transferringHost.value) {
      return const LiveRoomTransferResult(
        status: LiveRoomTransferStatus.failed,
        detail: 'A host transfer is already in progress.',
      );
    }
    transferringHost.value = true;
    try {
      var result = await sendLiveRoomTransferHostRequest(
        dio: _dio,
        channelId: channelId,
        newHostId: newHostId,
        authToken: _authController.token.value,
      );
      if (result.isSuccess) {
        applyHostChange(
          channelId: channelId,
          hostId: liveRoomHostId(result.room) ?? newHostId,
          room: result.room,
        );
        return result;
      }
      if (result.status == LiveRoomTransferStatus.uncertain ||
          result.status == LiveRoomTransferStatus.notCurrentHost ||
          result.status == LiveRoomTransferStatus.notFound) {
        final refreshed = await refreshActiveLiveRoom();
        final hostId = liveRoomHostId(refreshed.room);
        if (hostId != null) {
          applyHostChange(
            channelId: channelId,
            hostId: hostId,
            room: refreshed.room,
          );
        }
        if (result.status == LiveRoomTransferStatus.uncertain &&
            hostId == newHostId) {
          result = LiveRoomTransferResult(
            status: LiveRoomTransferStatus.success,
            room: refreshed.room,
          );
        } else if (result.status == LiveRoomTransferStatus.uncertain &&
            refreshed.ok) {
          result = const LiveRoomTransferResult(
            status: LiveRoomTransferStatus.failed,
            detail: 'The transfer was not completed. You are still the host.',
          );
        }
      }
      return result;
    } finally {
      transferringHost.value = false;
    }
  }

  /// The live started on [channelId] when it is now hosted by someone else.
  Map<String, dynamic>? handedOverLiveRoom(int channelId) {
    final room = listLiveRoom.firstWhereOrNull(
      (room) => _liveRoomId(room) == channelId.toString(),
    );
    final hostId = liveRoomHostId(room);
    if (room is! Map || hostId == null || hostId == channelId) return null;
    return Map<String, dynamic>.from(room);
  }

  /// Fetches a fresh room list and returns the active room. `ok` is false when
  /// the list could not be fetched; `room` is null when the live has ended.
  Future<({bool ok, Map<String, dynamic>? room})>
  refreshActiveLiveRoom() async {
    final rooms = await _fetchAndApplyLiveRoomList();
    if (rooms == null) return (ok: false, room: null);
    final room = rooms.firstWhereOrNull(
      (room) => _liveRoomId(room) == channelName.value,
    );
    return (
      ok: true,
      room: room is Map ? Map<String, dynamic>.from(room) : null,
    );
  }

  void startLiveRoomHeartbeat({
    required int channelId,
    required Future<void> Function() onRoomMissing,
  }) {
    stopLiveRoomHeartbeat();
    _sendHeartbeat(channelId: channelId, onRoomMissing: onRoomMissing);
    _liveRoomHeartbeatTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _sendHeartbeat(channelId: channelId, onRoomMissing: onRoomMissing),
    );
  }

  void stopLiveRoomHeartbeat() {
    _liveRoomHeartbeatTimer?.cancel();
    _liveRoomHeartbeatTimer = null;
    _heartbeatInFlight = false;
  }

  Future<void> _sendHeartbeat({
    required int channelId,
    required Future<void> Function() onRoomMissing,
  }) async {
    if (_heartbeatInFlight) {
      return;
    }
    _heartbeatInFlight = true;
    try {
      final request = LiveRoomUpdateRequest.heartbeat(channelId: channelId);
      final firstAttempt = await sendLiveRoomUpdate(request);
      if (firstAttempt.isNotFound) {
        final secondAttempt = await sendLiveRoomUpdate(request);
        if (secondAttempt.isNotFound) {
          stopLiveRoomHeartbeat();
          await onRoomMissing();
        }
      }
    } catch (_) {
      // Keep the heartbeat alive for transient failures.
    } finally {
      _heartbeatInFlight = false;
    }
  }

  dynamic getLiveData({required String channelId}) async {
    return listLiveRoom.firstWhereOrNull(
      (el) => el['channel_id'].toString() == channelId,
    );
  }

  void initWebSocketClient() async {
    // do nothing if already disposed
    if (_isDisposed) {
      return;
    }
    if (webSocketClientForStreaming != null &&
        webSocketConnectionState.value != 'disconnecting' &&
        webSocketConnectionState.value != 'disconnected') {
      // print('Returned............................................');
      return;
    }
    String uniqueDeviceId = '', deviceName = '';
    uniqueDeviceId = await _authController.getUniqueDeviceId();

    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      // const androidIdPlugin = AndroidId();
      // final String? androidId = await androidIdPlugin.getId();
      // uniqueDeviceId = androidId!;

      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      deviceName = androidInfo.model; // e.g. "Moto G (4)"
    } else if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      // uniqueDeviceId = iosDeviceInfo.identifierForVendor!;
      deviceName = iosDeviceInfo.utsname.machine; // e.g. "iPod7,1"
    }
    deviceName = deviceName.replaceAll(' ', '_');

    // Create a WebSocket client.
    final uri = Uri.parse(
      kWebSocketLivekitStreamingUrl(
        roomName: 'livekit_streamings',
        userId: _authController.profile.value.user!.uid!,
        uniqueDeviceId: uniqueDeviceId,
        deviceName: deviceName,
      ),
    );
    // const backoff = ConstantBackoff(Duration(seconds: 1));
    final backoff = LinearBackoff(
      initial: const Duration(seconds: 0),
      increment: const Duration(seconds: 1),
      maximum: const Duration(seconds: 5),
    );
    webSocketClientForStreaming = WebSocket(uri, backoff: backoff);

    // Listen for changes in the connection state.
    webSocketClientForStreaming!.connection.listen((state) {
      // do nothing if already disposed
      if (_isDisposed) {
        return;
      }
      if (state == const Connecting()) {
        // print('connecting: the connection has not yet been established.');
        webSocketConnectionState.value = 'connecting';
        // isStreamingWebSocketConnected.value = false;
      } else if (state == const Connected()) {
        // print(
        //     ' connected: the connection is established and communication is possible.');
        webSocketConnectionState.value = 'connected';

        isStreamingWebSocketConnected.value = true;
      } else if (state == const Reconnecting()) {
        // print(
        //     ' reconnecting: the connection was lost and is in the process of being re-established.');
        webSocketConnectionState.value = 'reconnecting';

        // isStreamingWebSocketConnected.value = false;
      } else if (state == const Reconnected()) {
        // print(
        //     'reconnected: the connection was lost and has been re-established.');
        webSocketConnectionState.value = 'reconnected';

        isStreamingWebSocketConnected.value = true;
        // Socket events are transient; drop cards ended while disconnected.
        tryToLoadLiveRoomList();
      } else if (state == const Disconnecting()) {
        // print(
        //     ' disconnecting: the connection is going through the closing handshake or the close method has been invoked.');
        try {
          webSocketConnectionState.value = 'disconnecting';

          // isStreamingWebSocketConnected.value = false;
        } catch (e) {
          //
        }
      } else if (state == const Disconnected()) {
        // print(
        //     ' disconnected: the WebSocket connection has been closed or could not be established.');
        try {
          webSocketConnectionState.value = 'disconnected';

          // isStreamingWebSocketConnected.value = false;
        } catch (e) {
          //
        }
      }
    });

    //     connecting: the connection has not yet been established.
    // connected: the connection is established and communication is possible.
    // reconnecting: the connection was lost and is in the process of being re-established.
    // reconnected: the connection was lost and has been re-established.
    // disconnecting: the connection is going through the closing handshake or the close method has been invoked.
    // disconnected: the WebSocket connection has been closed or could not be established.

    // Listen for incoming messages.
    webSocketClientForStreaming!.messages.listen((message) {
      // do nothing if already disposed
      if (_isDisposed) {
        return;
      }
      dynamic data = jsonDecode(message)['message'];

      _loadWebSocketData(data);

      // Send a message to the server.
      // socket.send('ping');
    });
  }

  _loadWebSocketData(dynamic data) {
    if (data != null) {
      if (data['type'] == 'device_block') {
        // {type: device_block, device_blocked: true, device_id: f2f072997d09396d, user_id: 1855, datetime: 2023-03-26 05:27:07.204844+00:00}
        String deviceId = data['device_id'];
        _authController.getUniqueDeviceId().then((deviceUniqueId) {
          if (deviceId == deviceUniqueId) {
            // Device is blocked
            _tryToDeviceBlock();
          }
        });
      } else if (data['type'] == CHECK_DEVICE_BLOCKED) {
        if (!isStreamingWebSocketConnected.value) {
          isStreamingWebSocketConnected.value = true;
        }
        // Check device blocked
        if (data['uid'] == _authController.profile.value.user!.uid!) {
          bool isDeviceBlocked = data['device_blocked'];
          if (isDeviceBlocked) {
            _tryToDeviceBlock();
          }
        }
      } else if (data['type'] == LOAD_GIFTS) {
        if (data['uid'] == _authController.profile.value.user!.uid! ||
            listNormalGift.isEmpty) {
          // isStreamingWebSocketConnected.value = true;
          // Loading gifts
          listNormalGift.clear();
          listAnimatedGift.clear();
          listNormalGift.addAll(data['normal_gifts']);
          listAnimatedGift.addAll(data['animated_gifts']);
        }
      } else if (data['type'] == LOAD_PROFILE) {
        // Loading Own Profile
        if (_authController.profile.value.user?.uid == data['user']['uid']) {
          _authController.profile.value = Profile();
          _authController.profile.value = Profile.fromJson(data);
          _authController.preferences.setString('profile', jsonEncode(data));
        }
      } else if (data['type'] == 'gift') {
        // Headlines for sending gift
        String headline =
            '${data['full_name']} sends ${data['diamonds']} diamonds to ${data['receiver_full_name']}';
        listLiveHeadlines.add(headline);
        setMarqueeText();
      }
      // ######################################
      // Live Room
      else if (data['type'] == STREAMING) {
        _useIsolateLoadLiveStreamingList(liveData: data);
      } else if (data['type'] == DELETE_LIVE) {
        _removeEndedLiveRoom(data['channel_id']);
      } else if (data['type'] == UPDATE_CAMERA_FILTER) {
        dynamic liveData = listLiveRoom.firstWhereOrNull(
          (element) => element['channel_id'] == data['channel_id'],
        );
        if (liveData != null) {
          liveData['cm_flt_nm'] = data['cm_flt_nm'];
          _useIsolateLoadLiveStreamingList(liveData: liveData);
        }
      } else if (data['type'] == UPDATE_LIVE_PAKCAGE_THEME) {
        dynamic liveData = listLiveRoom.firstWhereOrNull(
          (element) => element['channel_id'] == data['channel_id'],
        );
        if (liveData != null) {
          liveData['owner_profile']['theme_gif'] = data['theme_gif'];
          _useIsolateLoadLiveStreamingList(liveData: liveData);
        }
      } else if (data['type'] == ALLOW_COMMENT_EMOJI_SEND) {
        dynamic liveData = listLiveRoom.firstWhereOrNull(
          (element) => element['channel_id'] == data['channel_id'],
        );
        if (liveData != null) {
          liveData['allow_send'] = data['allow_send'];
          _useIsolateLoadLiveStreamingList(liveData: liveData);
        }
      } else if (data['type'] == UPDATE_LIVE_LOCK) {
        dynamic liveData = listLiveRoom.firstWhereOrNull(
          (element) => element['channel_id'] == data['channel_id'],
        );
        if (liveData != null) {
          liveData['is_locked'] = data['is_locked'];
          liveData['locked_datetime'] = data['locked_datetime'];
          _useIsolateLoadLiveStreamingList(liveData: liveData);
        }
      } else if (data['type'] == UPDATE_VIEWERS_COUNT) {
        dynamic liveData = listLiveRoom.firstWhereOrNull(
          (element) => element['channel_id'] == data['channel_id'],
        );
        if (liveData != null) {
          liveData['viewers_count'] = data['viewers_count'];
          _useIsolateLoadLiveStreamingList(liveData: liveData);
        }
      } else if (data['type'] == LIVE_ROOM_BLOCKS) {
        if (data['uid'] == _authController.profile.value.user!.uid!) {
          int channelId = data['channel_id'];
          listLiveRoom.removeWhere((el) => el['channel_id'] == channelId);
          listFilterLiveStreams.removeWhere(
            (el) => el['channel_id'] == channelId,
          );
        }
      }
      // ################################################
      // Messenger ####################
      else if (data['type'] == 'chat_text_message') {
        data['type'] = 'text';
        int uid = _authController.profile.value.user!.uid!;
        if (data['sender_id'] == uid) {
          data['full_name'] = data['receiver_full_name'];
          data['profile_image'] = data['receiver_image'];
          data['user_id'] = uid;
          _messengerController.listLastMessage.removeWhere(
            (element) => element['chat_id'] == data['chat_id'],
          );
          _messengerController.listLastMessage.insert(0, data);
        } else if (data['receiver_id'] == uid) {
          data['full_name'] = data['sender_full_name'];
          data['profile_image'] = data['sender_image'];
          data['user_id'] = uid;
          _messengerController.listLastMessage.removeWhere(
            (element) => element['chat_id'] == data['chat_id'],
          );
          _messengerController.listLastMessage.insert(0, data);
        }
      }
    }
  }

  void _removeEndedLiveRoom(dynamic channelId) {
    final roomId = channelId?.toString();
    if (roomId == null || roomId.isEmpty) return;
    _deletedLiveRoomSeq.remove(roomId);
    _deletedLiveRoomSeq[roomId] = ++_liveRoomDeleteSeq;
    if (_deletedLiveRoomSeq.length > 50) {
      _deletedLiveRoomSeq.remove(_deletedLiveRoomSeq.keys.first);
    }
    listLiveRoom.removeWhere((room) => _liveRoomId(room) == roomId);
    listFilterLiveStreams.removeWhere((room) => _liveRoomId(room) == roomId);
  }

  /// Drops rooms ended after a snapshot was taken at [snapshotDeleteSeq].
  List<dynamic> _withoutRoomsEndedSince(
    List<dynamic> rooms,
    int snapshotDeleteSeq,
  ) {
    if (_liveRoomDeleteSeq == snapshotDeleteSeq) return rooms;
    return rooms.where((room) {
      final deletedAt = _deletedLiveRoomSeq[_liveRoomId(room)];
      return deletedAt == null || deletedAt <= snapshotDeleteSeq;
    }).toList();
  }

  // void _loadLiveStreamingListFromFirebase() {
  //   _sortingLiveRooms();
  // }

  // void _sortingLiveRooms() {
  //   if (listFilterLiveStreams.length > 1) {
  //     try {
  //       listFilterLiveStreams.sort((a, b) =>
  //           DateTime.fromMillisecondsSinceEpoch(
  //                   a['creation_time'].millisecondsSinceEpoch)
  //               .toLocal()
  //               .compareTo(DateTime.fromMillisecondsSinceEpoch(
  //                       b['creation_time'].millisecondsSinceEpoch)
  //                   .toLocal()));
  //     } catch (e) {
  //       //
  //     }

  //     listFilterLiveStreams
  //         .sort((a, b) => (b['viewers_count']).compareTo((a['viewers_count'])));
  //   }
  // }

  onUpdateLiveStreamStatus(dynamic data) {
    // do nothing if already disposed
    if (_isDisposed) {
      return;
    }
    if (webSocketClientForStreaming != null) {
      final jsonEncodedData = jsonEncode({'message': data});

      try {
        webSocketClientForStreaming!.send(jsonEncodedData);
      } catch (e) {
        //
      }
    }

    // if (webSocketChannelForStreaming != null) {
    //   try {
    //     webSocketChannelForStreaming?.sink.add(jsonEncode({
    //       'message': data,
    //     }));
    //   } catch (e) {
    //     //
    //   }
    // }
  }

  void _tryToDeviceBlock() {
    // Device is blocked
    // _authController.preferences.setString('token', '');
    // _authController.preferences.setString('profile', '');
    _authController.preferences.clear();
    Get.offAllNamed(Routes.AUTH);
    _authController.token.value = '';
    listLiveStreams.clear();
    listFilterLiveStreams.clear();
    _authController.tryToSignOut();
  }

  void setUserInteractTab({tab = 'gifts'}) {
    userInteractTab.value = tab;
  }

  void setLoadingRoom({required int roomId}) {
    loadingRoom.value = roomId;
  }

  void setBroadcastStreamingStuffs({
    required String brdchannelName,
    required String? broadcasterName,
    required String? brdImage,
    required bool isBrdOwner,
    required List<dynamic> activeInCalls,
    required List<dynamic> brdViewers,
    required List<dynamic> brdFollowers,
    required List<dynamic> brdBlocks,
    required int brdDiamonds,
    required int brdLoveReacts,
    required dynamic brdLevel,
    bool fromLink = false,
    bool allowSend = true,
    int? hostId,
    // required Room room,
    // required EventsListener<RoomEvent> listener,
  }) {
    setClearStreamingRelatedFields();
    setClearAnimationStuffs();
    videoDimensionsDescription = 'HD(1280x720)';

    channelName.value = brdchannelName;
    broadcasterFullname.value = broadcasterName ?? '';
    broadcasterProfileImage.value = brdImage ?? '';
    setCurrentHost(
      isBrdOwner ? myUid : (hostId ?? int.tryParse(brdchannelName) ?? 0),
    );
    isBroadcaster.value = isBrdOwner || isCurrentHost;
    allowCommentAndEmojiSend.value = allowSend;
    followers.addAll(brdFollowers);
    blocks.addAll(brdBlocks);
    broadcasterDiamonds.value = brdDiamonds;
    isFromSharedLink.value = fromLink;
    loveReacts.value = brdLoveReacts;
    level = brdLevel;
    setMuted(false);

    if (!isBrdOwner) {
      try {
        liveStreamData.value = listFilterLiveStreams.firstWhereOrNull(
          (element) => element['channel_id'].toString() == brdchannelName,
        );
        _syncActiveRoomHost(liveStreamData, hostEpoch: _hostEpoch);
      } catch (e) {
        //
      }
    }
  }

  void setMarqueeText() async {
    if (listLiveHeadlines.isNotEmpty && _timerShowingMarqueeText == null) {
      final headline = listLiveHeadlines[0];
      Duration duration = const Duration(milliseconds: 2300);
      marqueeText.value = headline + "\t\t\t";

      _timerShowingMarqueeText = Timer(duration, () async {
        _timerShowingMarqueeText?.cancel();
        _timerShowingMarqueeText = null;
        marqueeText.value = '';

        listLiveHeadlines.removeAt(0);
        setMarqueeText();
      });
    }
  }

  void _useIsolateToFetchTopRatedAgentList(minutes) {
    if (topContributorsIntervalMinutes < 0) {
      topContributorsIntervalMinutes = 0;
      processOfGettingTopRatedAgentList();
    } else if (minutes == 10) {
      processOfGettingTopRatedAgentList();
    }
  }

  void processOfGettingTopRatedAgentList() async {
    var recievePort = ReceivePort(); //creating new port to listen data
    await Isolate.spawn(_fetchTopRatedAgentList, [
      recievePort.sendPort,
      _authController.token.value,
    ]); //spawing/creating new thread as isolates.
    recievePort.listen((data) {
      //listening data from isolate
      if (data != null) {
        topSlidingAgentRankingList.clear();
        topSlidingAgentRankingList.addAll(data['manual_agent_list']);
      }
    });
  }

  void showNextAnimatedGift() {
    if (_isDisposed || _activeAnimatedGift != null) return;
    while (listAnimatedGiftSend.isNotEmpty &&
        listAnimatedGiftSend.first is! Map) {
      listAnimatedGiftSend.removeAt(0);
    }
    if (listAnimatedGiftSend.isEmpty) return;

    final gift = listAnimatedGiftSend.first;
    _activeAnimatedGift = gift;
    _animatedGiftStarted = false;
    _animatedGiftFinishing = false;
    final playbackId = ++animatedGiftPlaybackId.value;
    showGiftSendAnimation.value = true;
    final source = AnimatedMediaSource.fromMap(gift);

    // A failed download must not block the queue. Cancel this loading deadline
    // when playback starts; the animation then controls its own lifetime.
    _animatedGiftLoadTimer = Timer(
      source.isPlayable
          ? const Duration(seconds: 30)
          : const Duration(seconds: 3),
      () => unawaited(finishAnimatedGift(playbackId)),
    );
    if (!source.isPlayable) unawaited(_playAnimatedGiftAudio(playbackId));
  }

  bool _isCurrentAnimatedGift(int playbackId) =>
      !_isDisposed &&
      _activeAnimatedGift != null &&
      animatedGiftPlaybackId.value == playbackId;

  void onAnimatedGiftPlaybackStarted(int playbackId) {
    if (!_isCurrentAnimatedGift(playbackId) ||
        _animatedGiftFinishing ||
        _animatedGiftStarted) {
      return;
    }
    _animatedGiftStarted = true;
    _animatedGiftLoadTimer?.cancel();
    _animatedGiftLoadTimer = null;
    unawaited(_playAnimatedGiftAudio(playbackId));
  }

  Future<void> _playAnimatedGiftAudio(int playbackId) async {
    if (!_isCurrentAnimatedGift(playbackId) || _animatedGiftFinishing) return;
    final audioUrl = _activeAnimatedGift['audio']?.toString().trim();
    if (audioUrl == null || audioUrl.isEmpty) return;
    final player = AudioPlayer(
      playerId:
          'sent-gift-$playbackId-${DateTime.now().microsecondsSinceEpoch}',
    );
    _animatedGiftAudioPlayer = player;
    try {
      await player.play(UrlSource(audioUrl), volume: .4);
    } catch (_) {
      if (identical(_animatedGiftAudioPlayer, player)) {
        await _disposeAnimatedGiftAudio();
      }
    }
  }

  Future<void> finishAnimatedGift(int playbackId) async {
    if (!_isCurrentAnimatedGift(playbackId) || _animatedGiftFinishing) return;
    _animatedGiftFinishing = true;
    showGiftSendAnimation.value = false;
    _animatedGiftLoadTimer?.cancel();
    _animatedGiftLoadTimer = null;
    await _disposeAnimatedGiftAudio();
    // Room cleanup or a newer playback can invalidate an asynchronous callback.
    if (!_isCurrentAnimatedGift(playbackId)) return;
    if (listAnimatedGiftSend.isNotEmpty &&
        identical(listAnimatedGiftSend.first, _activeAnimatedGift)) {
      listAnimatedGiftSend.removeAt(0);
    }
    _activeAnimatedGift = null;
    _animatedGiftFinishing = false;
    showNextAnimatedGift();
  }

  Future<void> _disposeAnimatedGiftAudio() async {
    final player = _animatedGiftAudioPlayer;
    _animatedGiftAudioPlayer = null;
    if (player == null) return;
    try {
      await player.stop();
    } catch (_) {
      // Continue disposal if the platform has already stopped the sound.
    }
    try {
      await player.dispose();
    } catch (_) {
      // The platform may already have released this player during room cleanup.
    }
  }

  void removeExpiredNormalGiftShow() {
    if (listNormalGiftSend.isNotEmpty) {
      listNormalGiftSend.removeWhere(
        (element) =>
            (DateTime.parse(element['datetime']).toLocal().add(
              const Duration(milliseconds: 1300),
            )).compareTo(DateTime.now()) <=
            0,
      );
    }
  }

  void removeExpiredJoinedAnimationShow() {
    if (listUserJoinedAnimation.isNotEmpty) {
      listUserJoinedAnimation.removeWhere(
        (element) =>
            (DateTime.parse(element['datetime']).toLocal().add(
              const Duration(milliseconds: 2000),
            )).compareTo(DateTime.now()) <=
            0,
      );
    }
  }

  void setClearStreamingRelatedFields() {
    roomAdminIds.clear();
    updateRoomAdmin = null;
    liveStreamData.value = {};
    channelName.value = '';
    currentHostId.value = 0;
    transferringHost.value = false;
    broadcasterFullname.value = '';
    broadcasterProfileImage.value = '';
    liveRunningDuration.value = '00:00:00';
    muted.value = false;
    videoDisabled.value = false;
    loudSpeaker.value = true;
    isBroadcaster.value = false;
    allowVideoCall.value = false;
    pkState.value = false;
    busyConnectingEngine.value = true;
    needsScroll.value = true;
    expandMediaController.value = false;
    viewersCount.value = 0;
    loveReacts.value = 0;
    activeGroupCalls.clear();
    listRequestedCall.clear();
    listActiveCall.clear();
    blocks.clear();
    viewers.clear();
    viewersTemp.clear();
    followers.clear();
    listRenderView.clear();
    // clear users
    listCommentLiveStream.clear();
  }

  void setClearAnimationStuffs() {
    _animatedGiftLoadTimer?.cancel();
    _animatedGiftLoadTimer = null;
    _activeAnimatedGift = null;
    _animatedGiftStarted = false;
    _animatedGiftFinishing = false;
    animatedGiftPlaybackId.value++;
    showGiftSendAnimation.value = false;
    unawaited(_disposeAnimatedGiftAudio());
    listNormalGiftSend.clear();
    listAnimatedGiftSend.clear();
  }

  void setChannelName(String name) {
    channelName.value = name;
  }

  void setMuted(bool isMuted) {
    muted.value = isMuted;
  }

  void setVideoDisabled(bool isVideoDisabled) {
    videoDisabled.value = isVideoDisabled;
  }

  void setLoudSpeaker(bool isLoudSpeaker) {
    loudSpeaker.value = isLoudSpeaker;
  }

  void setIsBroadCaster(bool broadcaster) {
    isBroadcaster.value = broadcaster;
  }

  void setAllowVideoCall(bool isAllowVideoCall) {
    allowVideoCall.value = isAllowVideoCall;
  }

  void setToggleMute() {
    muted.value = !muted.value;
  }

  void setToggleVideoEnabled() {
    videoDisabled.value = !videoDisabled.value;
  }

  void setSwitchCameraPosition() {
    cameraPosition.value = cameraPosition.value.switched();
  }

  void setRequestedCalls(List<dynamic> requestedCalls) {
    listRequestedCall.clear();
    listRequestedCall.addAll(requestedCalls);
  }

  void setActiveCalls(List<dynamic> activeCalls) {
    listActiveCall.clear();
    listActiveCall.addAll(activeCalls);
  }

  void setRenderViewList(List<ParticipantTrack> views) {
    listRenderView.clear();
    listRenderView.addAll(views);
  }

  void setViewList(List<dynamic> listViewer) {
    viewers.clear();
    viewers.addAll(listViewer);
  }

  void setFollowerList(List<dynamic> listFollower) {
    followers.clear();
    followers.addAll(listFollower);
  }

  void setBlockList(List<dynamic> listBlock) {
    blocks.clear();
    blocks.addAll(listBlock);
  }

  setShowCommentField({required bool show}) {
    showCommentField.value = show;
  }

  setShowViewersTab({required bool showViewers}) {
    showViewersTab.value = showViewers;
  }

  setCallTab({required String tabName}) {
    callTabName.value = tabName;
  }

  Future<dynamic> createLiveKitToken({required String channelName}) async {
    dynamic data = {
      'channel_name': channelName,
      'identity': _authController.profile.value.user!.uid!.toString(),
      'full_name': _authController.profile.value.full_name,
      // A handed-over live keeps the creator's channel ID; only its current
      // host may join as owner. Replacement hosts join as participants.
      'is_owner':
          channelName == _authController.profile.value.user!.uid!.toString() &&
          (currentHostId.value <= 0 || isCurrentHost),
    };

    // dynamic data2 = {
    //   "channel_name": channelName,
    //   'is_owner':
    //       channelName == _authController.profile.value.user!.uid!.toString(),
    // };

    // Without a timeout a stalled mobile connection leaves the room loading
    // forever; retry once since mobile data often drops the first request.
    for (var attempt = 1; attempt <= 2; attempt++) {
      try {
        Response response = await _dio.post(
          kLiveKitEngineCheckAndTokenCreateUrl,
          options: Options(
            headers: _publicHeaders(),
            sendTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
          ),
          data: data,
        );
        return response.data;
      } on DioException catch (e) {
        final retryable =
            e.response == null || (e.response!.statusCode ?? 0) >= 500;
        if (!retryable || attempt == 2) return null;
        await Future.delayed(const Duration(seconds: 2));
      }
    }
    return null;
  }

  // Future<dynamic> createLiveKitToken2({
  //   required String url,
  //   required dynamic data,
  // }) async {
  //   var dio = Dio();

  //   try {
  //     // print('Second Call..............');
  //     Response response = await dio.post(
  //       url,
  //       options: Options(
  //         headers: {
  //           'accept': '*/*',
  //           // 'Authorization': 'Token ${_authController.token.value}',
  //           // 'X-Api-Key': DRF_API_KEY,
  //         },
  //       ),
  //       data: data,
  //     );

  //     // print(response.data);

  //     // print('Data 2');
  //     // print(response.data);

  //     return response.data;
  //   } catch (e) {
  //     return null;
  //   }
  // }

  // void deleteLiveKitRoom({required String channelName}) async {
  //   var dio = Dio();
  //   try {
  //     await dio.delete(
  //       kLiveKitRoomDeleteUrl(
  //         channelName: channelName,
  //       ),
  //       options: Options(headers: {
  //         'accept': '*/*',
  //         'Authorization': 'Token ${_authController.token.value}',
  //         'X-Api-Key': DRF_API_KEY,
  //       }),
  //     );
  //   } catch (e) {
  //     // return '';
  //   }
  // }

  void loadLivekitParticipantList({
    required String channelName,
    required Function onUpdateAction,
    bool fromLiveRoom = false,
  }) async {
    if (loadingParticipantList.value) {
      return;
    }
    _fromLiveRoom = fromLiveRoom;
    loadingParticipantList.value = true;

    try {
      final response = await _dio.get(
        kLiveKitParicipantListUrl(channelName: channelName),
        options: Options(headers: _authHeaders()),
      );
      int? statusCode = response.statusCode;
      loadingParticipantList.value = false;
      if (statusCode == 200) {
        sortingViewerList(response.data["participant_list"]);
        int myContributionDiamonds = response.data["my_contribution_diamonds"];

        if (_fromLiveRoom && myContributionDiamonds > 0) {
          // Send signal to sort Viewers list based on Contribution Diamonds
          dynamic data = {
            'action': 'sort_contribution_diamonds',
            'uid': _authController.profile.value.user!.uid!,
            'full_name': _authController.profile.value.full_name,
            'profile_image':
                _authController.profile.value.profile_image ??
                _authController.profile.value.photo_url,
            'contribution_diamonds': myContributionDiamonds,
            'contribution_rank': 0,
            'is_moderator': _authController.profile.value.is_moderator,
            'is_reseller': _authController.profile.value.is_reseller,
            'level': _authController.profile.value.level,
            'vvip_or_vip_preference':
                _authController.profile.value.vvip_or_vip_preference,
          };
          onUpdateAction(data);
        }
      }
    } catch (e) {
      loadingParticipantList.value = false;
    }
  }

  Future<void> refreshStreamingHomeFeed() async {
    await Future.wait([
      loadBannerList(),
      loadTopHostList(),
      loadTopContributorList(),
      tryToLoadLiveRoomList(),
    ]);
  }

  void startLiveRoomListAutoRefresh() {
    stopLiveRoomListAutoRefresh();
    _liveRoomListRefreshTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => tryToLoadLiveRoomList(),
    );
  }

  void stopLiveRoomListAutoRefresh() {
    _liveRoomListRefreshTimer?.cancel();
    _liveRoomListRefreshTimer = null;
  }

  Future<void> loadBannerList() async {
    if (loadingBannerList.value) {
      return;
    }
    loadingBannerList.value = true;
    try {
      final response = await _dio.get(
        kBannerListUrl,
        options: Options(headers: _publicHeaders()),
      );
      if (response.statusCode == 200) {
        final data = response.data['banner_list'] as List? ?? const [];
        bannerList.assignAll(
          data
              .map(
                (dynamic item) =>
                    HomeBanner.fromJson(Map<String, dynamic>.from(item)),
              )
              .toList(),
        );
      }
    } catch (_) {
      // The centralized Dio interceptor logs the failed request.
    } finally {
      loadingBannerList.value = false;
    }
  }

  Future<void> loadTopHostList() async {
    if (loadingTopHostList.value) {
      return;
    }
    loadingTopHostList.value = true;
    try {
      final response = await _dio.get(
        kTopHostListUrl,
        options: Options(headers: _publicHeaders()),
      );
      if (response.statusCode == 200) {
        topHostList.assignAll(
          _rankedProfilesFromResponse(response.data, const ['top_hosts']),
        );
      }
    } catch (_) {
      // The centralized Dio interceptor logs the failed request.
    } finally {
      loadingTopHostList.value = false;
    }
  }

  Future<void> loadTopContributorList() async {
    if (loadingTopContributorList.value) {
      return;
    }
    loadingTopContributorList.value = true;
    try {
      final response = await _dio.get(
        kTopContributorListUrl,
        options: Options(headers: _publicHeaders()),
      );
      if (response.statusCode == 200) {
        final contributors = _rankedProfilesFromResponse(response.data, const [
          'top_contributors',
          'top_contributor_list',
          'top_hosts',
        ]);

        contributors.sort(
          (a, b) => b.diamondsContributed.compareTo(a.diamondsContributed),
        );

        topContributorList.assignAll(contributors);
      }
    } catch (_) {
      // The centralized Dio interceptor logs the failed request.
    } finally {
      loadingTopContributorList.value = false;
    }
  }

  List<TopHost> _rankedProfilesFromResponse(
    dynamic responseData,
    List<String> keys,
  ) {
    dynamic rawList = responseData;
    if (responseData is Map) {
      rawList = null;
      for (final key in [...keys, 'results']) {
        if (responseData[key] is List) {
          rawList = responseData[key];
          break;
        }
      }
    }
    if (rawList is! List) {
      return const <TopHost>[];
    }
    return rawList
        .whereType<Map>()
        .map((item) => TopHost.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  // Live Room
  Future<void> tryToLoadLiveRoomList() async {
    if (loadingLiveRoomList.value) {
      return;
    }

    loadingLiveRoomList.value = true;
    try {
      await _fetchAndApplyLiveRoomList();
    } finally {
      loadingLiveRoomList.value = false;
    }
  }

  /// Replaces the dashboard list with the server's. Returns null on failure.
  Future<List<dynamic>?> _fetchAndApplyLiveRoomList() async {
    final deleteSeq = _liveRoomDeleteSeq;
    final hostEpoch = _hostEpoch;
    try {
      final response = await _dio.get(
        kLiveRoomListUrl,
        options: Options(headers: {'accept': '*/*'}),
      );
      final responseData = response.data;
      if (response.statusCode != 200 ||
          responseData is! Map ||
          responseData['live_room_list'] is! List) {
        return null;
      }
      final incomingRooms = _withoutRoomsEndedSince(
        (responseData['live_room_list'] as List).toList(),
        deleteSeq,
      );
      _reconcileLiveRoomCollection(listLiveRoom, incomingRooms);
      _syncActiveRoomHost(
        incomingRooms.firstWhereOrNull(
          (room) => _liveRoomId(room) == channelName.value,
        ),
        hostEpoch: hostEpoch,
      );
      _useIsolateLoadLiveStreamingList(liveData: null);
      return incomingRooms;
    } catch (_) {
      // Keep the current dashboard list when a refresh fails.
      return null;
    }
  }

  void _reconcileLiveRoomCollection(
    List<dynamic> currentRooms,
    List<dynamic> incomingRooms, {
    bool notifyDashboard = false,
  }) {
    final incomingById = <String, dynamic>{};
    for (final room in incomingRooms) {
      final roomId = _liveRoomId(room);
      if (roomId != null) {
        incomingById[roomId] = room;
      }
    }

    currentRooms.removeWhere((room) {
      final roomId = _liveRoomId(room);
      return roomId == null || !incomingById.containsKey(roomId);
    });

    for (final entry in incomingById.entries) {
      final existingIndex = currentRooms.indexWhere(
        (room) => _liveRoomId(room) == entry.key,
      );
      if (existingIndex == -1) {
        currentRooms.add(entry.value);
        continue;
      }

      final existingRoom = currentRooms[existingIndex];
      final incomingRoom = entry.value;
      if (existingRoom is Map && incomingRoom is Map) {
        existingRoom
          ..clear()
          ..addAll(incomingRoom);
      } else {
        currentRooms[existingIndex] = incomingRoom;
      }
    }

    final incomingOrder = <String, int>{};
    var order = 0;
    for (final roomId in incomingById.keys) {
      incomingOrder[roomId] = order++;
    }
    currentRooms.sort(
      (first, second) => (incomingOrder[_liveRoomId(first)] ?? 0).compareTo(
        incomingOrder[_liveRoomId(second)] ?? 0,
      ),
    );

    if (notifyDashboard) {
      listFilterLiveStreams.refresh();
    }
  }

  String? _liveRoomId(dynamic room) {
    if (room is! Map || room['channel_id'] == null) {
      return null;
    }
    return room['channel_id'].toString();
  }

  Future<LiveRoomUpdateResult> tryToUpdateLiveRoom({
    required LiveRoomUpdateRequest request,
  }) async {
    try {
      return await sendLiveRoomUpdate(request);
    } catch (_) {
      return const LiveRoomUpdateResult(statusCode: 500);
    }
  }

  void loadGroupCallerList({
    required String channelId,
    required List<int> callerIds,
  }) async {
    dynamic data = {
      'call_type': callType.value,
      'caller_ids': callerIds,
      'my_uid': _authController.profile.value.user!.uid!,
    };
    try {
      final response = await _dio.post(
        kGroupCallerCreateUrl(channelId: channelId),
        options: Options(headers: _authHeaders()),
        data: data,
      );
      int? statusCode = response.statusCode;
      if (statusCode == 200) {
        List<dynamic> groupCallers = response.data["group_callers"];
        if (groupCallers.isNotEmpty) {
          dynamic hostData = groupCallers.firstWhereOrNull(
            (el) => el['uid'].toString() == channelId,
          );
          if (hostData != null) {
            followers.assignAll(hostData['followers']);
            broadcasterDiamonds.value = hostData['diamonds'];
          }
        }

        setActiveCalls(groupCallers);
      }
    } catch (e) {
      //
    }
  }

  void loadContributionRankingList({required int userId}) async {
    if (loadingContributionRankingList.value) {
      return;
    }
    loadingContributionRankingList.value = true;
    contributionRankingList.clear();

    try {
      final response = await _dio.get(
        kContributionRankingListUrl(userId),
        options: Options(headers: _authHeaders()),
      );
      int? statusCode = response.statusCode;
      loadingContributionRankingList.value = false;
      if (statusCode == 200) {
        contributionRankingList.addAll(response.data);
      }
    } catch (e) {
      loadingContributionRankingList.value = false;
    }
  }

  void tryToNotifyFollowerAboutLiveStreaming() async {
    try {
      await _dio.post(
        kLiveStreamingNotifyFollowersCreateUrl,
        options: Options(headers: _authHeaders()),
      );
    } catch (e) {
      //
    }
  }

  void tryToDeleteContributionHistory() async {
    try {
      await _dio.delete(
        kContributionHistoryDeleteUrl,
        options: Options(headers: _authHeaders()),
      );
    } catch (e) {
      //
    }
  }

  void fetchGiftList() async {
    if (loadingGfitList.value) {
      return;
    }
    loadingGfitList.value = true;
    try {
      final response = await _dio.get(
        kGiftListUrl,
        options: Options(headers: _authHeaders()),
      );
      int? statusCode = response.statusCode;
      loadingGfitList.value = false;
      if (statusCode == 200) {
        dynamic data = response.data;
        listNormalGift.clear();
        listAnimatedGift.clear();
        listNormalGift.addAll(data['normal_gifts']);
        listAnimatedGift.addAll(data['animated_gifts']);
      }
    } catch (e) {
      // Nothing
      loadingGfitList.value = false;
    }
  }

  /*
  room_name = data_obj.get('room_name',None)
  receiver_uid = data_obj.get('receiver_uid',0)
  gift_type = data_obj.get('gift_type',None)
  gift_id = int(data_obj.get('gift_id',0))
   */

  Future<bool> tryToSendGiftOnLiveStreaming({
    required String channelName,
    required List<dynamic> receiverUids,
    required String giftType,
    required int giftId,
    required int diamonds,
    required int totalDiamonds,
    required int vat,
    required String receiverFullNames,
    String? giftImage,
    String? svga,
    String? gif,
    String? audio,
    required BuildContext context,
  }) async {
    loadingGiftSend.value = giftId;

    Profile myProfile = _authController.profile.value;

    final request = LiveStreamingGiftRequest(
      roomName: channelName,
      senderUid: myProfile.user!.uid!,
      receiverUids: receiverUids
          .map((dynamic uid) => int.tryParse(uid.toString()) ?? 0)
          .where((int uid) => uid != 0)
          .toList(),
      giftType: giftType,
      giftId: giftId,
      totalDiamonds: totalDiamonds,
      diamonds: diamonds,
      vat: vat,
      fullName: myProfile.full_name ?? '',
      receiverFullName: receiverFullNames,
      profileImage: myProfile.profile_image ?? myProfile.photo_url,
      level: myProfile.level,
      giftImage: giftImage,
      svga: svga,
      gif: gif,
      audio: audio,
      vvipOrVipPreference: myProfile.vvip_or_vip_preference,
    );
    //  '${data['full_name']} sends ${data['diamonds']} diamonds to ${data['receiver_full_name']}';
    // dynamic globalSocketData = {
    //   'type': 'gift',
    //   'full_name': myProfile.full_name,
    //   'diamonds': diamonds,
    //   'receiver_full_name': receiverFullNames,
    // };
    // onUpdateLiveStreamStatus(globalSocketData);

    // dynamic data = {
    //   'sender_uid': myProfile.user!.uid!,
    //   'receiver_uids': receiverUids,
    //   'total_diamonds': totalDiamonds,
    //   'diamonds': diamonds,
    //   'vat': vat,
    // };

    try {
      final response = await _dio.post(
        kLiveStreamingGiftCreateUrl,
        data: request.toJson(),
        options: Options(
          headers: _authHeaders(),
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      int? statusCode = response.statusCode;
      loadingGiftSend.value = -1;
      if (statusCode == 201) {
        // Get.snackbar(
        //   'Success',
        //   "Gift has been sent successfully.",
        //   backgroundColor: Colors.green,
        //   colorText: Colors.white,
        //   snackPosition: SnackPosition.TOP,
        // );
        return true;
      } else if (statusCode == 203) {
        // Get.snackbar(
        //   'Failed',
        //   "You have no sufficient diamonds to send this gift. Please purchase diamonds.",
        //   backgroundColor: Colors.red,
        //   colorText: Colors.white,
        //   snackPosition: SnackPosition.TOP,
        //   duration: const Duration(seconds: 6),
        // );
        rShowSnackBar(
          context: context,
          title:
              "You have no sufficient diamonds to send this gift. Please purchase diamonds.",
          color: AppColors.error,
          durationInSeconds: 6,
        );
      } else if (statusCode == 204) {
        // Get.snackbar(
        //   'Failed',
        //   "You have no sufficient diamonds to send this gift. Please purchase diamonds.",
        //   backgroundColor: Colors.red,
        //   colorText: Colors.white,
        //   snackPosition: SnackPosition.TOP,
        //   duration: const Duration(seconds: 6),
        // );
        Get.defaultDialog(
          title: 'Locked',
          middleText: 'Your diamonds has been locked.',
          titleStyle: const TextStyle(color: AppColors.error),
        );
      } else {
        // Get.snackbar(
        //   'Failed',
        //   "Something is wrong. Please try again.",
        //   backgroundColor: Colors.red,
        //   colorText: Colors.white,
        //   snackPosition: SnackPosition.TOP,
        // );
        rShowSnackBar(
          context: context,
          title: "Something is wrong. Please try again.",
          color: AppColors.error,
          durationInSeconds: 2,
        );
      }
    } catch (_) {
      loadingGiftSend.value = -1;
      // Get.snackbar(
      //   'Failed',
      //   "Something is wrong. Please try again.",
      //   backgroundColor: Colors.red,
      //   colorText: Colors.white,
      //   snackPosition: SnackPosition.TOP,
      // );
      rShowSnackBar(
        context: context,
        title: "Something is wrong. Please try again.",
        color: AppColors.error,
        durationInSeconds: 2,
      );
    }
    return false;
  }

  void sortingViewerList(List<dynamic> viewers) {
    if (viewers.length > 1) {
      // Sorting by Levels and Contribution Diamonds
      try {
        viewers.sort(
          (a, b) => b['level'] != null
              ? b['level']['level']
              : 0.compareTo(a['level'] != null ? a['level']['level'] : 0),
        );
        viewers.sort(
          (a, b) =>
              b['contribution_diamonds'].compareTo(a['contribution_diamonds']),
        );

        if (viewers.length == 2) {
          if (viewers[0]['contribution_diamonds'] > 0) {
            viewers[0]['contribution_rank'] = 1;
            // dynamic firstUser = viewers[0];
            // firstUser['contribution_rank'] = 1;
            // viewers.removeAt(0);
            // viewers.insert(0, firstUser);

            if (viewers[1]['contribution_diamonds'] > 0) {
              viewers[1]['contribution_rank'] = 2;
              // dynamic secondUser = viewers[0];
              // secondUser['contribution_rank'] = 2;
              // viewers.removeAt(0);
              // viewers.insert(1, secondUser);

              viewers = sortingForVVIPorVipPreference(viewers);
              // viewers.insert(0, firstUser);
              // viewers.insert(1, secondUser);
            } else {
              viewers = sortingForVVIPorVipPreference(viewers);
              // viewers.insert(0, firstUser);
            }
          } else {
            viewers = sortingForVVIPorVipPreference(viewers);
          }
        } else if (viewers.length >= 3) {
          if (viewers[0]['contribution_diamonds'] > 0) {
            viewers[0]['contribution_rank'] = 1;
            // dynamic firstUser = viewers[0];
            // firstUser['contribution_rank'] = 1;
            // viewers.removeAt(0);
            // viewers.insert(0, firstUser);

            if (viewers[1]['contribution_diamonds'] > 0) {
              viewers[1]['contribution_rank'] = 2;
              // dynamic secondUser = viewers[0];
              // secondUser['contribution_rank'] = 2;
              // viewers.removeAt(0);
              // viewers.insert(1, secondUser);

              if (viewers[2]['contribution_diamonds'] > 0) {
                viewers[2]['contribution_rank'] = 3;
                // dynamic thirdUser = viewers[0];
                // thirdUser['contribution_rank'] = 3;
                // viewers.removeAt(0);
                // viewers.insert(2, thirdUser);

                viewers = sortingForVVIPorVipPreference(viewers);
                // viewers.insert(0, firstUser);
                // viewers.insert(1, secondUser);
                // viewers.insert(2, thirdUser);
              } else {
                viewers = sortingForVVIPorVipPreference(viewers);
                // viewers.insert(0, firstUser);
                // viewers.insert(1, secondUser);
              }
            } else {
              viewers = sortingForVVIPorVipPreference(viewers);
              // viewers.insert(0, firstUser);
            }
          } else {
            viewers = sortingForVVIPorVipPreference(viewers);
          }
        }
      } catch (e) {
        // setViewList(viewers);
      }
    }
    setViewList(viewers);
  }

  List<dynamic> sortingForVVIPorVipPreference(List<dynamic> viewers) {
    try {
      viewers.sort(
        (a, b) => (b['vvip_or_vip_preference']['rank']).compareTo(
          a['vvip_or_vip_preference']['rank'],
        ),
      );
    } catch (e) {
      //
    }
    return viewers;
  }

  void _useIsolateLoadLiveStreamingList({
    Map<String, dynamic>? liveData,
  }) async {
    var recievePort = ReceivePort(); //creating new port to listen data
    final deleteSeq = _liveRoomDeleteSeq;
    final hostEpoch = _hostEpoch;

    await Isolate.spawn(loadLiveRoomList, [
      recievePort.sendPort,
      _authController.profile.value.user!.uid!,
      channelName.value,
      listLiveRoom.toList(),
      liveData,
    ]); //spawing/creating new thread as isolates.
    late final StreamSubscription<dynamic> subscription;
    subscription = recievePort.listen((data) {
      //listening data from isolate
      if (_isDisposed) {
        subscription.cancel();
        recievePort.close();
        return;
      }
      if (data != null) {
        if (data['type'] == 'liveStreamData') {
          // The user may have left this room while the isolate was running.
          if (data['data']['channel_id'].toString() != channelName.value) {
            return;
          }
          liveStreamData.value = {};
          liveStreamData.value = data['data'];
          allowCommentAndEmojiSend.value = data['data']['allow_send'] ?? true;
          _syncActiveRoomHost(data['data'], hostEpoch: hostEpoch);
        } else if (data['type'] == 'listLiveStreams') {
          final incomingRooms = _withoutRoomsEndedSince(
            (data['listLiveStreams'] as List).toList(),
            deleteSeq,
          );
          _reconcileLiveRoomCollection(listLiveRoom, incomingRooms);
          _reconcileLiveRoomCollection(
            listFilterLiveStreams,
            incomingRooms,
            notifyDashboard: true,
          );
          subscription.cancel();
          recievePort.close();
        }
      }
    });
  }
}

void loadLiveRoomList(List<dynamic> args) {
  SendPort sendPort = args[0];
  dynamic uid = args[1];
  String channelId = args[2];
  List<dynamic> listLiveStreams = args[3];
  dynamic data = args[4];

  if (data != null) {
    if (data['channel_id'].toString() == channelId) {
      dynamic jsonData = {'type': 'liveStreamData', 'data': data};
      sendPort.send(jsonData);
    }

    // Upsert by channel_id: a host handover keeps the same card.
    listLiveStreams.removeWhere(
      (element) =>
          element['channel_id'].toString() == data['channel_id'].toString(),
    );
    final ownerProfile = data['owner_profile'];
    if (ownerProfile is Map &&
        !((ownerProfile['blocks'] as List?)?.contains(uid) ?? false)) {
      listLiveStreams.add(data);
    }
  }

  if (listLiveStreams.length > 1) {
    listLiveStreams.sort(
      (a, b) => DateTime.parse(
        a['created_datetime'],
      ).compareTo(DateTime.parse(b['created_datetime'])),
    );
    // try {
    listLiveStreams.sort(
      (a, b) => (b['viewers_count'] + (b['owner_profile']['ranking'] ?? 0))
          .compareTo(a['viewers_count'] + (a['owner_profile']['ranking'] ?? 0)),
    );
    // } catch (e) {
    //   print('Error : $e......................................');
    // }
    // listLiveStreams
    //     .sort((a, b) => (b['viewers_count']).compareTo(a['viewers_count']));

    // for (dynamic data1 in listLiveStreams.toList()) {
    //   print(
    //       "Serial: ${data1['owner_profile']['full_name']} ${data1['viewers_count'] + (data1['owner_profile']['ranking'] ?? 0)}");
    // }
  }

  dynamic jsonData = {
    'type': 'listLiveStreams',
    'listLiveStreams': listLiveStreams,
  };
  Isolate.exit(sendPort, jsonData);
}

// void loadLiveStramingFirebaseList(List<dynamic> args) {
//   // recievePort.sendPort,
//   //   _authController.profile.value.user!.uid!,
//   //   channelName.value,
//   //   listQueryDocumentSpanshot,
//   SendPort sendPort = args[0];
//   dynamic uid = args[1];
//   String channelName = args[2];
//   List<QueryDocumentSnapshot<Map<String, dynamic>>>
//       listLiveStreamsFromFirebase = args[3];
//   List<dynamic> listLiveStreams = [];
//   for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
//       in listLiveStreamsFromFirebase) {
//     if (documentSnapshot.exists && documentSnapshot.data().isNotEmpty) {
//       Map<String, dynamic> data = documentSnapshot.data();
//       if (data['channel_id'].toString() == channelName) {
//         dynamic jsonData = {
//           'type': 'liveStreamData',
//           'data': data,
//         };
//         sendPort.send(jsonData);
//       }
//       if (!data['blocks'].contains(uid)) {
//         listLiveStreams.add(data);
//       }
//     }
//   }
//   if (listLiveStreams.length > 1) {
//     listLiveStreams
//         .sort((a, b) => a['creation_time'].compareTo(b['creation_time']));

//     listLiveStreams.sort((a, b) => (b['viewers_count'] + (b['vvip_rank'] ?? 0))
//         .compareTo(a['viewers_count'] + (a['vvip_rank'] ?? 0)));
//   }

//   dynamic jsonData = {
//     'type': 'listLiveStreams',
//     'listLiveStreams': listLiveStreams,
//   };
//   Isolate.exit(sendPort, jsonData);
// }

// void _sortingLiveRooms() {
//   if (listFilterLiveStreams.length > 1) {
//     try {
//       listFilterLiveStreams.sort((a, b) =>
//           DateTime.fromMillisecondsSinceEpoch(
//                   a['creation_time'].millisecondsSinceEpoch)
//               .toLocal()
//               .compareTo(DateTime.fromMillisecondsSinceEpoch(
//                       b['creation_time'].millisecondsSinceEpoch)
//                   .toLocal()));
//     } catch (e) {
//       //
//     }

//     listFilterLiveStreams
//         .sort((a, b) => (b['viewers_count']).compareTo((a['viewers_count'])));
//   }
// }

void _fetchTopRatedAgentList(List<dynamic> args) async {
  SendPort sendPort = args[0];
  final dio = createApiDio();
  try {
    final response = await dio.get(
      kManualAgentListUrl,
      options: Options(
        headers: {
          'accept': '*/*',
          // 'Authorization': 'Token $token',
          'X-Api-Key': DRF_API_KEY,
        },
      ),
      // queryParameters: {'list_range': 5},
    );

    int? statusCode = response.statusCode;
    if (statusCode == 200) {
      Isolate.exit(sendPort, response.data);
    }
    Isolate.exit(sendPort);
  } catch (e) {
    // Nothing
    Isolate.exit(sendPort);
  }
}
