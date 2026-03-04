import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:audioplayers/audioplayers.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:doyel_live/app/data/profile_model.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/views/livekit/widgets/participant_info.dart';
import 'package:doyel_live/app/modules/messenger/controllers/messenger_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'package:livekit_client/livekit_client.dart';
import 'package:doyel_live/app/routes/app_pages.dart';
import 'package:doyel_live/app/utils/api_endpoints.dart';
import 'package:doyel_live/app/utils/constants.dart';
import 'package:doyel_live/app/utils/drf_api_key.dart';
import 'package:doyel_live/app/widgets/reusable_widgets.dart';
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
  final AuthController _authController = Get.find();
  // final loadingCommentSend = false.obs;
  final loadingLiveRoomList = false.obs;
  final loadingGfitList = false.obs;
  final loadingGiftSend = (-1).obs;
  final loadingParticipantList = false.obs;
  final loadingContributionRankingList = false.obs;

  final countryName = ''.obs;
  final phoneCode = ''.obs;
  final RxList<dynamic> listNormalGift = <dynamic>[].obs;
  final RxList<dynamic> listAnimatedGift = <dynamic>[].obs;

  final userInteractTab = 'gifts'.obs;
  final showViewersTab = false.obs;
  final callTabName = 'views'.obs;
  final showCommentField = false.obs;
  final muted = false.obs,
      videoDisabled = false.obs,
      loudSpeaker = false.obs,
      needsScroll = true.obs;
  final isBroadcaster = false.obs,
      allowVideoCall = false.obs,
      allowCommentAndEmojiSend = true.obs,
      pkState = false.obs,
      busyConnectingEngine = true.obs;

  final callType = ''.obs;
  final RxList<dynamic> listRequestedCall = <dynamic>[].obs;
  final RxList<dynamic> listActiveCall = <dynamic>[].obs;
  Timer? _timerAnimatedGiftSendAnimcation,
      _timerShowingMarqueeText,
      _timerTopContributorList;

  final showUserJoinedAnimation = false.obs,
      showGiftSendAnimation = false.obs,
      expandMediaController = false.obs;
  // Gift stuffs
  final RxList<dynamic> listNormalGiftSend = <dynamic>[].obs;
  final RxList<dynamic> listAnimatedGiftSend = <dynamic>[].obs;
  final RxList<dynamic> listLiveHeadlines = <dynamic>[].obs;

  final liveRunningDuration = '00:00:00'.obs;
  // Live Broadcast Stuffs
  final channelName = '0'.obs;
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

  String liveRoomSocketBaseUrl = 'ws://195.26.253.191/ws/livekit-live-room';

  Rx<CameraPosition> cameraPosition = CameraPosition.front.obs;

  final loadingRoom = 0.obs;
  int topContributorsIntervalMinutes = -1;

  final selectedGift = {
    'gift_type': '',
    'id': 0,
    'diamonds': 0,
    'vat': 0,
    'gift_image': null,
    'gif': null,
    'audio': null,
  }.obs;

  Rx<HomeTabEnum> selectedHomeTabEnum = HomeTabEnum.ALL_LIVES.obs;
  final MessengerController _messengerController = Get.find();

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
    String? gif,
    String? audio,
  }) {
    selectedGift.value = {
      'gift_type': giftType,
      'id': id,
      'diamonds': diamonds ?? 0,
      'vat': vat ?? 0,
      'gift_image': giftImage,
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
    webSocketClientForStreaming!.close();
    if (_timerAnimatedGiftSendAnimcation != null) {
      _timerAnimatedGiftSendAnimcation?.cancel();
    }
    if (_timerShowingMarqueeText != null) {
      _timerShowingMarqueeText?.cancel();
    }
    _isDisposed = true;
    disposetopContributorRankingList();

    super.onClose();
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
      deviceName = iosDeviceInfo.utsname.machine!; // e.g. "iPod7,1"
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
        listLiveRoom.removeWhere(
          (element) => element['channel_id'] == data['channel_id'],
        );
        listFilterLiveStreams.removeWhere(
          (element) => element['channel_id'] == data['channel_id'],
        );
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
    // required Room room,
    // required EventsListener<RoomEvent> listener,
  }) {
    setClearStreamingRelatedFields();
    setClearAnimationStuffs();
    videoDimensionsDescription = 'HD(1280x720)';

    channelName.value = brdchannelName;
    broadcasterFullname.value = broadcasterName ?? '';
    broadcasterProfileImage.value = brdImage ?? '';
    isBroadcaster.value = isBrdOwner;
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
        showGiftSendAnimation.value = false;
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

  void setTimerForShowAnimatedGiftSendAnimation() async {
    if (listAnimatedGiftSend.isNotEmpty &&
        _timerAnimatedGiftSendAnimcation == null) {
      // if (_timerAnimatedGiftSendAnimcation != null) {
      //   _timerAnimatedGiftSendAnimcation?.cancel();
      // }
      final giftData = listAnimatedGiftSend[0];
      Duration duration = const Duration(milliseconds: 1300);
      if (giftData['gift_type'] == 'animation') {
        duration = const Duration(seconds: 3);
      }
      AudioPlayer? audioPlayer;
      if (giftData['audio'] != null) {
        audioPlayer = AudioPlayer(playerId: giftData['gift_id'].toString());

        try {
          await audioPlayer.play(UrlSource(giftData['audio']), volume: .4);
        } catch (e) {
          //
        }
      }

      showGiftSendAnimation.value = true;
      _timerAnimatedGiftSendAnimcation = Timer(duration, () async {
        showGiftSendAnimation.value = false;
        _timerAnimatedGiftSendAnimcation?.cancel();
        _timerAnimatedGiftSendAnimcation = null;
        if (giftData['audio'] != null) {
          // AudioPlayer audioPlayer =
          //     AudioPlayer(playerId: giftData['gift_id'].toString());
          try {
            await audioPlayer?.stop();
            await audioPlayer?.release();
          } catch (e) {
            //
          }
        }
        try {
          listAnimatedGiftSend.removeAt(0);
        } catch (e) {
          //
        }
        setTimerForShowAnimatedGiftSendAnimation();
      });
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
    liveStreamData.value = {};
    channelName.value = '';
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
    var dio = Dio();
    dynamic data = {
      'channel_name': channelName,
      'identity': _authController.profile.value.user!.uid!.toString(),
      'full_name': _authController.profile.value.full_name,
      'is_owner':
          channelName == _authController.profile.value.user!.uid!.toString(),
    };

    // dynamic data2 = {
    //   "channel_name": channelName,
    //   'is_owner':
    //       channelName == _authController.profile.value.user!.uid!.toString(),
    // };

    try {
      Response response = await dio.post(
        kLiveKitEngineCheckAndTokenCreateUrl,
        options: Options(
          headers: {
            'accept': '*/*',
            // 'Authorization': 'Token ${_authController.token.value}',
            'X-Api-Key': DRF_API_KEY,
          },
        ),
        // data: data2,
        data: data,
      );

      // print('Data 1');
      // print(response.data);
      return response.data;

      // String engine = response.data['engine'];
      // String url = response.data['url'];
      // dynamic responseData = await createLiveKitToken2(data: data, url: url);
      // if (responseData != null) {
      //   responseData['engine'] = engine;
      // }
      // // print('responseData: $responseData');
      // return responseData;
    } catch (e) {
      return null;
    }
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
    var dio = Dio();
    loadingParticipantList.value = true;

    try {
      final response = await dio.get(
        kLiveKitParicipantListUrl(channelName: channelName),
        options: Options(
          headers: {
            'accept': '*/*',
            'Authorization': 'Token ${_authController.token.value}',
            'X-Api-Key': DRF_API_KEY,
          },
        ),
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

  // Live Room
  void tryToLoadLiveRoomList() async {
    if (loadingLiveRoomList.value) {
      return;
    }

    loadingLiveRoomList.value = true;
    var dio = Dio();

    try {
      final response = await dio.get(
        kLiveRoomListUrl,
        options: Options(
          headers: {
            'accept': '*/*',
            // 'Authorization': 'Token ${_authController.token.value}',
            // 'X-Api-Key': DRF_API_KEY,
          },
        ),
      );
      int? statusCode = response.statusCode;
      loadingLiveRoomList.value = false;
      if (statusCode == 200) {
        listLiveRoom.assignAll(response.data['live_room_list']);
        _useIsolateLoadLiveStreamingList(liveData: null);
      }
    } catch (e) {
      loadingLiveRoomList.value = false;
    }
  }

  // Live Room
  void tryToUpdateLiveRoom({required dynamic data}) async {
    var dio = Dio();

    try {
      await dio.put(
        kLiveRoomUpdateUrl,
        options: Options(
          headers: {
            'accept': '*/*',
            // 'Authorization': 'Token ${_authController.token.value}',
            'X-Api-Key': DRF_API_KEY,
          },
        ),
        data: data,
      );
    } catch (e) {
      //
    }
  }

  void loadGroupCallerList({
    required String channelId,
    required List<int> callerIds,
  }) async {
    var dio = Dio();
    dynamic data = {
      'call_type': callType.value,
      'caller_ids': callerIds,
      'my_uid': _authController.profile.value.user!.uid!,
    };
    try {
      final response = await dio.post(
        kGroupCallerCreateUrl(channelId: channelId),
        options: Options(
          headers: {
            'accept': '*/*',
            'Authorization': 'Token ${_authController.token.value}',
            'X-Api-Key': DRF_API_KEY,
          },
        ),
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
    var dio = Dio();

    try {
      final response = await dio.get(
        kContributionRankingListUrl(userId),
        options: Options(
          headers: {
            'accept': '*/*',
            'Authorization': 'Token ${_authController.token.value}',
            'X-Api-Key': DRF_API_KEY,
          },
        ),
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
    var dio = Dio();
    try {
      await dio.post(
        kLiveStreamingNotifyFollowersCreateUrl,
        options: Options(
          headers: {
            'accept': '*/*',
            'Authorization': 'Token ${_authController.token.value}',
            'X-Api-Key': DRF_API_KEY,
          },
        ),
      );
    } catch (e) {
      //
    }
  }

  void tryToDeleteContributionHistory() async {
    var dio = Dio();
    try {
      await dio.delete(
        kContributionHistoryDeleteUrl,
        options: Options(
          headers: {
            'accept': '*/*',
            'Authorization': 'Token ${_authController.token.value}',
            'X-Api-Key': DRF_API_KEY,
          },
        ),
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
    var dio = Dio();
    try {
      final response = await dio.get(
        kGiftListUrl,
        options: Options(
          headers: {
            'accept': '*/*',
            'Authorization': 'Token ${_authController.token.value}',
            'X-Api-Key': DRF_API_KEY,
          },
        ),
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
    String? gif,
    String? audio,
    required BuildContext context,
  }) async {
    loadingGiftSend.value = giftId;

    Profile myProfile = _authController.profile.value;

    dynamic data = {
      'room_name': channelName,
      'sender_uid': myProfile.user!.uid!,
      'receiver_uids': receiverUids,
      'full_name': myProfile.full_name,
      'receiver_full_name': receiverFullNames,
      'profile_image': myProfile.profile_image ?? myProfile.photo_url,
      'level': myProfile.level,
      'gift_type': giftType,
      'gift_id': giftId,
      'total_diamonds': totalDiamonds,
      'diamonds': diamonds,
      'vat': vat,
      'gift_image': giftImage,
      'gif': gif,
      'audio': audio,
      'vvip_or_vip_preference': myProfile.vvip_or_vip_preference,
    };
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

    var dio = Dio();
    try {
      final response = await dio.post(
        kLiveStreamingGiftCreateUrl,
        data: data,
        options: Options(
          headers: {
            'accept': '*/*',
            'Authorization': 'Token ${_authController.token.value}',
            'X-Api-Key': DRF_API_KEY,
          },
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
          color: Colors.red,
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
          titleStyle: const TextStyle(color: Colors.red),
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
          color: Colors.red,
          durationInSeconds: 2,
        );
      }
    } catch (e) {
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
        color: Colors.red,
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

    await Isolate.spawn(loadLiveRoomList, [
      recievePort.sendPort,
      _authController.profile.value.user!.uid!,
      channelName.value,
      listLiveRoom.toList(),
      liveData,
    ]); //spawing/creating new thread as isolates.
    recievePort.listen((data) {
      //listening data from isolate
      if (data != null) {
        if (data['type'] == 'liveStreamData') {
          liveStreamData.value = {};
          liveStreamData.value = data['data'];
          allowCommentAndEmojiSend.value = data['data']['allow_send'] ?? true;
        } else if (data['type'] == 'listLiveStreams') {
          listLiveRoom.assignAll(data['listLiveStreams']);
          listFilterLiveStreams.assignAll(data['listLiveStreams']);
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

    listLiveStreams.removeWhere(
      (element) => element['channel_id'] == data['channel_id'],
    );
    if (data['owner_profile'] != null &&
        !data['owner_profile']['blocks'].contains(uid)) {
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
  String token = args[1];
  var dio = Dio();
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
