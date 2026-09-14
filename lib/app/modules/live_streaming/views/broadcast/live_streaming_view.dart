import 'package:doyel_live/app/theme/app_colors.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doyel_live/app/data/entry_effect_model.dart';
import 'package:doyel_live/app/data/profile_model.dart';
import 'package:doyel_live/app/data/vip_preference.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/models/live_room_update_models.dart';
import 'package:doyel_live/app/modules/live_streaming/utlls/livekit_stuffs.dart';
import 'package:doyel_live/app/modules/live_streaming/utlls/liveroom_isolation_actions.dart';
import 'package:doyel_live/app/modules/live_streaming/views/broadcast/display/initial_renderer_room_display_layout.dart';
import 'package:doyel_live/app/modules/live_streaming/views/broadcast/display/video_group_room_layout.dart';
import 'package:doyel_live/app/modules/live_streaming/views/broadcast/helper_functions/call_waiting_bottom_sheet_function.dart';
import 'package:doyel_live/app/modules/live_streaming/views/broadcast/helper_functions/user_info_bottom_sheet_function.dart';
import 'package:doyel_live/app/modules/live_streaming/views/broadcast/helper_functions/user_interact/user_interact_bottom_sheet_funtion.dart';
import 'package:doyel_live/app/modules/live_streaming/views/broadcast/widgets/live_room_icon_button.dart';
import 'package:doyel_live/app/modules/live_streaming/views/livekit/widgets/participant_info.dart';
import 'package:doyel_live/app/modules/nav/views/nav_view.dart';
import 'package:doyel_live/app/modules/products/controllers/vvip_or_vip_package_controller.dart';
import 'package:doyel_live/app/utils/constants.dart';
import 'package:doyel_live/app/utils/firebase_stuffs/helper_functions.dart';
import 'package:doyel_live/app/widgets/animated_media_widget.dart';
import 'package:doyel_live/app/widgets/reusable_widgets.dart';
import 'package:doyel_live/app/widgets/vip_profile_avatar.dart';
import 'package:emojis/emoji.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:headset_connection_event/headset_event.dart';

import 'package:get/get.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:marquee/marquee.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_client/web_socket_client.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart' as rtc;

class LiveStreamingView extends StatefulWidget {
  const LiveStreamingView({
    super.key,
    required this.channelName,
    required this.isBroadcaster,
    required this.followers,
    required this.blocks,
    required this.level,
    required this.vVipOrVipPreference,
    this.broadcasterDiamonds = 0,
    this.loves = 0,
    this.profileImage,
    this.fullName,
    this.isFromSharedLink = false,
  });
  final String channelName;
  final bool isBroadcaster, isFromSharedLink;
  final List<dynamic> followers, blocks;
  // final List<int> followers, blocks;
  final int broadcasterDiamonds, loves;
  final String? profileImage, fullName;
  final dynamic level, vVipOrVipPreference;

  @override
  _LiveStreamingViewState createState() => _LiveStreamingViewState();
}

class EmojiItem {
  static final random = Random();
  // double? _size;
  String? datetime;

  Alignment? _alignment;
  Emoji? emoji;

  EmojiItem({required String this.datetime, required this.emoji}) {
    _alignment = Alignment(
      random.nextDouble() * 2 - 1.2,
      random.nextDouble() * 2 - 1,
    );
    // _size = random.nextDouble() * 40 + 50;
  }
}

class _LiveStreamingViewState extends State<LiveStreamingView>
    with SingleTickerProviderStateMixin {
  final AuthController _authController = Get.find();
  final LiveStreamingController _livekitStreamingController = Get.find();
  final VVIPorVipPackageController _packageController =
      Get.isRegistered<VVIPorVipPackageController>()
      ? Get.find<VVIPorVipPackageController>()
      : Get.put(VVIPorVipPackageController());

  late TextEditingController _editingControllerComment;

  final _focusNode = FocusNode();

  final _headsetPlugin = HeadsetEvent();
  HeadsetState? _headsetState;
  // IOWebSocketChannel? webSocketChannelForActions;
  WebSocket? webSocketClientForActions;
  StreamSubscription<dynamic>? _actionSocketConnectionSubscription;
  StreamSubscription<dynamic>? _actionSocketMessageSubscription;
  String? _liveRoomSocketBaseUrl;
  String _webSocketConnectionState = '';
  int _actionSocketGeneration = 0;

  final ScrollController _scrollController = ScrollController();
  double? _scrollPosition;
  double get _screenGlobalWidth => MediaQuery.sizeOf(context).width;
  double get _screenGlobalHeight => MediaQuery.sizeOf(context).height;
  Map<String, dynamic> get _hostVipPreference =>
      normalizeVipPreference(widget.vVipOrVipPreference);
  // Keep track of whether a scroll is needed.
  bool _isFirstTimeLoad = true;

  Timer? _timer,
      _timerTrackingExpiredStreams,
      _timerTrackingExpiredNormalGifts,
      _timerAfterInternetConnectionCheck;
  Timer? _entryEffectTimer;
  AudioPlayer? _entryEffectAudioPlayer;
  final List<_RoomEntryEffect> _entryEffectQueue = <_RoomEntryEffect>[];
  _RoomEntryEffect? _activeEntryEffect;
  bool _entryEffectFinishing = false;

  // Live Kit
  String? _preferredCodec;
  // Live Kit
  Room? _room;
  EventsListener<RoomEvent>? _listener;
  String _roomToken = '', _serverUrl = '';
  String? _engineName = 'engine_1';

  final bool _fastConnect = false;
  bool _isDisposed = false;

  CameraPosition _cameraPosition = CameraPosition.front;
  // /////////////////////////////////
  final List<dynamic> _listSendingEmojiName = [], _listSendingEmojiCount = [];

  int _myUid = 0, _prevDuration = -1, _liveGroupRoomCount = 1;
  final List<int> _listGroupIds = [];

  // var items = <Item>[];
  AnimationController? _animationController;
  // Working Emoji
  final _emojiItems = <EmojiItem>[];
  final _random = Random();

  bool get _hasLiveRoomControlAccess {
    final isModerator = _authController.profile.value.is_moderator ?? false;
    final hasKingPackage = _packageController.hasActiveKingPackage;
    return widget.isBroadcaster || isModerator || hasKingPackage;
  }

  _scrollToBottom() {
    // _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    try {
      _scrollPosition = _scrollController.position.maxScrollExtent;
    } catch (e) {
      //
      try {
        _scrollPosition = _scrollController.position.pixels;
      } catch (e) {
        //
        _scrollPosition = 0;
      }
    }
    try {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      //
    }
  }

  void _showUpActivity({required dynamic data}) {
    if (data['type'] == 'gift') {
      // Sender
      if (_myUid == data['sender_uid']) {
        Profile profile = _authController.profile.value;
        profile.diamonds =
            profile.diamonds! - int.parse(data['gift_diamonds'].toString());

        _authController.profile.value = Profile();
        _authController.profile.value = profile;
        _authController.preferences.setString(
          'profile',
          jsonEncode(profile.toJson()),
        );
      }
      // Receiver
      // if (_myUid == int.parse(data['receiver_uid'].toString())) {
      if (data['receiver_uids'].contains(_myUid)) {
        Profile profile = _authController.profile.value;
        profile.diamonds =
            profile.diamonds! +
            int.parse(data['diamonds'].toString()) -
            int.parse(data['vat'].toString());
        _authController.profile.value = Profile();
        _authController.profile.value = profile;
        _authController.preferences.setString(
          'profile',
          jsonEncode(profile.toJson()),
        );
      }
      // Update Broadcaster diamonds on Live Streaming
      if (data['sender_uid'] == int.parse(widget.channelName)) {
        _livekitStreamingController.broadcasterDiamonds.value -= int.parse(
          data['gift_diamonds'].toString(),
        );
      }
      // Update Broadcaster diamonds on Live Streaming
      // if (int.parse(data['receiver_uid'].toString()) ==
      //     int.parse(widget.channelName)) {
      if (data['receiver_uids'].contains(int.parse(widget.channelName))) {
        _livekitStreamingController.broadcasterDiamonds.value +=
            int.parse(data['diamonds'].toString()) -
            int.parse(data['vat'].toString());
      }
      if (_livekitStreamingController.listActiveCall.isNotEmpty) {
        // Sender
        int index1 = _livekitStreamingController.listActiveCall.indexWhere(
          (element) => element['uid'] == data['sender_uid'],
        );
        if (index1 > -1) {
          dynamic activeCall =
              _livekitStreamingController.listActiveCall[index1];
          activeCall['diamonds'] -= int.parse(data['gift_diamonds'].toString());

          _livekitStreamingController.listActiveCall.removeAt(index1);
          _livekitStreamingController.listActiveCall.insert(index1, activeCall);
        }
        // Receivers
        for (dynamic receiverId in data['receiver_uids']) {
          int index2 = _livekitStreamingController.listActiveCall.indexWhere(
            (element) => element['uid'] == receiverId,
          );
          if (index2 > -1) {
            dynamic activeCall =
                _livekitStreamingController.listActiveCall[index2];
            activeCall['diamonds'] +=
                int.parse(data['diamonds'].toString()) -
                int.parse(data['vat'].toString());

            _livekitStreamingController.listActiveCall.removeAt(index2);
            _livekitStreamingController.listActiveCall.insert(
              index2,
              activeCall,
            );
          }
        }
      }

      ////////////////////
      // Animated Gifts
      if (data['gift_type'] == 'animation') {
        _livekitStreamingController.listAnimatedGiftSend.add(data);
        _livekitStreamingController.showNextAnimatedGift();
      } else {
        // Normal Gifts
        _livekitStreamingController.listNormalGiftSend.insert(0, data);
      }
    }
    _livekitStreamingController.listCommentLiveStream.add(data);
    _scrollingCommentsView();
  }

  void _scrollingCommentsView() {
    // Scrolling Comments
    if (_livekitStreamingController.needsScroll.value) {
      _scrollToBottom();
    }
    //  else if (_livekitStreamingController.listCommentLiveStream.length < 15) {
    //   _scrollController.animateTo(
    //       _scrollController.position.maxScrollExtent + 50,
    //       duration: const Duration(milliseconds: 200),
    //       curve: Curves.easeInOut);
    // }
  }

  void _sendComment() {
    final commentsAllowed =
        widget.isBroadcaster ||
        _livekitStreamingController.allowCommentAndEmojiSend.value;
    if (!commentsAllowed) {
      rShowSnackBar(
        context: context,
        title: 'Comments are currently disabled by the host.',
        color: AppColors.warning,
        durationInSeconds: 2,
      );
      return;
    }

    final enteredText = _editingControllerComment.text.trim();
    if (enteredText.isEmpty) {
      return;
    }

    final wasTruncated = enteredText.length > 1000;
    final commentText = wasTruncated
        ? enteredText.substring(0, 1000)
        : enteredText;
    final profile = _authController.profile.value;
    final sent = onUpdateAction({
      'action': 'activity',
      'type': 'comment',
      'uid': profile.user!.uid!,
      'text': commentText,
      'full_name': profile.full_name,
      'level': profile.level,
      'profile_image': profile.profile_image ?? profile.photo_url,
      'diamonds': profile.diamonds,
      'is_moderator': profile.is_moderator,
      'is_reseller': profile.is_reseller,
      'vvip_or_vip_preference': profile.vvip_or_vip_preference,
    });

    if (!sent) {
      unawaited(initWebSocketClientForActions());
      rShowSnackBar(
        context: context,
        title: 'Comment connection is not ready. Please try again.',
        color: AppColors.warning,
        durationInSeconds: 2,
      );
      return;
    }

    _editingControllerComment.clear();
    _focusNode.unfocus();
    if (wasTruncated) {
      rShowSnackBar(
        context: context,
        title: 'Your comment was shortened to 1000 characters.',
        color: AppColors.warning,
        durationInSeconds: 2,
      );
    }
  }

  Future<void> initWebSocketClientForActions({
    bool forceReconnect = false,
  }) async {
    final socketBaseUrl = _liveRoomSocketBaseUrl?.trim() ?? '';
    if (_isDisposed || socketBaseUrl.isEmpty) {
      return;
    }

    if (webSocketClientForActions != null &&
        !forceReconnect &&
        _webSocketConnectionState != 'disconnecting' &&
        _webSocketConnectionState != 'disconnected') {
      return;
    }

    final normalizedBaseUrl = socketBaseUrl.endsWith('/')
        ? socketBaseUrl.substring(0, socketBaseUrl.length - 1)
        : socketBaseUrl;
    final uri = Uri.tryParse(
      '$normalizedBaseUrl/${Uri.encodeComponent(widget.channelName)}/',
    );
    if (uri == null || (uri.scheme != 'ws' && uri.scheme != 'wss')) {
      _webSocketConnectionState = 'disconnected';
      return;
    }

    _closeActionSocket();
    final socketGeneration = _actionSocketGeneration;
    final backoff = LinearBackoff(
      initial: const Duration(seconds: 0),
      increment: const Duration(seconds: 1),
      maximum: const Duration(seconds: 5),
    );
    final socket = WebSocket(uri, backoff: backoff);
    webSocketClientForActions = socket;

    _actionSocketConnectionSubscription = socket.connection.listen((state) {
      if (_isDisposed || socketGeneration != _actionSocketGeneration) {
        return;
      }
      if (state == const Connecting()) {
        _webSocketConnectionState = 'connecting';
      } else if (state == const Connected()) {
        _webSocketConnectionState = 'connected';
      } else if (state == const Reconnecting()) {
        _webSocketConnectionState = 'reconnecting';
      } else if (state == const Reconnected()) {
        _webSocketConnectionState = 'reconnected';
      } else if (state == const Disconnecting()) {
        _webSocketConnectionState = 'disconnecting';
      } else if (state == const Disconnected()) {
        _webSocketConnectionState = 'disconnected';
      }
    });

    _actionSocketMessageSubscription = socket.messages.listen((message) {
      if (_isDisposed || socketGeneration != _actionSocketGeneration) {
        return;
      }
      try {
        dynamic data = jsonDecode(message)['message'];
        if (data['gzip'] != null) {
          final gzipDecodedBytes = gzip.decode(data['gzip'].cast<int>());
          final Map<String, dynamic> gzipData = jsonDecode(
            utf8.decode(gzipDecodedBytes),
          );
          data['gzip'] = null;
          data = {...data, ...gzipData};
        }

        _takeActionOnReceivedData(data);
      } catch (_) {
        // Ignore malformed room messages without stopping the socket listener.
      }
    });
  }

  bool get _isActionSocketConnected =>
      webSocketClientForActions != null &&
      (_webSocketConnectionState == 'connected' ||
          _webSocketConnectionState == 'reconnected');

  void _closeActionSocket() {
    _actionSocketGeneration++;
    _actionSocketConnectionSubscription?.cancel();
    _actionSocketConnectionSubscription = null;
    _actionSocketMessageSubscription?.cancel();
    _actionSocketMessageSubscription = null;
    final socket = webSocketClientForActions;
    webSocketClientForActions = null;
    _webSocketConnectionState = 'disconnected';
    socket?.close(1000, 'CLOSE_NORMAL');
  }

  void _takeActionOnReceivedData(dynamic data) async {
    if (data != null) {
      switch (data['action']) {
        // Request to Call
        case 'call_request':
          if (_livekitStreamingController.listRequestedCall.indexWhere(
                (element) => element['uid'] == data['uid'],
              ) ==
              -1) {
            _livekitStreamingController.listRequestedCall.add(data);
            data['type'] = 'call_request';
            _livekitStreamingController.listCommentLiveStream.add(data);
            _scrollingCommentsView();

            // if (data['uid'] == _myUid) {
            //   try {
            //     await _room!.localParticipant!.setCameraEnabled(true);
            //   } catch (e) {
            //     //
            //   }
            // }
          }
          break;
        case 'cancel_request':
          _livekitStreamingController.listRequestedCall.removeWhere(
            (element) => element['uid'] == data['uid'],
          );

          data['type'] = 'cancel_request';
          _livekitStreamingController.listCommentLiveStream.add(data);
          _scrollingCommentsView();
          // if (data['uid'] == _myUid) {
          //  _onUnpublishAllTracks();
          // }
          break;
        case 'end_call':
          _livekitStreamingController.listActiveCall.removeWhere(
            (element) => element['uid'] == data['uid'],
          );

          if (data['uid'] == _myUid) {
            _onUnpublishAllTracks();
          }
          break;
        case 'end_active_calls':
          for (
            int i = 0;
            i < _livekitStreamingController.listActiveCall.length;
            i++
          ) {
            if (i > 0) {
              if (_livekitStreamingController.listActiveCall[i]['uid'] ==
                  _myUid) {
                _onUnpublishAllTracks();
              }
              _livekitStreamingController.listActiveCall.removeAt(i);
            }
          }
          _livekitStreamingController.listActiveCall.clear();
          break;
        case 'controller':
          int index = _livekitStreamingController.listActiveCall.indexWhere(
            (element) => element['uid'] == data['uid'],
          );
          if (index > -1) {
            dynamic activeCallData =
                _livekitStreamingController.listActiveCall[index];
            // Owner
            if (data['uid'] == _myUid) {
              try {
                await _room!.localParticipant?.setMicrophoneEnabled(
                  !data['muted'],
                );
              } catch (e) {
                //
              }
              if (activeCallData['call_type'] == 'video') {
                try {
                  await _room!.localParticipant?.setCameraEnabled(
                    !data['video_disabled'],
                  );
                } catch (e) {
                  //
                }
              }

              _livekitStreamingController.muted.value = data['muted'];
              _livekitStreamingController.videoDisabled.value =
                  data['video_disabled'];
            }

            activeCallData['muted'] = data['muted'];
            activeCallData['video_disabled'] = data['video_disabled'];
            _livekitStreamingController.listActiveCall.removeAt(index);
            _livekitStreamingController.listActiveCall.insert(
              index,
              activeCallData,
            );
          }
          break;
        case "accept_general_callers":

          // active_user
          if (_livekitStreamingController.listActiveCall.indexWhere(
                (element) => element['uid'] == data['uid'],
              ) ==
              -1) {
            _livekitStreamingController.listRequestedCall.removeWhere(
              (element) => element['uid'] == data['uid'],
            );

            _livekitStreamingController.listActiveCall.add(data);

            if (data['uid'] == _myUid) {
              try {
                await _room!.localParticipant?.setCameraEnabled(true);
              } catch (e) {
                //
              }
              try {
                await _room!.localParticipant?.setMicrophoneEnabled(true);
              } catch (e) {
                //
              }
              if (data['call_type'] == 'audio') {
                try {
                  await _room!.localParticipant?.setCameraEnabled(false);
                } catch (e) {
                  //
                }
              }
            }
          }
          break;
        case "active_users":
          if (_livekitStreamingController.listActiveCall.indexWhere(
                (element) => element['uid'] == data['uid'],
              ) ==
              -1) {
            _livekitStreamingController.listRequestedCall.removeWhere(
              (element) => element['uid'] == data['uid'],
            );

            _livekitStreamingController.listActiveCall.add(data);

            if (data['uid'] == _myUid) {
              try {
                await _room!.localParticipant?.setCameraEnabled(true);
              } catch (e) {
                //
              }
              if (data['call_type'] == 'audio') {
                try {
                  await _room!.localParticipant?.setCameraEnabled(false);
                } catch (e) {
                  //
                }
              }
              try {
                await _room!.localParticipant?.setMicrophoneEnabled(
                  !data['muted'],
                );
              } catch (e) {
                //
              }
            }
            // _groupCallingDatetime = DateTime.now();
          }

          break;

        case "loaded_group_callers":
          _livekitStreamingController.setActiveCalls([
            ...data['group_callers'],
          ]);
          break;
        case "switch_position":
          _applyPositionSwitch(
            sourceUid: _toInt(data['uid']),
            targetUid: _toInt(data['target_uid']),
          );
          break;
        case "participant_joined":
          dynamic userJoinedData = data;
          if (userJoinedData != null) {
            if (widget.isBroadcaster &&
                _authController.profile.value.blocks!.contains(
                  userJoinedData['uid'],
                )) {
              // Get Out participant
              dynamic actionData = {
                "action": "restrict_live",
                "uid": userJoinedData['uid'],
              };
              onUpdateAction(actionData);
            } else {
              _queueEntryEffectForParticipant(userJoinedData);
              userJoinedData['datetime'] = DateTime.now().toIso8601String();
              dynamic activityData = {
                "type": "joined",
                "uid": userJoinedData['uid'],
                "full_name": userJoinedData["full_name"],
                "profile_image": userJoinedData["profile_image"],
                "level": userJoinedData["level"],
                "vvip_or_vip_preference":
                    userJoinedData["vvip_or_vip_preference"],
              };
              _livekitStreamingController.listUserJoinedAnimation.insert(
                0,
                userJoinedData,
              );
              _showUpActivity(data: activityData);
            }
          }
          // load all participants for newly connected user
          if (data['uid'] == _authController.profile.value.user!.uid!) {
            _livekitStreamingController.loadLivekitParticipantList(
              channelName: widget.channelName,
              onUpdateAction: onUpdateAction,
              fromLiveRoom: true,
            );
          } else if (_livekitStreamingController.viewers.indexWhere(
                (element) => element['uid'] == data['uid'],
              ) <
              0) {
            // load all participants for existing connected user
            _livekitStreamingController.viewers.add(userJoinedData);
            _useIsolateSortingUserJoined(
              listViewers: _livekitStreamingController.viewers.toList(),
            );
          }

          break;
        case "sort_contribution_diamonds":
          dynamic userJoinedData = data;
          // load all participants for newly connected user
          if (data['uid'] != _myUid) {
            _livekitStreamingController.viewers.removeWhere(
              (element) => element['uid'] == data['uid'],
            );
            // load all participants for existing connected user
            _livekitStreamingController.viewers.add(userJoinedData);
            _useIsolateSortingUserJoined(
              listViewers: _livekitStreamingController.viewers.toList(),
            );
          }
          break;
        // User joined or Leave to Streaming
        case "user_joined":
          data['datetime'] = DateTime.now().toIso8601String();
          _livekitStreamingController.listUserJoinedAnimation.insert(0, data);
          break;
        case "user_offline":
          // Removing from all request
          _livekitStreamingController.listRequestedCall.removeWhere(
            (element) => element['uid'] == data['uid'],
          );

          break;
        case 'followers':
          // Notes: data['uid'] is the following to User ID
          // Update on Owner side
          if (_myUid == data['uid']) {
            Profile profile = _authController.profile.value;
            profile.followers = data['followers'];
            _authController.profile.value = Profile();
            _authController.profile.value = profile;
            _authController.preferences.setString(
              'profile',
              jsonEncode(profile.toJson()),
            );
          }
          // Update on Live Streaming
          if (data['uid'] == int.parse(widget.channelName)) {
            // jump
            _livekitStreamingController.setFollowerList(data['followers']);
          }
          if (_livekitStreamingController.listActiveCall.isNotEmpty) {
            int index = _livekitStreamingController.listActiveCall.indexWhere(
              (element) => element['uid'] == data['uid'],
            );
            if (index > -1) {
              dynamic activeCall =
                  _livekitStreamingController.listActiveCall[index];
              activeCall['followers'] = data['followers'];
              _livekitStreamingController.listActiveCall.removeAt(index);
              _livekitStreamingController.listActiveCall.insert(
                index,
                activeCall,
              );
              // if (widget.isBroadcaster) {

              // }
            }
          }

          break;
        case 'blocks':
          // Update on Owner side
          if (_myUid == int.parse(widget.channelName)) {
            _livekitStreamingController.setBlockList(data['blocks']);

            Profile profile = _authController.profile.value;
            profile.blocks = data['blocks'];
            _authController.profile.value = Profile();
            _authController.profile.value = profile;
            _authController.preferences.setString(
              'profile',
              jsonEncode(profile.toJson()),
            );
          } else if (data['uid'] == _myUid) {
            // Working Blocks
            if (_livekitStreamingController.listActiveCall.indexWhere(
                  (element) => element['uid'] == data['uid'],
                ) !=
                -1) {
              dynamic actionData = {"action": "end_call", "uid": data['uid']};
              onUpdateAction(actionData);
              LiveRoomIsolationActions.useIsolateUpdateLiveRoom(
                submissionData:
                    LiveRoomUpdateRequest.removeUserFromCallingGroup(
                      channelId: int.parse(widget.channelName),
                      uid: int.parse(data['uid'].toString()),
                    ),
              );
            }
            // _onCallEnd(context);
            _closeEverything();

            // Get.off(() => NavView());
          }
          break;
        case 'locked_duration':
          break;
        // case 'duration':
        //   _performOnRunningTimeClock(durationFormat: data['duration_format']);
        //   break;
        case 'end_streaming':
          try {
            if (_myUid != int.parse(widget.channelName)) {
              // _onCallEnd(context);
              _closeEverything();

              // Get.off(() => NavView());
            }
          } catch (e) {
            //
          }
          break;
        case 'restrict_live':
          if (data['uid'] == _authController.profile.value.user!.uid) {
            _closeEverything();
          }

          break;
        case 'moderator_end_streaming':
          _closeEverything();
          break;
        case 'close_everything':
          _closeEverything();
          if (widget.isBroadcaster) {
            // Device is blocked
            _authController.preferences.setString('token', '');
            _authController.preferences.setString('profile', '');
            // _authController.preferences.clear();
            // Get.offAllNamed(Routes.AUTH);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => NavView()),
              (route) => false,
            );
            _authController.token.value = '';
            _authController.tryToSignOut();
          }
          break;
        case 'emoji_send':
          data['datetime'] = DateTime.now().toIso8601String();
          _receiveEmojiFormSender(data: data);
          break;
        case 'activity':
          if (data != null) {
            data['datetime'] = DateTime.now().toIso8601String();
            _showUpActivity(data: data);
          }
          break;
        case 'allow_comment_emoji_send':
          _livekitStreamingController.allowCommentAndEmojiSend.value =
              data['allow_send'] ?? true;
          break;
        default:
      }
    }
  }

  void _performOnRunningTimeClock({required String durationFormat}) {
    _livekitStreamingController.setLiveRunningDurationFormat(durationFormat);
  }

  void _queueEntryEffectForParticipant(dynamic participantData) {
    if (participantData is! Map) {
      return;
    }

    var effect = EntryEffect.fromDynamic(participantData['entry_effect']);
    if (effect == null) {
      final preference = participantData['vvip_or_vip_preference'];
      if (preference is Map) {
        effect = EntryEffect.fromDynamic(preference['entry_effect']);
      } else if (preference is String) {
        try {
          final decodedPreference = jsonDecode(preference);
          if (decodedPreference is Map) {
            effect = EntryEffect.fromDynamic(decodedPreference['entry_effect']);
          }
        } catch (_) {
          // Ignore an invalid legacy preference value.
        }
      }
    }

    if (effect == null || !effect.isActive) {
      return;
    }

    _entryEffectQueue.add(
      _RoomEntryEffect(
        effect: effect,
        userName: participantData['full_name']?.toString(),
      ),
    );
    _showNextEntryEffect();
  }

  void _showNextEntryEffect() {
    if (_isDisposed || !mounted || _activeEntryEffect != null) {
      return;
    }
    if (_entryEffectQueue.isEmpty) {
      return;
    }

    final nextEffect = _entryEffectQueue.removeAt(0);
    setState(() => _activeEntryEffect = nextEffect);
    final source = AnimatedMediaSource.fromUrls(
      svga: nextEffect.effect.svgaUrl,
      gif: nextEffect.effect.gifUrl,
    );
    if (source.isPlayable) {
      // Only limit loading. Once playback starts, the media's completion event
      // advances the queue, regardless of the animation's length.
      _entryEffectTimer = Timer(const Duration(seconds: 30), () {
        unawaited(_finishCurrentEntryEffect(nextEffect));
      });
    } else {
      unawaited(_playEntryEffectAudio(nextEffect));
      _entryEffectTimer = Timer(const Duration(seconds: 3), () {
        unawaited(_finishCurrentEntryEffect(nextEffect));
      });
    }
  }

  bool _isCurrentEntryEffect(_RoomEntryEffect entry) =>
      mounted && !_isDisposed && identical(_activeEntryEffect, entry);

  void _onEntryEffectStarted(_RoomEntryEffect entry) {
    if (!_isCurrentEntryEffect(entry) || _entryEffectFinishing) return;
    _entryEffectTimer?.cancel();
    _entryEffectTimer = null;
    unawaited(_playEntryEffectAudio(entry));
  }

  Future<void> _playEntryEffectAudio(_RoomEntryEffect entry) async {
    final audioUrl = entry.effect.audioUrl;
    if (audioUrl == null ||
        !_isCurrentEntryEffect(entry) ||
        _entryEffectFinishing) {
      return;
    }

    final player = AudioPlayer(
      playerId: 'entry-effect-${DateTime.now().microsecondsSinceEpoch}',
    );
    _entryEffectAudioPlayer = player;
    try {
      await player.play(UrlSource(audioUrl), volume: .6);
    } catch (_) {
      if (identical(_entryEffectAudioPlayer, player)) {
        await _disposeEntryEffectAudio();
      }
    }
  }

  Future<void> _finishCurrentEntryEffect(_RoomEntryEffect entry) async {
    if (!_isCurrentEntryEffect(entry) || _entryEffectFinishing) return;
    _entryEffectFinishing = true;
    _entryEffectTimer?.cancel();
    _entryEffectTimer = null;
    await _disposeEntryEffectAudio();
    if (!_isCurrentEntryEffect(entry)) {
      return;
    }
    setState(() {
      _activeEntryEffect = null;
      _entryEffectFinishing = false;
    });
    _showNextEntryEffect();
  }

  Future<void> _disposeEntryEffectAudio() async {
    final player = _entryEffectAudioPlayer;
    _entryEffectAudioPlayer = null;
    if (player == null) {
      return;
    }
    try {
      await player.stop();
      await player.release();
      await player.dispose();
    } catch (_) {
      // The player may already have been released by the platform.
    }
  }

  Widget _buildEntryEffectOverlay(_RoomEntryEffect roomEntryEffect) {
    final effect = roomEntryEffect.effect;
    final source = AnimatedMediaSource.fromUrls(
      svga: effect.svgaUrl,
      gif: effect.gifUrl,
    );
    final effectTitle = effect.title ?? 'Special Entry';
    final userName = roomEntryEffect.userName?.trim();

    return IgnorePointer(
      child: ColoredBox(
        color: AppColors.overlayMedium,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 380, maxHeight: 420),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.overlay,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.premium, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (source.isPlayable)
                  Flexible(
                    child: AnimatedMediaWidget(
                      key: ObjectKey(roomEntryEffect),
                      source: source,
                      loop: false,
                      onPlaybackStarted: () =>
                          _onEntryEffectStarted(roomEntryEffect),
                      onCompleted: () =>
                          unawaited(_finishCurrentEntryEffect(roomEntryEffect)),
                      onError: (_) =>
                          unawaited(_finishCurrentEntryEffect(roomEntryEffect)),
                      fit: BoxFit.contain,
                      placeholder: const SizedBox(
                        height: 180,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.premium,
                          ),
                        ),
                      ),
                      errorWidget: const Icon(
                        LucideIcons.sparkles,
                        color: AppColors.premium,
                        size: 100,
                      ),
                    ),
                  )
                else
                  const Icon(
                    LucideIcons.sparkles,
                    color: AppColors.premium,
                    size: 100,
                  ),
                const SizedBox(height: 12),
                Text(
                  userName == null || userName.isEmpty
                      ? effectTitle
                      : '$userName entered with $effectTitle',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.surface,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    _myUid = _authController.profile.value.user!.uid!;
    _liveGroupRoomCount = 1;
    _packageController.ensureKingPackageCatalogLoaded();

    _authController.setShowingOverlay(overlay: false);

    _editingControllerComment = TextEditingController();
    // These must exist before socket events or a control can rebuild the room.
    _timeConsumingTasks();
    _scrollingStuff();
    _loadStateData();
    unawaited(_initializeLiveRoom());
  }

  Future<void> _initializeLiveRoom() async {
    try {
      debugPrint('🟡 LIVE INIT: fetching LiveKit stuffs...');

      await _initLiveKitStuffs();

      debugPrint('✅ LIVE INIT: LiveKit stuffs loaded');

      if (_isDisposed || !mounted) {
        return;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ LIVE INIT ERROR: $e');
      debugPrint('$stackTrace');
    }
  }

  @override
  void dispose() {
    // _closeEverything();

    _isDisposed = true;
    _cancelRoomTimers();
    _livekitStreamingController.setClearAnimationStuffs();
    unawaited(_disposeEntryEffectAudio());
    _closeActionSocket();
    _animationController?.dispose();
    _editingControllerComment.dispose();
    _focusNode.dispose();
    _scrollController.dispose();

    (() {
      _livekitStreamingController.stopLiveRoomHeartbeat();
      _closeLiveRoom();
      if (widget.isBroadcaster) {
        LiveRoomIsolationActions.useIsolateUpdateLiveRoom(
          submissionData: LiveRoomUpdateRequest.deleteLiveRoom(
            channelId: int.parse(widget.channelName),
          ),
        );
      }
    })();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          body: Container(
            color: AppColors.textPrimary,
            child: Stack(
              children: [
                // Body
                Positioned(
                  top: 54,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _broadcastView(),
                ),
                // Emoji animation items
                ...buildEmojiItems(),
                // Top Diamonds
                Positioned(
                  top: 58,
                  left: 8,
                  right: 0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _livekitStreamingController.setSelectedGift(
                                giftType: '',
                                id: 0,
                              );
                              _livekitStreamingController.setUserInteractTab(
                                tab: 'contributors',
                              );

                              showUserInteractBottomSheet(
                                context: context,
                                data: {
                                  'uid': int.parse(widget.channelName),
                                  'full_name': widget.fullName,
                                  'profile_image': widget.profileImage,
                                  'vvip_or_vip_preference': _hostVipPreference,
                                },
                                onUpdateAction: onUpdateAction,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                color: AppColors.overlay,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    LucideIcons.gem,
                                    color: AppColors.onMedia,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 8),
                                  Obx(() {
                                    return Text(
                                      '${_livekitStreamingController.broadcasterDiamonds.value}',
                                      style: const TextStyle(
                                        color: AppColors.surface,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Stars
                          Container(
                            padding: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              color: AppColors.overlay,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Obx(() {
                              return Row(
                                children: [
                                  const Icon(
                                    LucideIcons.sparkles,
                                    color: AppColors.premium,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${_livekitStreamingController.broadcasterDiamonds.value < 100000 ? 0 : (_livekitStreamingController.broadcasterDiamonds.value / 100000).floor()}',
                                    style: const TextStyle(
                                      color: AppColors.onMedia,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                          const SizedBox(width: 16),
                          GestureDetector(
                            onTap: () {
                              _livekitStreamingController.setCallTab(
                                tabName: 'views',
                              );
                              showCallWaitingBottomSheet(
                                context: context,
                                data: {'package_theme_gif': null},
                                streamingController:
                                    _livekitStreamingController,
                                authController: _authController,
                                onUpdateAction: onUpdateAction,
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                color: AppColors.overlay,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    LucideIcons.eye,
                                    color: AppColors.onMedia,
                                    size: 15,
                                  ),
                                  const SizedBox(width: 8),
                                  Obx(() {
                                    return Text(
                                      '${_livekitStreamingController.viewersCount.value}',
                                      style: const TextStyle(
                                        color: AppColors.surface,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                          // Close Stream only for Moderator access
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Obx(() {
                                  final hasLiveRoomControlAccess =
                                      _hasLiveRoomControlAccess;
                                  if (widget.isBroadcaster ||
                                      !hasLiveRoomControlAccess) {
                                    return Container();
                                  }

                                  return LiveRoomIconButton(
                                    icon: LucideIcons.x,
                                    label: 'End live room',
                                    backgroundColor: AppColors.premium,
                                    iconColor: AppColors.premiumText,
                                    onPressed: () {
                                      rShowAlertDialog(
                                        context: context,
                                        title: 'Room control',
                                        content: 'Do you wanna close Live?',
                                        onConfirm: () {
                                          LiveRoomIsolationActions.useIsolateUpdateLiveRoom(
                                            submissionData:
                                                LiveRoomUpdateRequest.deleteLiveRoom(
                                                  channelId: int.parse(
                                                    widget.channelName,
                                                  ),
                                                ),
                                          );

                                          dynamic userData = {
                                            'action': 'moderator_end_streaming',
                                          };

                                          onUpdateAction(userData);

                                          Navigator.pop(context);
                                        },
                                      );
                                    },
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                      _buildMarquee(),
                    ],
                  ),
                ),
                // Top Nav
                Positioned(
                  top: 8,
                  left: 4,
                  right: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          showUserInfoBottomSheet(
                            context: context,
                            data: {
                              'uid': int.parse(widget.channelName),
                              'full_name': widget.fullName,
                              'profile_image': widget.profileImage,
                              'vvip_or_vip_preference': _hostVipPreference,
                            },
                            onUpdateAction: onUpdateAction,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          decoration: BoxDecoration(
                            color: AppColors.textSecondary,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 28,
                                height: 28,
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          100.0,
                                        ),
                                        border: Border.all(
                                          width: 2.0,
                                          color: AppColors.warning,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                          100.0,
                                        ),
                                        child: widget.profileImage == null
                                            ? Image.asset(
                                                'assets/others/person.jpg',
                                                width:
                                                    _hostVipPreference['vvip_or_vip_gif'] !=
                                                        null
                                                    ? 22
                                                    : 28,
                                                height:
                                                    _hostVipPreference['vvip_or_vip_gif'] !=
                                                        null
                                                    ? 22
                                                    : 28,
                                                fit: BoxFit.cover,
                                              )
                                            : CachedNetworkImage(
                                                imageUrl:
                                                    '${widget.profileImage}',
                                                width:
                                                    _hostVipPreference['vvip_or_vip_gif'] !=
                                                        null
                                                    ? 22
                                                    : 28,
                                                height:
                                                    _hostVipPreference['vvip_or_vip_gif'] !=
                                                        null
                                                    ? 22
                                                    : 28,
                                                fit: BoxFit.cover,
                                                placeholder: (context, url) =>
                                                    const Center(
                                                      child:
                                                          CircularProgressIndicator(
                                                            color:
                                                                AppColors.error,
                                                          ),
                                                    ),
                                              ),
                                      ),
                                    ),
                                    _hostVipPreference['vvip_or_vip_gif'] !=
                                            null
                                        ? Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: AppColors.overlay,
                                                // borderRadius: BorderRadius.only(
                                                //   bottomLeft: Radius.circular(20.0),
                                                //   bottomRight: Radius.circular(20.0),
                                                // ),
                                                border: Border.all(
                                                  color: AppColors.warning,
                                                  // width: 2.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      100.0,
                                                    ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      100.0,
                                                    ),
                                                child: CachedNetworkImage(
                                                  imageUrl:
                                                      _hostVipPreference['vvip_or_vip_gif'],
                                                  width: 14,
                                                  height: 14,
                                                ),
                                              ),
                                            ),
                                          )
                                        : Container(),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4.0),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 100,
                                    ),
                                    child: Text(
                                      // data['full_name'],
                                      '${widget.fullName}',
                                      overflow: TextOverflow.ellipsis,
                                      // textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: AppColors.surface,
                                        fontWeight: FontWeight.w700,
                                        // backgroundColor: AppColors.overlayLight,
                                      ),
                                    ),
                                  ),
                                  Obx(() {
                                    return Text(
                                      _livekitStreamingController
                                          .liveRunningDuration
                                          .value,
                                      style: const TextStyle(
                                        color: AppColors.surface,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                        // backgroundColor: AppColors.overlayLight,
                                      ),
                                    );
                                  }),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Viewer List
                      Expanded(
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.only(left: 4),
                          child: Obx(() {
                            return ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount:
                                  _livekitStreamingController.viewers.length,
                              itemBuilder: (context, index) {
                                final dynamic data =
                                    _livekitStreamingController.viewers[index];

                                return GestureDetector(
                                  onTap: () {
                                    showUserInfoBottomSheet(
                                      context: context,
                                      data: data,
                                      onUpdateAction: onUpdateAction,
                                    );
                                  },
                                  child: Center(
                                    child: VipProfileAvatar(
                                      profileImage:
                                          data['profile_image'] ??
                                          data['photo_url'],
                                      vipPreference:
                                          data['vvip_or_vip_preference'],
                                      frameSize: 42,
                                      unframedSize: 30,
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) =>
                                  const SizedBox(width: 4),
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ),
                // Top Close
                Positioned(
                  top: 4,
                  right: 0,
                  child: LiveRoomIconButton(
                    icon: LucideIcons.x,
                    label: 'Leave live room',
                    // onPressed: () => Get.back(),
                    onPressed: () {
                      rShowAlertDialog(
                        context: context,
                        title: 'Close',
                        content: 'Do you wanna close?',
                        onConfirm: _closeStreamingEvent,
                      );
                    },
                  ),
                ),

                // Comments Show
                Positioned(
                  bottom: 56,
                  left: 8,
                  right: 86,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * .27,
                    child: _commentView(),
                  ),
                ),

                // Normal Gifts Show
                Obx(() {
                  return _livekitStreamingController
                          .listNormalGiftSend
                          .isNotEmpty
                      ? Positioned(
                          top: 108,
                          bottom: MediaQuery.of(context).size.height * .22,
                          left: 16,
                          right: 16,
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _livekitStreamingController
                                .listNormalGiftSend
                                .length,
                            itemBuilder: (context, index) {
                              return _giftSendAnimationView(
                                data: _livekitStreamingController
                                    .listNormalGiftSend[index],
                              );
                            },
                          ),
                        )
                      : Container();
                }),
                // Animation Gift Send
                Obx(() {
                  final playbackId =
                      _livekitStreamingController.animatedGiftPlaybackId.value;
                  return _livekitStreamingController.showGiftSendAnimation.value
                      ? Positioned(
                          top: 80,
                          left: 0,
                          right: 0,
                          bottom: 80,
                          child: AnimatedMediaWidget(
                            key: ValueKey<int>(playbackId),
                            source: _getAnimatedGiftMedia(),
                            loop: false,
                            onPlaybackStarted: () => _livekitStreamingController
                                .onAnimatedGiftPlaybackStarted(playbackId),
                            onCompleted: () => unawaited(
                              _livekitStreamingController.finishAnimatedGift(
                                playbackId,
                              ),
                            ),
                            onError: (_) => unawaited(
                              _livekitStreamingController.finishAnimatedGift(
                                playbackId,
                              ),
                            ),
                            fit: BoxFit.contain,
                            placeholder: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        )
                      : Container();
                }),
                // Bottom Actions
                Positioned(
                  left: 8,
                  right: 4,
                  bottom: 4,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Comments
                        Container(
                          width: 220,
                          constraints: const BoxConstraints(
                            minHeight: 40,
                            maxHeight: 64,
                          ),
                          margin: const EdgeInsets.only(right: 4.0),
                          child: Obx(() {
                            // Read the Rx value before applying the broadcaster
                            // override so Obx always registers a dependency.
                            final roomAllowsComments =
                                _livekitStreamingController
                                    .allowCommentAndEmojiSend
                                    .value;
                            final commentsAllowed =
                                widget.isBroadcaster || roomAllowsComments;
                            return rPrimaryTextField(
                              controller: _editingControllerComment,
                              focusNode: _focusNode,
                              readOnly: !commentsAllowed,
                              keyboardType: TextInputType.multiline,
                              maxLines: 2,
                              borderColor: AppColors.transparent,
                              borderRadius: 22,
                              fillColor: AppColors.overlay,
                              textColor: AppColors.onMediaMuted,
                              hintText: commentsAllowed
                                  ? 'Write your comment'
                                  : 'Comments are disabled',
                              helpTextColor: AppColors.onMediaMuted,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              suffixIcon: IconButton(
                                padding: EdgeInsets.zero,
                                onPressed: commentsAllowed
                                    ? _sendComment
                                    : null,
                                tooltip: 'Send comment',
                                icon: const Icon(LucideIcons.send, size: 19),
                              ),
                            );
                          }),
                        ),
                        // Gifts
                        LiveRoomIconButton(
                          icon: LucideIcons.gift,
                          label: 'Send a gift',
                          onPressed: () {
                            _livekitStreamingController.setSelectedGift(
                              giftType: '',
                              id: 0,
                            );
                            _livekitStreamingController.setUserInteractTab(
                              tab: 'gifts',
                            );

                            showUserInteractBottomSheet(
                              context: context,
                              data: {
                                'uid': int.parse(widget.channelName),
                                'full_name': widget.fullName,
                                'profile_image': widget.profileImage,
                                'vvip_or_vip_preference': _hostVipPreference,
                              },
                              onUpdateAction: onUpdateAction,
                            );
                          },
                        ),
                        // Join
                        GestureDetector(
                          onTap: () {
                            _livekitStreamingController.setCallTab(
                              tabName: 'waiting',
                            );
                            showCallWaitingBottomSheet(
                              context: context,
                              data: {'package_theme_gif': null},
                              streamingController: _livekitStreamingController,
                              authController: _authController,
                              onUpdateAction: onUpdateAction,
                            );
                          },
                          child: SizedBox(
                            width: 46,
                            height: 46,
                            child: Stack(
                              children: [
                                Center(
                                  child: LiveRoomIconButton(
                                    onPressed: () {
                                      _livekitStreamingController.setCallTab(
                                        tabName: 'waiting',
                                      );
                                      showCallWaitingBottomSheet(
                                        context: context,
                                        data: {'package_theme_gif': null},
                                        streamingController:
                                            _livekitStreamingController,
                                        authController: _authController,
                                        onUpdateAction: onUpdateAction,
                                      );
                                    },
                                    icon: LucideIcons.phone,
                                    label: 'Join live call',
                                    size: 40,
                                    iconSize: 19,
                                    backgroundColor: AppColors.success,
                                    iconColor: AppColors.surface,
                                  ),
                                ),
                                Obx(() {
                                  if (_livekitStreamingController
                                      .listRequestedCall
                                      .isEmpty) {
                                    return Container();
                                  }
                                  return Positioned(
                                    top: 8,
                                    right: 2,
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: AppColors.error,
                                        borderRadius: BorderRadius.circular(
                                          100.0,
                                        ),
                                      ),
                                      child: Text(
                                        '${_livekitStreamingController.listRequestedCall.length}',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: AppColors.surface,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                        // 👍 thumbsup
                        GestureDetector(
                          onTap: () {
                            if (!widget.isBroadcaster &
                                !_livekitStreamingController
                                    .allowCommentAndEmojiSend
                                    .value) {
                              return;
                            }
                            // final emojis = Emoji.byKeyword('like');
                            // for (Emoji emoji in emojis) {
                            //   print('${emoji.char} ${emoji.shortName}\n');
                            // }

                            // return;
                            // Working Emoji
                            // int randomNumber = random.nextInt(100); // from 0 upto 99 included
                            int randomNumber = _random.nextInt(
                              listEmojiLikeKeywordName.length,
                            );
                            Emoji? emoji = Emoji.byShortName(
                              listEmojiLikeKeywordName[randomNumber],
                            );

                            String emojiName = emoji!.shortName;

                            onUpdateAction({
                              'action': 'emoji_send',
                              'type': 'emoji',
                              'emoji': '',
                              'uid': _authController.profile.value.user!.uid!,
                              'full_name':
                                  _authController.profile.value.full_name,
                              'level': _authController.profile.value.level,
                              'profile_image':
                                  _authController.profile.value.profile_image ??
                                  _authController.profile.value.photo_url,
                              'list_emoji_name': [emojiName],
                              'list_emoji_count': [1],
                              'diamonds':
                                  _authController.profile.value.diamonds,
                              'is_moderator':
                                  _authController.profile.value.is_moderator,
                              'is_reseller':
                                  _authController.profile.value.is_reseller,
                              'vvip_or_vip_preference': _authController
                                  .profile
                                  .value
                                  .vvip_or_vip_preference,
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2.0),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: AppColors.overlay,
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                            child: Text(
                              Emoji.byShortName('thumbsup')!.char,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        //  💖 sparkling_heart
                        GestureDetector(
                          onTap: () {
                            if (!widget.isBroadcaster &
                                !_livekitStreamingController
                                    .allowCommentAndEmojiSend
                                    .value) {
                              return;
                            }
                            int randomNumber = _random.nextInt(
                              listEmojiHeartKeywordName.length,
                            );
                            Emoji? emoji = Emoji.byShortName(
                              listEmojiHeartKeywordName[randomNumber],
                            );

                            onUpdateAction({
                              'action': 'emoji_send',
                              'type': 'emoji',
                              'emoji': '',
                              'uid': _authController.profile.value.user!.uid!,
                              'full_name':
                                  _authController.profile.value.full_name,
                              'level': _authController.profile.value.level,
                              'profile_image':
                                  _authController.profile.value.profile_image ??
                                  _authController.profile.value.photo_url,
                              'list_emoji_name': [emoji!.shortName],
                              'list_emoji_count': [1],
                              'diamonds':
                                  _authController.profile.value.diamonds,
                              'is_moderator':
                                  _authController.profile.value.is_moderator,
                              'is_reseller':
                                  _authController.profile.value.is_reseller,
                              'vvip_or_vip_preference': _authController
                                  .profile
                                  .value
                                  .vvip_or_vip_preference,
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2.0),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: AppColors.overlay,
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                            child: Text(
                              Emoji.byShortName('sparkling_heart')!.char,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        // 🥰 smiling_face_with_3_hearts
                        GestureDetector(
                          onTap: () {
                            if (!widget.isBroadcaster &
                                !_livekitStreamingController
                                    .allowCommentAndEmojiSend
                                    .value) {
                              return;
                            }
                            int randomNumber = _random.nextInt(
                              listEmojiSmileKeywordName.length,
                            );
                            Emoji? emoji = Emoji.byShortName(
                              listEmojiSmileKeywordName[randomNumber],
                            );

                            onUpdateAction({
                              'action': 'emoji_send',
                              'type': 'emoji',
                              'emoji': '',
                              'uid': _authController.profile.value.user!.uid!,
                              'full_name':
                                  _authController.profile.value.full_name,
                              'level': _authController.profile.value.level,
                              'profile_image':
                                  _authController.profile.value.profile_image ??
                                  _authController.profile.value.photo_url,
                              'list_emoji_name': [emoji!.shortName],
                              'list_emoji_count': [1],
                              'diamonds':
                                  _authController.profile.value.diamonds,
                              'is_moderator':
                                  _authController.profile.value.is_moderator,
                              'is_reseller':
                                  _authController.profile.value.is_reseller,
                              'vvip_or_vip_preference': _authController
                                  .profile
                                  .value
                                  .vvip_or_vip_preference,
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2.0),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: AppColors.overlay,
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                            child: Text(
                              Emoji.byShortName(
                                'smiling_face_with_3_hearts',
                              )!.char,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        // 🤣 rofl
                        GestureDetector(
                          onTap: () {
                            if (!widget.isBroadcaster &
                                !_livekitStreamingController
                                    .allowCommentAndEmojiSend
                                    .value) {
                              return;
                            }
                            int randomNumber = _random.nextInt(
                              listEmojiHaHaKeywordName.length,
                            );
                            Emoji? emoji = Emoji.byShortName(
                              listEmojiHaHaKeywordName[randomNumber],
                            );

                            onUpdateAction({
                              'action': 'emoji_send',
                              'type': 'emoji',
                              'emoji': '',
                              'uid': _authController.profile.value.user!.uid!,
                              'full_name':
                                  _authController.profile.value.full_name,
                              'level': _authController.profile.value.level,
                              'profile_image':
                                  _authController.profile.value.profile_image ??
                                  _authController.profile.value.photo_url,
                              'list_emoji_name': [emoji!.shortName],
                              'list_emoji_count': [1],
                              'diamonds':
                                  _authController.profile.value.diamonds,
                              'is_moderator':
                                  _authController.profile.value.is_moderator,
                              'is_reseller':
                                  _authController.profile.value.is_reseller,
                              'vvip_or_vip_preference': _authController
                                  .profile
                                  .value
                                  .vvip_or_vip_preference,
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(2.0),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: AppColors.overlay,
                              borderRadius: BorderRadius.circular(100.0),
                            ),
                            child: Text(
                              Emoji.byShortName('rofl')!.char,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Bottom Right Action
                Positioned(
                  bottom: 64,
                  right: 8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Share
                      // LiveRoomIconButton(
                      //   icon: LucideIcons.share2,
                      //   label: 'Share live room',
                      //   backgroundColor: Theme.of(context).primaryColor,
                      //   iconColor: AppColors.onMediaMuted,
                      //   onPressed: () {
                      //     HelperFunctions().buildDynamicLinksForLiveStreaming(
                      //       title: _livekitStreamingController
                      //           .broadcasterFullname
                      //           .value,
                      //       description: 'Is Live Now',
                      //       image: _livekitStreamingController
                      //           .broadcasterProfileImage
                      //           .value,
                      //       channelId: widget.channelName,
                      //     );
                      //   },
                      // ),
                      !widget.isBroadcaster
                          ? Container()
                          : Obx(() {
                              final isExpanded = _livekitStreamingController
                                  .expandMediaController
                                  .value;
                              final activeCallCount =
                                  _livekitStreamingController
                                      .listActiveCall
                                      .length;
                              if (!isExpanded || activeCallCount < 2) {
                                return Container();
                              }
                              return LiveRoomIconButton(
                                onPressed: _onHostSwitchPosition,
                                icon: LucideIcons.arrowUpDown,
                                label: 'Swap guest position',
                                iconColor: AppColors.onMediaMuted,
                              );
                            }),
                      // Allow Comment and Emoji sends
                      !widget.isBroadcaster
                          ? Container()
                          : Obx(() {
                              if (!_livekitStreamingController
                                  .expandMediaController
                                  .value) {
                                return Container();
                              }
                              return LiveRoomIconButton(
                                onPressed: () {
                                  bool allowSend = _livekitStreamingController
                                      .allowCommentAndEmojiSend
                                      .value;
                                  _livekitStreamingController
                                          .allowCommentAndEmojiSend
                                          .value =
                                      !allowSend;
                                  onUpdateAction({
                                    'action': 'allow_comment_emoji_send',
                                    'allow_send': !allowSend,
                                  });
                                  LiveRoomIsolationActions.useIsolateUpdateLiveRoom(
                                    submissionData:
                                        LiveRoomUpdateRequest.fromMap({
                                          'action': 'allow_comment_emoji_send',
                                          'channel_id': int.parse(
                                            widget.channelName,
                                          ),
                                          'allow_send': !allowSend,
                                        }),
                                  );
                                },
                                icon:
                                    _livekitStreamingController
                                        .allowCommentAndEmojiSend
                                        .value
                                    ? LucideIcons.messageCircle
                                    : LucideIcons.messageCircleOff,
                                label:
                                    _livekitStreamingController
                                        .allowCommentAndEmojiSend
                                        .value
                                    ? 'Disable comments and reactions'
                                    : 'Enable comments and reactions',
                                iconColor:
                                    _livekitStreamingController
                                        .allowCommentAndEmojiSend
                                        .value
                                    ? AppColors.success
                                    : AppColors.error,
                              );
                            }),
                      // Audio Mute
                      Obx(() {
                        if (!_livekitStreamingController
                                .expandMediaController
                                .value ||
                            _livekitStreamingController.listActiveCall
                                    .indexWhere(
                                      (element) =>
                                          element['uid'] ==
                                          _authController
                                              .profile
                                              .value
                                              .user!
                                              .uid!,
                                    ) ==
                                -1) {
                          return Container();
                        }
                        return LiveRoomIconButton(
                          onPressed: _onToggleMute,
                          icon: _livekitStreamingController.muted.value
                              ? LucideIcons.micOff
                              : LucideIcons.mic,
                          label: _livekitStreamingController.muted.value
                              ? 'Unmute microphone'
                              : 'Mute microphone',
                          iconColor: _livekitStreamingController.muted.value
                              ? AppColors.error
                              : AppColors.onMediaMuted,
                        );
                      }),
                      // Camera On/Off
                      Obx(() {
                        if (!_livekitStreamingController
                                .expandMediaController
                                .value ||
                            _livekitStreamingController.listActiveCall
                                    .indexWhere(
                                      (element) =>
                                          element['uid'] ==
                                          _authController
                                              .profile
                                              .value
                                              .user!
                                              .uid!,
                                    ) ==
                                -1) {
                          return Container();
                        }
                        return LiveRoomIconButton(
                          onPressed: _onToggleVideoEnable,
                          icon: _livekitStreamingController.videoDisabled.value
                              ? LucideIcons.videoOff
                              : LucideIcons.video,
                          label: _livekitStreamingController.videoDisabled.value
                              ? 'Turn camera on'
                              : 'Turn camera off',
                          iconColor:
                              _livekitStreamingController.videoDisabled.value
                              ? AppColors.error
                              : AppColors.onMediaMuted,
                        );
                      }),
                      // Camera Switch
                      Obx(() {
                        if (!_livekitStreamingController
                                .expandMediaController
                                .value ||
                            _livekitStreamingController.videoDisabled.value ||
                            _livekitStreamingController.listActiveCall
                                    .indexWhere(
                                      (element) =>
                                          element['uid'] ==
                                          _authController
                                              .profile
                                              .value
                                              .user!
                                              .uid!,
                                    ) ==
                                -1) {
                          return Container();
                        }
                        return LiveRoomIconButton(
                          onPressed: _onSwitchCamera,
                          icon: LucideIcons.switchCamera,
                          label: 'Switch camera',
                          iconColor: AppColors.onMediaMuted,
                        );
                      }),
                      Obx(() {
                        if (_livekitStreamingController.listActiveCall
                                .indexWhere(
                                  (element) =>
                                      element['uid'] ==
                                      _authController.profile.value.user!.uid!,
                                ) ==
                            -1) {
                          return Container();
                        }
                        return LiveRoomIconButton(
                          onPressed: () {
                            _livekitStreamingController
                                .expandMediaController
                                .value = !_livekitStreamingController
                                .expandMediaController
                                .value;
                          },
                          icon:
                              !_livekitStreamingController
                                  .expandMediaController
                                  .value
                              ? LucideIcons.chevronUp
                              : LucideIcons.chevronDown,
                          label:
                              !_livekitStreamingController
                                  .expandMediaController
                                  .value
                              ? 'Show call controls'
                              : 'Hide call controls',
                          iconColor:
                              !_livekitStreamingController
                                  .expandMediaController
                                  .value
                              ? AppColors.onMediaMuted
                              : AppColors.warning,
                          backgroundColor: AppColors.overlay,
                        );
                      }),
                      Container(
                        padding: const EdgeInsets.all(4.0),
                        margin: const EdgeInsets.only(top: 4, right: 8),
                        decoration: BoxDecoration(
                          color: AppColors.overlay,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              LucideIcons.heart,
                              color: AppColors.onMediaMuted,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Obx(() {
                              return Text(
                                '${_livekitStreamingController.loveReacts.value}',
                                style: const TextStyle(
                                  color: AppColors.onMediaMuted,
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (_activeEntryEffect != null)
                  Positioned.fill(
                    child: _buildEntryEffectOverlay(_activeEntryEffect!),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _initLiveKitStuffs() async {
    // _room = _livekitStreamingController.livekitRoom!;
    // _listener = _livekitStreamingController.roomEventListener!;

    if (await Permission.camera.request().isGranted &&
        await Permission.microphone.request().isGranted) {
      // Either the permission was already granted before or the user just granted it.
      if (defaultTargetPlatform == TargetPlatform.android) {
        await [
          // Permission.microphone,
          // Permission.camera,
          Permission.bluetooth,
          Permission.bluetoothConnect,
        ].request();
      }

      try {
        final credential = await _livekitStreamingController.createLiveKitToken(
          channelName: widget.channelName,
        );
        if (credential == null || _isDisposed || !mounted) {
          return;
        }

        _engineName = credential['engine'];
        _roomToken = credential['token'];
        _serverUrl = credential['server_url'];
        _preferredCodec = credential['codec'];

        final socketBaseUrl = credential['websocket_base_url']
            ?.toString()
            .trim();
        if (socketBaseUrl == null || socketBaseUrl.isEmpty) {
          throw StateError('Missing websocket_base_url in LiveKit credential');
        }
        _liveRoomSocketBaseUrl = socketBaseUrl;
        _livekitStreamingController.liveRoomSocketBaseUrl = socketBaseUrl;
        await initWebSocketClientForActions(forceReconnect: true);

        //create new room
        _room = Room(
          roomOptions: await LivekitStuffs().getRoomOptions(
            preferredCodec: _preferredCodec,
            isHost: widget.isBroadcaster,
            enableHostHDRoom: credential['enable_host_hd_room'] ?? false,
            allowVideoCall: true,
          ),
        );
        // Create a Listener before connecting
        _listener = _room!.createListener();
        await _connectingRoom(token: _roomToken);
        _room!.addListener(_onRoomDidUpdate);
        _setUpEventListeners();
      } catch (e) {
        _livekitStreamingController.busyConnectingEngine.value = false;
      }
    } else {
      _closeEverything();
      openAppSettings();
    }
  }

  Future<void> _connectingRoom({required String token}) async {
    _livekitStreamingController.busyConnectingEngine.value = true;
    // String serverUrl = 'wss://livekit.famousapp.xyz';

    // Try to connect to the room
    // This will throw an Exception if it fails for any reason.
    // Reference: https://docs.livekit.io/client-sdk-flutter/livekit_client/VideoParametersPresets.html

    await _room!.prepareConnection(_serverUrl, token);

    Map<String, dynamic>? pendingLiveData;
    if (widget.isBroadcaster) {
      final myProfile = _authController.profile.value;
      pendingLiveData = {
        "id": 16,
        "channel_id": _myUid,
        "title": widget.fullName,
        "is_pk": false,
        "is_video": true,
        "is_locked": false,
        "allow_send": true,
        "cm_flt_nm": null,
        "owner_profile": {
          "uid": _myUid,
          "full_name": widget.fullName,
          "profile_image": widget.profileImage,
          "cover_image": null,
          "vvip_or_vip_gif": _hostVipPreference['vvip_or_vip_gif'],
          "diamonds": myProfile.diamonds,
          "blocks": myProfile.blocks,
          // "designation": "agent"
        },
        "group_caller_ids": [
          {'uid': _myUid, 'position': 1},
        ],
        "reacts": 0,
        "viewers_count": 0,
        "locked_datetime": null,
        "engine": _engineName,
        "created_datetime": DateTime.now().toIso8601String(),
      };

      LiveRoomIsolationActions.useIsolateUpdateLiveRoom(
        submissionData: LiveRoomUpdateRequest.addLiveRoom(pendingLiveData),
      );
    }

    await _room!
        .connect(
          _serverUrl,
          token,
          fastConnectOptions: _fastConnect || widget.isBroadcaster
              ? FastConnectOptions(
                  microphone: const TrackOption(enabled: true),
                  camera: const TrackOption(enabled: true),
                )
              : null,
        )
        .then(
          (value) async {
            // Room Connected
            if (widget.isBroadcaster) {
              if (_livekitStreamingController.listActiveCall.isEmpty) {
                dynamic callerData = {
                  'uid': _myUid,
                  'full_name': widget.fullName,
                  'profile_image': widget.profileImage,
                  'diamonds': _authController.profile.value.diamonds,
                  'vvip_or_vip_preference':
                      _authController.profile.value.vvip_or_vip_preference,
                  'followers': _authController.profile.value.followers,
                  'muted': false,
                  'video_disabled': false,
                };
                _livekitStreamingController.listActiveCall.insert(
                  0,
                  callerData,
                );

                // // TODO: Testing
                // for (int i = 1; i <= 10; i++) {
                //   _livekitStreamingController.listActiveCall.insert(
                //     i,
                //     callerData,
                //   );
                // }
              }

              final liveData = pendingLiveData ?? <String, dynamic>{};
              _livekitStreamingController.channelName.value = _myUid.toString();
              _livekitStreamingController.liveStreamData.value = liveData;

              // One time History
              LiveRoomIsolationActions.useIsolateToDeleteContributionHistory(
                token: _authController.token.value,
              );
              // _livekitStreamingController.tryToDeleteContributionHistory();
              // Notify followers about Live Streaming
              LiveRoomIsolationActions.useIsolateNotifyFollowerAboutLiveStreaming(
                token: _authController.token.value,
              );
              // // Notify followers about Live Streaming
              // _livekitStreamingController.tryToNotifyFollowerAboutLiveStreaming();
            }
            // await Hardware.instance.setSpeakerphoneOn(true);
            await rtc.Helper.setSpeakerphoneOn(
              _livekitStreamingController.loudSpeaker.value,
            );

            _livekitStreamingController.busyConnectingEngine.value = false;
            if (widget.isBroadcaster) {
              _livekitStreamingController.startLiveRoomHeartbeat(
                channelId: int.parse(widget.channelName),
                onRoomMissing: _handleMissingLiveRoomHeartbeat,
              );
            }
            _renderParticipants();

            // For only participant
            if (!widget.isBroadcaster) {
              dynamic userJoined = {
                'action': 'participant_joined',
                'uid': _myUid,
                'full_name': _authController.profile.value.full_name,
                'profile_image':
                    _authController.profile.value.profile_image ??
                    _authController.profile.value.photo_url,
                'is_moderator': _authController.profile.value.is_moderator,
                'is_reseller': _authController.profile.value.is_reseller,
                'diamonds': _authController.profile.value.diamonds,
                'level': _authController.profile.value.level,
                'vvip_or_vip_preference':
                    _authController.profile.value.vvip_or_vip_preference,
                'entry_effect': _authController.profile.value.entryEffect
                    ?.toJson(),
              };

              onUpdateAction(userJoined);

              if (_listGroupIds.isEmpty) {
                _sortParticipants();
              }
              // broadcasterDiamonds
              _livekitStreamingController.loadGroupCallerList(
                channelId: widget.channelName,
                callerIds: _listGroupIds,
              );
            }
          },
          onError: (error) {
            // _closeEverything();
            // Get.defaultDialog(
            //   title: 'Something is wrong',
            //   middleText: 'Please try again',
            //   titleStyle: const TextStyle(
            //     color: AppColors.warning,
            //   ),
            // );
            if (_isDisposed) return;
            rShowSnackBar(
              context: context,
              title: 'Connection failed. Please try again.',
              color: AppColors.error,
              durationInSeconds: 2,
            );
          },
        );
  }

  /// Video layout wrapper
  Widget _broadcastView() {
    return Obx(() {
      // if (_livekitStreamingController.busyConnectingEngine.value ||
      //     _livekitStreamingController.listRenderView.isEmpty) {
      if (_livekitStreamingController.listRenderView.isEmpty) {
        return Center(
          child: Image.asset('assets/logos/biho.png', width: 100, height: 100),
        );
      } else if (_livekitStreamingController.listRenderView.isNotEmpty &&
          _livekitStreamingController.listActiveCall.isEmpty) {
        return InitialRendererRoomDisplayLayout.initialRendererView(
          screenGlobalWidth: _screenGlobalWidth,
          screenGlobalHeight: _screenGlobalHeight,
          livekitStreamingController: _livekitStreamingController,
        );
      }
      return VideoGroupRoomLayout.generateGroupRooms(
        screenGlobalWidth: _screenGlobalWidth,
        screenGlobalHeight: _screenGlobalHeight,
        channelName: widget.channelName,
        isBroadcaster: widget.isBroadcaster,
        context: context,
        onUpdateAction: onUpdateAction,
        livekitStreamingController: _livekitStreamingController,
        authController: _authController,
      );
    });
  }

  Widget _commentView() {
    return Obx(() {
      return ListView.builder(
        controller: _scrollController,
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: _livekitStreamingController.listCommentLiveStream.length,
        itemBuilder: ((context, index) {
          dynamic data =
              _livekitStreamingController.listCommentLiveStream[index];
          return _commentItemWidget(data: data);
        }),
      );
    });
  }

  void _receiveEmojiFormSender({required dynamic data}) {
    // Working emoji
    // // _generateEmojiFly(data: data, index: 0);
    // int count = 0;
    // for (int i = 0; i < data['list_emoji_name'].length; i++) {
    //   Emoji? emoji = Emoji.byShortName(data['list_emoji_name'][i]);
    //   int tempCount = int.parse(data['list_emoji_count'][i].toString());
    //   count += tempCount;
    //   _livekitStreamingController.loveReacts.value += tempCount;

    //   for (int j = 0; j < tempCount; j++) {
    //     _emojiItems.add(EmojiItem(datetime: data['datetime'], emoji: emoji));
    //   }
    //   if (i + 1 == data['list_emoji_name'].length) {
    //     var emojiData = {
    //       'type': 'emoji',
    //       'uid': data['uid'],
    //       'full_name': data['full_name'],
    //       'level': data['level'],
    //       'profile_image': data['profile_image'],
    //       'emoji': emoji,
    //       'count': count,
    //       'diamonds': data['diamonds'],
    //       'is_moderator': data['is_moderator'],
    //       'is_reseller': data['is_reseller'],
    //     };

    //     _livekitStreamingController.listCommentLiveStream.add(emojiData);
    //     _scrollingCommentsView();
    //   }
    // }

    Emoji? emoji = Emoji.byShortName(data['list_emoji_name'][0]);
    var emojiData = {
      'type': 'emoji',
      'uid': data['uid'],
      'full_name': data['full_name'],
      'level': data['level'],
      'profile_image': data['profile_image'],
      'emoji': emoji,
      'count': 1,
      'diamonds': data['diamonds'],
      'is_moderator': data['is_moderator'],
      'is_reseller': data['is_reseller'],
      'vvip_or_vip_preference': data['vvip_or_vip_preference'],
    };
    _emojiItems.add(EmojiItem(datetime: data['datetime'], emoji: emoji));

    _livekitStreamingController.loveReacts.value += 1;
    _livekitStreamingController.listCommentLiveStream.add(emojiData);
    _scrollingCommentsView();

    if (_animationController != null && !_animationController!.isAnimating) {
      _animationController!.reset();
      _animationController!.forward();
    }
  }

  Widget _buildMarquee() {
    return Obx(() {
      if (_livekitStreamingController.marqueeText.value.isEmpty) {
        return Container();
      }
      return Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.overlay,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Marquee(
          text: _livekitStreamingController.marqueeText.value,
          velocity: 50.0,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.premium,
          ),
          // scrollAxis: Axis.horizontal,
          // crossAxisAlignment: CrossAxisAlignment.end,
          // blankSpace: 20,
          // // pauseAfterRound: const Duration(seconds: 1),
          // showFadingOnlyWhenScrolling: true,
          fadingEdgeStartFraction: 0.1,
          fadingEdgeEndFraction: 0.1,
          startPadding: 16,
          accelerationDuration: const Duration(milliseconds: 1150),
          accelerationCurve: Curves.linear,
          decelerationDuration: const Duration(milliseconds: 1150),
          decelerationCurve: Curves.easeOut,
        ),
      );
    });
  }

  List<Widget> buildEmojiItems() {
    return _emojiItems.map((item) {
      if (item.emoji == null) {
        return Container();
      }
      var tween = Tween<Offset>(
        begin: Offset(Random().nextDouble() * 0.5, 2),
        end: Offset(0, Random().nextDouble() * -1 - 1),
        // begin: Offset(1, 1),
        // end: Offset(0, -0),
      );
      // .chain(CurveTween(curve: Curves.linear));
      return SlideTransition(
        position: _animationController!.drive(tween),
        child: AnimatedAlign(
          alignment: item._alignment!,
          duration: const Duration(seconds: 6),
          child: Text(item.emoji!.char, style: const TextStyle(fontSize: 34)),
          // child: AnimatedContainer(
          //   duration: Duration(seconds: 10),
          //   width: item._size,
          //   height: item._size,
          //   decoration: BoxDecoration(shape: BoxShape.circle),
          //   child: Text(
          //     '${item.emoji!.char}',
          //     style: TextStyle(fontSize: 34),
          //   ),
          // ),
        ),
      );
    }).toList();
  }

  void _onRoomDidUpdate() {
    _renderParticipants();
  }

  // Future<void> _updateBroadcasterStates() async {
  //   if (widget.isBroadcaster) {
  //     _livekitStreamingController.broadcasterDiamonds.value =
  //         _authController.profile.value.diamonds!;

  //     _livekitStreamingController.followers
  //         .addAll(_authController.profile.value.followers!);
  //     _livekitStreamingController.blocks
  //         .addAll(_authController.profile.value.blocks!);
  //   }
  // }

  void _setUpEventListeners() => _listener!
    ..on<LocalTrackPublishedEvent>((_) => _renderParticipants())
    ..on<LocalTrackUnpublishedEvent>((_) => _renderParticipants())
    ..on<TrackPublishedEvent>((_) => _renderParticipants())
    ..on<TrackUnpublishedEvent>((_) => _renderParticipants())
    ..on<DataReceivedEvent>((event) {
      // String decoded = 'Failed to decode';
      dynamic data;
      try {
        String decoded = utf8.decode(event.data);
        data = jsonDecode(decoded)['message'];
        // rShowSnackBar(context: context, title: '$data', color: AppColors.success);
        if (data['gzip'] != null) {
          List<int> gzipDecodedBytes = gzip.decode(data['gzip'].cast<int>());
          Map<String, dynamic> gzipData = jsonDecode(
            utf8.decode(gzipDecodedBytes),
          );
          data['gzip'] = null;
          data = {...data, ...gzipData};
        }
        _takeActionOnReceivedData(data);
      } catch (_) {
        // print('Failed to decode: $_');
      }
      // context.showDataReceivedDialog(decoded);
      // rShowSnackBar(context: context, title: '$data', color: AppColors.success);
    })
    // ..on<TrackSubscribedEvent>((e) {
    //   if (e.publication.kind == TrackType.VIDEO) {
    //     // e.publication.videoQuality = VideoQuality.LOW;
    //     e.publication.setVideoQuality(VideoQuality.LOW);
    //   } else if (e.publication.kind == TrackType.AUDIO) {
    //     // e.publication.videoQuality = VideoQuality.LOW;
    //     e.publication.setVideoQuality(VideoQuality.OFF);
    //   }
    // })
    // ..on<AudioPlaybackStatusChanged>((event) async {
    //   if (!_room!.canPlaybackAudio) {
    //     print('Audio playback failed for iOS Safari ..........');
    //     await _room!.startAudio();
    //     // bool? yesno = await context.showPlayAudioManuallyDialog();
    //     // if (yesno == true) {
    //     //   await _room!.startAudio();
    //     // }
    //   }
    // });
    // ..on<RoomReconnectingEvent>((p0) async {
    //   // WidgetsBindingCompatible.instance
    //   //     ?.addPostFrameCallback((timeStamp) => Navigator.pop(context));
    //   print(
    //       'RoomReconnectingEvent $p0........................................');
    // })
    // ..on<RoomRestartingEvent>((p0) async {
    //   // WidgetsBindingCompatible.instance
    //   //     ?.addPostFrameCallback((timeStamp) => Navigator.pop(context));
    //   print('RoomRestartingEvent $p0........................................');
    // })
    // ..on<RoomDisconnectedEvent>((RoomDisconnectedEvent event) async {
    //   // WidgetsBindingCompatible.instance
    //   //     ?.addPostFrameCallback((timeStamp) => Navigator.pop(context));
    //   switch (event.reason) {
    //     case DisconnectReason.roomDeleted:
    //       _closeEverything();
    //       break;
    //     case DisconnectReason.joinFailure:
    //       if (_roomToken != '') {
    //         _connectingRoom(token: _roomToken);
    //       } else {
    //         _closeLiveRoom();
    //         _initLiveKitStuffs();
    //       }
    //       break;
    //     default:
    //   }
    //   // print(
    //   //     'RoomDisconnectedEvent $event........................................');
    // })
    // Should me Mendatory for all apps
    ..on<RoomReconnectedEvent>((event) {
      // if (_livekitStreamingController.listActiveCall.indexWhere(
      //       (element) => element['uid'] == _myUid,
      //     ) >
      //     -1) {
      //   try {
      //     if (_livekitStreamingController.allowVideoCall.value) {
      //       _room!.localParticipant!.setCameraEnabled(true);
      //       _room!.localParticipant!.setMicrophoneEnabled(true);

      //       _livekitStreamingController.muted.value = false;
      //       _livekitStreamingController.videoDisabled.value = false;
      //     } else {
      //       _room!.localParticipant!.setMicrophoneEnabled(true);
      //       _livekitStreamingController.muted.value = false;
      //     }
      //   } catch (_) {}
      // }
      _renderParticipants();
    })
    ..on<TrackSubscribedEvent>((_) => _renderParticipants())
    ..on<TrackUnsubscribedEvent>((_) => _renderParticipants())
    ..on<ParticipantConnectedEvent>((p0) {
      _livekitStreamingController.viewersCount.value =
          _room!.remoteParticipants.length;

      if (widget.isBroadcaster) {
        LiveRoomIsolationActions.useIsolateUpdateLiveRoom(
          submissionData: LiveRoomUpdateRequest.updateViewersCount(
            channelId: int.parse(widget.channelName),
            viewersCount: _room!.remoteParticipants.length,
          ),
        );
      }

      // print(
      //     'ParticipantConnectedEvent $p0 --------------------------------------------');
    })
    ..on<ParticipantDisconnectedEvent>((p0) {
      _livekitStreamingController.viewersCount.value =
          _room!.remoteParticipants.length;

      if (widget.isBroadcaster) {
        LiveRoomIsolationActions.useIsolateUpdateLiveRoom(
          submissionData: LiveRoomUpdateRequest.updateViewersCount(
            channelId: int.parse(widget.channelName),
            viewersCount: _room!.remoteParticipants.length,
          ),
        );
      }

      try {
        int participantId = int.parse(p0.participant.identity);
        _livekitStreamingController.viewers.removeWhere(
          (element) => element['uid'] == participantId,
        );
        _useIsolateSortingUserJoined(
          listViewers: _livekitStreamingController.viewers.toList(),
        );

        //  print(
        //   'ParticipantDisconnectedEvent $p0 ------------------------------------')
      } catch (e) {
        //
      }
    });

  AnimatedMediaSource _getAnimatedGiftMedia() {
    try {
      dynamic data = _livekitStreamingController.listAnimatedGiftSend[0];
      if (data is Map) {
        return AnimatedMediaSource.fromMap(data);
      }
    } catch (_) {
      // The animation queue can be cleared while the reactive view rebuilds.
    }
    return const AnimatedMediaSource(
      url: null,
      type: AnimatedMediaType.unsupported,
    );
  }

  void _renderParticipants() {
    // do nothing if already disposed
    if (_isDisposed) {
      return;
    }
    if (_livekitStreamingController.listActiveCall.isNotEmpty) {
      if (!_livekitStreamingController.busyConnectingEngine.value) {
        _generateViews(activeCalls: _livekitStreamingController.listActiveCall);
      }
    } else {
      _sortParticipants();
    }
  }

  void _generateViews({required List<dynamic> activeCalls}) async {
    List<ParticipantTrack> userMediaTracks = [];
    for (var activeCallData in activeCalls) {
      int uid = int.parse(activeCallData['uid'].toString());
      if (uid.toString() == widget.channelName) {
        if (widget.isBroadcaster) {
          LocalParticipant? localParticipant = _room!.localParticipant;
          final localParticipantVideoTracks =
              localParticipant?.videoTrackPublications;
          if (localParticipantVideoTracks != null) {
            for (var t in localParticipantVideoTracks) {
              if (!t.isScreenShare) {
                userMediaTracks.add(
                  ParticipantTrack(
                    participant: _room!.localParticipant!,
                    videoTrack: t.track,
                    isScreenShare: false,
                  ),
                );
              }
            }
          } else {
            final localParticipantAudioTracks =
                localParticipant?.audioTrackPublications;
            if (localParticipantAudioTracks != null) {
              for (var t in localParticipantAudioTracks) {
                if (!t.isScreenShare) {
                  userMediaTracks.add(
                    ParticipantTrack(
                      participant: _room!.localParticipant!,
                      videoTrack: null,
                      isScreenShare: false,
                    ),
                  );
                }
              }
            }
          }
        } else {
          try {
            var remoteParticipant = _room!.remoteParticipants.values
                .singleWhere((element) => element.identity == uid.toString());

            if (remoteParticipant.videoTrackPublications.isNotEmpty) {
              for (var t in remoteParticipant.videoTrackPublications) {
                if (!t.isScreenShare) {
                  userMediaTracks.add(
                    ParticipantTrack(
                      participant: remoteParticipant,
                      videoTrack: t.track,
                      isScreenShare: false,
                    ),
                  );
                }
              }
            } else if (remoteParticipant.audioTrackPublications.isNotEmpty) {
              for (var t in remoteParticipant.audioTrackPublications) {
                if (!t.isScreenShare) {
                  userMediaTracks.add(
                    ParticipantTrack(
                      participant: remoteParticipant,
                      videoTrack: null,
                      isScreenShare: false,
                    ),
                  );
                }
              }
            }
          } catch (e) {
            //
          }
        }
      } else if (uid == _myUid) {
        // _room!.setClientRole(ClientRole.Broadcaster);
        LocalParticipant? localParticipant = _room!.localParticipant;
        final localParticipantVideoTracks =
            localParticipant?.videoTrackPublications;
        if (localParticipantVideoTracks != null) {
          for (var t in localParticipantVideoTracks) {
            if (!t.isScreenShare) {
              userMediaTracks.add(
                ParticipantTrack(
                  participant: _room!.localParticipant!,
                  videoTrack: t.track,
                  isScreenShare: false,
                ),
              );
            }
          }
        } else {
          final localParticipantAudioTracks =
              localParticipant?.audioTrackPublications;
          if (localParticipantAudioTracks != null) {
            for (var t in localParticipantAudioTracks) {
              if (!t.isScreenShare) {
                userMediaTracks.add(
                  ParticipantTrack(
                    participant: _room!.localParticipant!,
                    videoTrack: null,
                    isScreenShare: false,
                  ),
                );
              }
            }
          }
        }
      } else {
        try {
          var remoteParticipant = _room!.remoteParticipants.values.singleWhere(
            (element) => element.identity == uid.toString(),
          );
          if (remoteParticipant.videoTrackPublications.isNotEmpty) {
            for (var t in remoteParticipant.videoTrackPublications) {
              if (!t.isScreenShare) {
                userMediaTracks.add(
                  ParticipantTrack(
                    participant: remoteParticipant,
                    videoTrack: t.track,
                    isScreenShare: false,
                  ),
                );
              }
            }
          } else if (remoteParticipant.audioTrackPublications.isNotEmpty) {
            for (var t in remoteParticipant.audioTrackPublications) {
              if (!t.isScreenShare) {
                userMediaTracks.add(
                  ParticipantTrack(
                    participant: remoteParticipant,
                    videoTrack: null,
                    isScreenShare: false,
                  ),
                );
              }
            }
          }
        } catch (e) {
          //
        }
      }
    }

    // participantTracks = [...userMediaTracks];
    _livekitStreamingController.setRenderViewList([...userMediaTracks]);
  }

  void _sortParticipants() {
    if (_room == null) {
      return;
    }
    _listGroupIds.clear();
    List<ParticipantTrack> userMediaTracks = [];
    for (var participant in _room!.remoteParticipants.values) {
      if (participant.videoTrackPublications.isNotEmpty) {
        for (var t in participant.videoTrackPublications) {
          if (!t.isScreenShare) {
            if (participant.identity == widget.channelName) {
              userMediaTracks.insert(
                0,
                ParticipantTrack(
                  participant: participant,
                  videoTrack: t.track,
                  isScreenShare: false,
                ),
              );
              _listGroupIds.insert(0, int.parse(participant.identity));
            } else {
              userMediaTracks.add(
                ParticipantTrack(
                  participant: participant,
                  videoTrack: t.track,
                  isScreenShare: false,
                ),
              );
              _listGroupIds.add(int.parse(participant.identity));
            }
          }
        }
      } else {
        for (var t in participant.audioTrackPublications) {
          if (!t.isScreenShare) {
            if (participant.identity == widget.channelName) {
              userMediaTracks.insert(
                0,
                ParticipantTrack(
                  participant: participant,
                  videoTrack: null,
                  isScreenShare: false,
                ),
              );
              _listGroupIds.insert(0, int.parse(participant.identity));
            } else {
              userMediaTracks.add(
                ParticipantTrack(
                  participant: participant,
                  videoTrack: null,
                  isScreenShare: false,
                ),
              );
              _listGroupIds.add(int.parse(participant.identity));
            }
          }
        }
      }
    }
    // // sort speakers for the grid
    // userMediaTracks.sort((a, b) {
    //   // loudest speaker first
    //   if (a.participant.isSpeaking && b.participant.isSpeaking) {
    //     if (a.participant.audioLevel > b.participant.audioLevel) {
    //       return -1;
    //     } else {
    //       return 1;
    //     }
    //   }

    //   // last spoken at
    //   final aSpokeAt = a.participant.lastSpokeAt?.millisecondsSinceEpoch ?? 0;
    //   final bSpokeAt = b.participant.lastSpokeAt?.millisecondsSinceEpoch ?? 0;

    //   if (aSpokeAt != bSpokeAt) {
    //     return aSpokeAt > bSpokeAt ? -1 : 1;
    //   }

    //   // video on
    //   if (a.participant.hasVideo != b.participant.hasVideo) {
    //     return a.participant.hasVideo ? -1 : 1;
    //   }

    //   // joinedAt
    //   return a.participant.joinedAt.millisecondsSinceEpoch -
    //       b.participant.joinedAt.millisecondsSinceEpoch;
    // });

    LocalParticipant? localParticipant = _room!.localParticipant;
    final localParticipantVideoTracks =
        localParticipant?.videoTrackPublications;
    if (localParticipantVideoTracks != null) {
      for (var t in localParticipantVideoTracks) {
        if (!t.isScreenShare) {
          if (localParticipant!.identity == widget.channelName) {
            userMediaTracks.insert(
              0,
              ParticipantTrack(
                participant: _room!.localParticipant!,
                videoTrack: t.track,
                isScreenShare: false,
              ),
            );
            _listGroupIds.insert(0, int.parse(localParticipant.identity));
          } else {
            userMediaTracks.add(
              ParticipantTrack(
                participant: _room!.localParticipant!,
                videoTrack: t.track,
                isScreenShare: false,
              ),
            );
            _listGroupIds.add(int.parse(localParticipant.identity));
          }
        }
      }
    } else {
      final localParticipantAudioTracks =
          localParticipant?.audioTrackPublications;
      if (localParticipantAudioTracks != null) {
        for (var t in localParticipantAudioTracks) {
          if (!t.isScreenShare) {
            if (localParticipant!.identity == widget.channelName) {
              userMediaTracks.insert(
                0,
                ParticipantTrack(
                  participant: _room!.localParticipant!,
                  videoTrack: null,
                  isScreenShare: false,
                ),
              );
              _listGroupIds.insert(0, int.parse(localParticipant.identity));
            } else {
              userMediaTracks.add(
                ParticipantTrack(
                  participant: _room!.localParticipant!,
                  videoTrack: null,
                  isScreenShare: false,
                ),
              );
              _listGroupIds.add(int.parse(localParticipant.identity));
            }
          }
        }
      }
    }

    _livekitStreamingController.setRenderViewList([...userMediaTracks]);
  }

  void _closeStreamingEvent() {
    if (_isDisposed || !mounted) return;
    if (widget.isBroadcaster) {
      onUpdateAction({'action': 'end_streaming'});
      _livekitStreamingController.onUpdateLiveStreamStatus({
        'type': STREAMING,
        'channelName': _myUid,
        'online': false,
        'datetime': DateTime.now().toString(),
      });
    } else if (_livekitStreamingController.listActiveCall.any(
      (element) => element['uid'] == _myUid,
    )) {
      onUpdateAction({'action': 'end_call', 'uid': _myUid});
      LiveRoomIsolationActions.useIsolateUpdateLiveRoom(
        submissionData: LiveRoomUpdateRequest.removeUserFromCallingGroup(
          channelId: int.parse(widget.channelName),
          uid: _myUid,
        ),
      );
    }
    _closeEverything();
  }

  void _timeConsumingTasks() {
    _timerTrackingExpiredNormalGifts = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (_room != null &&
            _room!.remoteParticipants.length !=
                _livekitStreamingController.viewersCount.value) {
          _livekitStreamingController.viewersCount.value =
              _room!.remoteParticipants.length;
        }
        _livekitStreamingController.removeExpiredJoinedAnimationShow();
        _livekitStreamingController.removeExpiredNormalGiftShow();

        // Checking blocks
        if (_livekitStreamingController.liveStreamData.value['blocks'] !=
                null &&
            _livekitStreamingController.liveStreamData.value['blocks'].contains(
              _myUid,
            )) {
          timer.cancel();
          _closeEverything();
          Get.defaultDialog(
            title: 'No Access',
            middleText: '${widget.fullName} blocked you',
            titleStyle: const TextStyle(color: AppColors.error),
          );

          return;
        }

        if (!_livekitStreamingController.liveStreamData.containsKey(
          'created_datetime',
        )) {
          _performOnRunningTimeClock(durationFormat: '00:00:00');
        } else {
          try {
            int recentDuration =
                _currentDateTimeInSeconds(dateTime: DateTime.now().toLocal()) -
                _currentDateTimeInSeconds(
                  dateTime: DateTime.parse(
                    _livekitStreamingController
                        .liveStreamData['created_datetime'],
                  ).toLocal(),
                );
            if (_prevDuration == -1) {
              if (recentDuration < 0) {
                _prevDuration = recentDuration * -1;
              } else {
                _prevDuration = 0;
              }
            }
            // print('dateTime: $recentDuration....................');
            _performOnRunningTimeClock(
              durationFormat: _printDuration(
                Duration(seconds: (recentDuration + _prevDuration)),
              ),
            );
          } catch (e) {
            //
          }
        }
      },
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );
    _animationController!.addStatusListener((AnimationStatus status) {
      if (_isDisposed || !mounted) return;
      setState(() {});

      if (status == AnimationStatus.completed) {
        // Working emoji
        _emojiItems.removeWhere(
          (EmojiItem emojiItem) =>
              (DateTime.parse(emojiItem.datetime!).toLocal().add(
                const Duration(seconds: 6),
              )).compareTo(DateTime.now()) <
              0,
        );
        if (_emojiItems.isNotEmpty) {
          _animationController!.reset();
          _animationController!.forward();
        }
      }
    });
  }

  int _currentDateTimeInSeconds({required DateTime dateTime}) {
    var ms = dateTime.millisecondsSinceEpoch;
    return (ms / 1000).round();
  }

  void _scrollingStuff() {
    _scrollController.addListener(() {
      _scrollPosition ??= 0;

      if (_scrollController.position.pixels < _scrollPosition!) {
        // Stop Auto Scrolling
        if (_livekitStreamingController.needsScroll.value) {
          _livekitStreamingController.needsScroll.value = false;
        }
        _scrollPosition = _scrollController.position.pixels;
      } else if (_scrollController.position.pixels > _scrollPosition!) {
        // Continue Auto Scrolling
        if (!_livekitStreamingController.needsScroll.value) {
          _livekitStreamingController.needsScroll.value = true;
        }
      }
    });
  }

  void _loadStateData() async {
    // Viewer
    if (!widget.isBroadcaster) {
      // Normal Entry
      _livekitStreamingController.broadcasterDiamonds.value =
          widget.broadcasterDiamonds;
    }
    // else {
    //   // Broadcaster
    //   // Notify followers about Live Streaming
    //   _livekitStreamingController.tryToNotifyFollowerAboutLiveStreaming();
    // }
  }

  Future<void> _handleMissingLiveRoomHeartbeat() async {
    if (_isDisposed) {
      return;
    }
    _closeEverything();
    Get.defaultDialog(
      title: 'Restart Stream',
      middleText:
          'Live room was not found on the server. Please restart the stream.',
      barrierDismissible: false,
      textConfirm: 'OK',
      onConfirm: () {
        if (Get.isDialogOpen == true) {
          Get.back();
        }
      },
    );
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> _closeLiveRoom() async {
    final room = _room;
    final listener = _listener;
    _room = null;
    _listener = null;
    room?.removeListener(_onRoomDidUpdate);
    try {
      await listener?.dispose();
    } catch (_) {
      // Continue releasing the room if listener teardown failed.
    }
    try {
      await room?.disconnect();
    } catch (_) {
      // A disconnected transport must still be disposed.
    }
    try {
      await room?.dispose();
    } catch (_) {
      debugPrint('[LIVE-ROOM] Room disposal failed');
    }
  }

  void _cancelRoomTimers() {
    _timerAfterInternetConnectionCheck?.cancel();
    _timer?.cancel();
    _timerTrackingExpiredStreams?.cancel();
    _timerTrackingExpiredNormalGifts?.cancel();
    _entryEffectTimer?.cancel();
  }

  void _closeEverything() {
    if (_isDisposed || !mounted) return;
    _isDisposed = true;
    _authController.setShowingOverlay(overlay: true);
    _livekitStreamingController.stopLiveRoomHeartbeat();
    _cancelRoomTimers();
    _animationController?.stop();
    _closeActionSocket();
    unawaited(_closeLiveRoom());
    _livekitStreamingController.setClearAnimationStuffs();

    // Get.back() can close only a sheet/dialog. Repeated callbacks then used
    // to pop the page underneath; keep navigation tied to this room's route.
    final route = ModalRoute.of(context);
    if (route == null) return;
    final navigator = Navigator.of(context);
    navigator.popUntil((candidate) => candidate == route || candidate.isFirst);
    if (!route.isCurrent) return;
    if (route.isFirst) {
      navigator.pushReplacement(MaterialPageRoute(builder: (_) => NavView()));
    } else {
      navigator.pop();
    }
    // Widget controllers stay alive during the route's exit animation and are
    // disposed exactly once in dispose().
  }

  bool onUpdateAction(dynamic data) => onUpdateAgtionWithWebSocketClient(data);

  bool onUpdateAgtionWithWebSocketClient(dynamic data) {
    if (!_isActionSocketConnected || data is! Map) {
      return false;
    }

    final mapData = Map<String, dynamic>.from(data);
    mapData.addIf(!mapData.containsKey('type'), 'type', data['action']);

    // final jsonEncodedData = jsonEncode({
    //   'message': mapData,
    // });

    final jsonEncodedData = jsonEncode(mapData);

    // print(
    //     'jsonEncodedData Action Socket: ${jsonEncodedData.length}.................................');
    final gzipEncodedData = gzip.encode(utf8.encode(jsonEncodedData));
    // print(
    //     'gzipEncodedData Action Socket: ${gzipEncodedData.length}.................................');

    dynamic sendableData;

    if (jsonEncodedData.length > gzipEncodedData.length) {
      sendableData = jsonEncode({
        'message': {'gzip': gzipEncodedData},
      });
    } else {
      sendableData = jsonEncode({'message': mapData});
    }

    try {
      webSocketClientForActions!.send(sendableData);
      return true;
    } catch (e) {
      _webSocketConnectionState = 'disconnected';
      if (data['action'] == 'end_call' || data['action'] == 'end_pk_call') {
        _closeEverything();
      }
      return false;
    }
  }

  void _onUnpublishAllTracks() async {
    try {
      await _room!.localParticipant?.unpublishAllTracks();
    } catch (e) {
      //
    }
  }

  Future<void> _onToggleMute() async {
    try {
      final muted = !_livekitStreamingController.muted.value;
      await _room!.localParticipant?.setMicrophoneEnabled(!muted);
      _livekitStreamingController.muted.value = muted;
      _updateLocalActiveCallMediaState(muted: muted);

      String action = 'controller';
      if (_livekitStreamingController.pkState.value) {
        action = 'controller_pk';
      }
      dynamic data = {
        // 'room_name': '${widget.channelName}_actions',
        'action': action,
        'uid': _myUid,
        // 'full_name': _authController.profile.value.full_name,
        // 'profile_image': _authController.profile.value.profile_image ??
        //     _authController.profile.value.photo_url,
        // 'diamonds': _authController.profile.value.diamonds,
        // 'is_moderator': _authController.profile.value.is_moderator,
        // 'is_host': _authController.profile.value.is_host,
        // 'is_reseller': _authController.profile.value.is_reseller,
        // 'level': _authController.profile.value.level,
        // 'vvip_or_vip_preference':
        //     _authController.profile.value.vvip_or_vip_preference,
        // 'package_theme_gif': _authController.profile.value.package_theme_gif,
        // 'followers': _authController.profile.value.followers,
        // 'blocks': _authController.profile.value.blocks,
        'call_type': _livekitStreamingController.callType.value,
        'muted': muted,
        'video_disabled': _livekitStreamingController.videoDisabled.value,
      };
      onUpdateAction(data);
      //  _livekitStreamingController.muted.value =
      //     !_livekitStreamingController.muted.value;
    } catch (e) {
      //
      if (!mounted) {
        return;
      }
      rShowSnackBar(
        context: context,
        title:
            'Failed to ${_livekitStreamingController.muted.value ? 'Unmute' : 'Mute'}',
        color: AppColors.error,
        durationInSeconds: 1,
      );
    }
  }

  void _setSpeakerphoneOn() async {
    if (_headsetState == HeadsetState.CONNECT) {
      rShowSnackBar(
        context: context,
        title: 'Your headset is already connected.',
        color: AppColors.success,
        durationInSeconds: 1,
      );
      return;
    }
    bool speakerOn = true;
    // switch (Hardware.instance.speakerOn) {
    switch (_livekitStreamingController.loudSpeaker.value) {
      case true:
        speakerOn = false;
        _livekitStreamingController.setLoudSpeaker(false);
        break;
      case false:
        speakerOn = true;
        _livekitStreamingController.setLoudSpeaker(true);
        break;
      default:
    }
    // await Hardware.instance.setSpeakerphoneOn(speakerOn);
    await rtc.Helper.setSpeakerphoneOn(speakerOn);
  }

  Future<void> _onToggleVideoEnable() async {
    try {
      final videoDisabled = !_livekitStreamingController.videoDisabled.value;
      await _room!.localParticipant?.setCameraEnabled(!videoDisabled);
      _livekitStreamingController.videoDisabled.value = videoDisabled;
      _updateLocalActiveCallMediaState(videoDisabled: videoDisabled);

      String action = 'controller';
      if (_livekitStreamingController.pkState.value) {
        action = 'controller_pk';
      }
      dynamic data = {
        // 'room_name': '${widget.channelName}_actions',
        'action': action,
        'uid': _myUid,
        // 'full_name': _authController.profile.value.full_name,
        // 'profile_image': _authController.profile.value.profile_image ??
        //     _authController.profile.value.photo_url,
        // 'diamonds': _authController.profile.value.diamonds,
        // 'is_moderator': _authController.profile.value.is_moderator,
        // 'is_host': _authController.profile.value.is_host,
        // 'is_reseller': _authController.profile.value.is_reseller,
        // 'level': _authController.profile.value.level,
        // 'vvip_or_vip_preference':
        //     _authController.profile.value.vvip_or_vip_preference,
        // 'followers': _authController.profile.value.followers,
        // 'blocks': _authController.profile.value.blocks,
        'call_type': 'video',
        'muted': _livekitStreamingController.muted.value,
        'video_disabled': videoDisabled,
      };
      onUpdateAction(data);
      //  _livekitStreamingController.videoDisabled.value =
      //     !_livekitStreamingController.videoDisabled.value;
    } catch (e) {
      //
      if (!mounted) {
        return;
      }
      rShowSnackBar(
        context: context,
        title:
            'Failed to ${_livekitStreamingController.videoDisabled.value ? 'Show Video' : 'Hide Video'}',
        color: AppColors.error,
        durationInSeconds: 1,
      );
    }
  }

  void _updateLocalActiveCallMediaState({bool? muted, bool? videoDisabled}) {
    final activeCalls = _livekitStreamingController.listActiveCall;
    final index = activeCalls.indexWhere(
      (element) => _toInt(element['uid']) == _myUid,
    );
    if (index == -1) {
      return;
    }

    final updatedData = Map<String, dynamic>.from(activeCalls[index] as Map);
    if (muted != null) {
      updatedData['muted'] = muted;
    }
    if (videoDisabled != null) {
      updatedData['video_disabled'] = videoDisabled;
    }
    activeCalls[index] = updatedData;
    activeCalls.refresh();
  }

  void _onSwitchCamera() async {
    final track = _room!.localParticipant?.videoTrackPublications.first.track;
    if (track == null) return;

    try {
      final newPosition = _cameraPosition.switched();
      await track.setCameraPosition(newPosition);
      _cameraPosition = newPosition;
      // if (widget.isBroadcaster) {
      //   _livekitStreamingController.cameraPosition.value = _cameraPosition;
      //   _livekitStreamingController.tryToUpdateStreamingStuffs(
      //       channelName: _livekitStreamingController.channelName.value);
      // }

      // String action = 'controller';
      // if (_livekitStreamingController.pkState.value) {
      //   action = 'controller_pk';
      // }
      // dynamic data = {
      //   // 'room_name': '${widget.channelName}_actions',
      //   'action': action,
      //   'uid': _myUid,
      //   // 'full_name': _authController.profile.value.full_name,
      //   // 'profile_image': _authController.profile.value.profile_image ??
      //   //     _authController.profile.value.photo_url,
      //   // 'diamonds': _authController.profile.value.diamonds,
      //   // 'is_moderator': _authController.profile.value.is_moderator,
      //   // 'is_host': _authController.profile.value.is_host,
      //   // 'is_reseller': _authController.profile.value.is_reseller,
      //   // 'level': _authController.profile.value.level,
      //   // 'vvip_or_vip_preference':
      //   //     _authController.profile.value.vvip_or_vip_preference,
      //   // 'package_theme_gif': _authController.profile.value.package_theme_gif,
      //   // 'followers': _authController.profile.value.followers,
      //   // 'blocks': _authController.profile.value.blocks,
      //   'call_type': 'video',
      //   'muted': _livekitStreamingController.muted.value,
      //   'video_disabled': _livekitStreamingController.videoDisabled.value,
      // };
      // onUpdateAction(data);
    } catch (error) {
      return;
    }
  }

  void _onHostSwitchPosition() {
    if (!widget.isBroadcaster) {
      return;
    }
    final activeCalls = _livekitStreamingController.listActiveCall;
    if (activeCalls.length < 2) {
      rShowSnackBar(
        context: context,
        title: 'Need at least 2 active callers to switch position.',
        color: AppColors.warning,
        durationInSeconds: 1,
      );
      return;
    }

    final hostUid = _toInt(widget.channelName) ?? _myUid;
    final hostIndex = activeCalls.indexWhere(
      (element) => _toInt(element['uid']) == hostUid,
    );
    if (hostIndex < 0) {
      return;
    }

    final targetIndex = (hostIndex + 1) % activeCalls.length;
    if (targetIndex == hostIndex) {
      return;
    }
    final targetUid = _toInt(activeCalls[targetIndex]['uid']);
    if (targetUid == null) {
      return;
    }

    onUpdateAction({
      'action': 'switch_position',
      'uid': hostUid,
      'target_uid': targetUid,
    });
  }

  void _applyPositionSwitch({
    required int? sourceUid,
    required int? targetUid,
  }) {
    if (sourceUid == null || targetUid == null) {
      return;
    }
    final activeCalls = _livekitStreamingController.listActiveCall;
    final sourceIndex = activeCalls.indexWhere(
      (element) => _toInt(element['uid']) == sourceUid,
    );
    final targetIndex = activeCalls.indexWhere(
      (element) => _toInt(element['uid']) == targetUid,
    );
    if (sourceIndex < 0 || targetIndex < 0 || sourceIndex == targetIndex) {
      return;
    }

    final sourceData = activeCalls[sourceIndex];
    activeCalls[sourceIndex] = activeCalls[targetIndex];
    activeCalls[targetIndex] = sourceData;
    activeCalls.refresh();
  }

  int? _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  Widget _giftSendAnimationView({required dynamic data}) {
    return Stack(
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.warning.withValues(alpha: .2),
                    AppColors.error.withValues(alpha: .2),
                    AppColors.overlay,
                  ],
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                ),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // data['profile_image'] == null || data['profile_image'] == ''
                  //     ? ClipRRect(
                  //         borderRadius: BorderRadius.circular(20.0),
                  //         child: Image.asset(
                  //           'assets/others/person.jpg',
                  //           width: 50,
                  //           height: 50,
                  //           fit: BoxFit.cover,
                  //         ),
                  //       )
                  //     : ClipRRect(
                  //         borderRadius: BorderRadius.circular(20.0),
                  //         child: CachedNetworkImage(
                  //           imageUrl: data['profile_image'],
                  //           width: 50,
                  //           height: 50,
                  //           fit: BoxFit.cover,
                  //         ),
                  //       ),
                  SizedBox(
                    width: 44,
                    height: 44,
                    child: Stack(
                      children: [
                        Positioned(
                          top: 2,
                          left: 2,
                          right: 2,
                          bottom: 2,
                          child:
                              data['vvip_or_vip_preference'] != null &&
                                  data['vvip_or_vip_preference']['vvip_or_vip_gif'] !=
                                      null &&
                                  data['vvip_or_vip_preference']['vvip_or_vip_gif'] !=
                                      ''
                              ? Container(
                                  width: 40,
                                  height: 40,
                                  foregroundDecoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: CachedNetworkImageProvider(
                                        data['vvip_or_vip_preference']['vvip_or_vip_gif'],
                                      ),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child:
                                        data['profile_image'] == null &&
                                            data['photo_url'] == null
                                        ? Image.asset(
                                            'assets/others/person.jpg',
                                            width: 32,
                                            height: 32,
                                            fit: BoxFit.cover,
                                          )
                                        : CachedNetworkImage(
                                            imageUrl:
                                                data['profile_image'] ??
                                                data['photo_url'],
                                            width: 32,
                                            height: 32,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                const Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                        color: AppColors.error,
                                                      ),
                                                ),
                                          ),
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(100),
                                  child:
                                      data['profile_image'] == null &&
                                          data['photo_url'] == null
                                      ? Image.asset(
                                          'assets/others/person.jpg',
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                        )
                                      : CachedNetworkImage(
                                          imageUrl:
                                              data['profile_image'] ??
                                              data['photo_url'],
                                          width: 40,
                                          height: 40,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              const Center(
                                                child:
                                                    CircularProgressIndicator(
                                                      color: AppColors.error,
                                                    ),
                                              ),
                                        ),
                                ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 4,
                          child: Container(
                            padding: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Container(
                              width: 16,
                              height: 16,
                              padding: const EdgeInsets.all(1),
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Center(
                                child: Text(
                                  '${data['level'] != null ? data['level']['level'] : 0}',
                                  style: const TextStyle(
                                    color: AppColors.surface,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: _screenGlobalWidth * .45,
                    ),
                    child: Text(
                      '${data['full_name']}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.surface,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: data['gift_image'],
                  // height: 80,
                  width: 70,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(color: AppColors.error),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        decoration: BoxDecoration(
                          color: AppColors.overlay,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              LucideIcons.gem,
                              color: AppColors.surface,
                            ),
                            Text(
                              '${data['diamonds']}',
                              style: const TextStyle(color: AppColors.surface),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        // Positioned(
        //   top: 0,
        //   left: 38,
        //   child: Container(
        //     padding: const EdgeInsets.symmetric(horizontal: 4.0),
        //     decoration: BoxDecoration(
        //       color: AppColors.premium,
        //       borderRadius: BorderRadius.circular(20.0),
        //     ),
        //     child: Text(
        //       'L.v'${data['level'] != null ? data['level']['level'] : 0}',
        //       style: const TextStyle(
        //         color: AppColors.surface,
        //         fontSize: 12,
        //         fontWeight: FontWeight.w500,
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _commentItemWidget({required data}) {
    return GestureDetector(
      onTap: () {
        showUserInfoBottomSheet(
          context: context,
          // data: {
          //   'profile_image': _profileImage,
          //   'full_name': _fullName,
          //   'uid': int.parse(widget.channelName),
          // },
          data: data,
          onUpdateAction: onUpdateAction,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              // color: const Color(0xFF8B69C8),
              color: AppColors.overlay,
              borderRadius: BorderRadius.circular(10),
              border:
                  data['vvip_or_vip_preference'] == null ||
                      data['vvip_or_vip_preference']['vvip_or_vip_gif'] == null
                  ? null
                  : Border.all(color: AppColors.warning),
            ),
            child:
                data['vvip_or_vip_preference'] == null ||
                    data['vvip_or_vip_preference']['vvip_or_vip_gif'] == null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        // padding: const EdgeInsets.all(4),
                        margin: const EdgeInsets.only(right: 4),
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          // borderRadius: BorderRadius.circular(100),
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          maxHeight: 20,
                        ),
                        child: Center(
                          child: Text(
                            '${data['level'] != null ? data['level']['level'] : 0}',
                            style: const TextStyle(
                              color: AppColors.surface,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: _screenGlobalWidth - 150,
                            ),
                            margin: const EdgeInsets.only(right: 4),
                            child: Text(
                              '${data['full_name']}',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.surface,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Container(
                            constraints: BoxConstraints(
                              maxWidth: _screenGlobalWidth - 150,
                            ),
                            child: Text(
                              data['type'] == 'joined'
                                  ? 'Coming'
                                  : data['type'] == 'call_request'
                                  ? 'Requested for joining the Group!'
                                  : data['type'] == 'cancel_request'
                                  ? 'Canceled the joining request!'
                                  : data['type'] == 'emoji'
                                  ? 'sent ${data['emoji'] is Emoji ? data['emoji'].char : data['emoji']}'
                                  : data['type'] == 'gift'
                                  ? 'sent ${data['diamonds']}-diamonds gift to ${data['receiver_full_name']}'
                                  : '${data['text']}',
                              style: TextStyle(
                                color:
                                    data['type'] == 'joined' ||
                                        data['type'] == 'call_request' ||
                                        data['type'] == 'cancel_request' ||
                                        data['type'] == 'gift'
                                    ? AppColors.premium
                                    : data['type'] == 'emoji'
                                    ? AppColors.error
                                    : AppColors.surface,
                                fontStyle:
                                    data['type'] == 'joined' ||
                                        data['type'] == 'call_request' ||
                                        data['type'] == 'cancel_request' ||
                                        data['type'] == 'emoji' ||
                                        data['type'] == 'gift'
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                                fontWeight:
                                    data['type'] == 'joined' ||
                                        data['type'] == 'call_request' ||
                                        data['type'] == 'cancel_request' ||
                                        data['type'] == 'emoji' ||
                                        data['type'] == 'gift'
                                    ? FontWeight.w700
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100.0),
                          border: Border.all(
                            width: 2.0,
                            color: AppColors.warning,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100.0),
                          child: data['profile_image'] == null
                              ? Image.asset(
                                  'assets/others/person.jpg',
                                  width: 28,
                                  height: 28,
                                  fit: BoxFit.cover,
                                )
                              : CachedNetworkImage(
                                  imageUrl: '${data['profile_image']}',
                                  width: 28,
                                  height: 28,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => const Center(
                                    child: CircularProgressIndicator(
                                      color: AppColors.error,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Level , Name, VVIP/VIP
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            // padding: const EdgeInsets.all(4),
                            margin: const EdgeInsets.only(right: 4),
                            // decoration: const BoxDecoration(
                            //   color: AppColors.error,
                            //   // borderRadius: BorderRadius.circular(100),
                            //   // shape: BoxShape.circle,
                            // ),
                            // constraints: const BoxConstraints(
                            //   minWidth: 20,
                            //   maxHeight: 20,
                            // ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'L.v.${data['level'] != null ? data['level']['level'] : 0}',
                                  style: const TextStyle(
                                    color: AppColors.premium,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth: _screenGlobalWidth - 180,
                                  ),
                                  margin: const EdgeInsets.only(left: 4),
                                  child: Text(
                                    '${data['full_name']}',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.surface,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(right: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.overlay,
                                  // borderRadius: BorderRadius.only(
                                  //   bottomLeft: Radius.circular(20.0),
                                  //   bottomRight: Radius.circular(20.0),
                                  // ),
                                  border: Border.all(
                                    color: AppColors.warning,
                                    // width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(100.0),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(100.0),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        data['vvip_or_vip_preference']['vvip_or_vip_gif'],
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                              ),
                              Container(
                                constraints: BoxConstraints(
                                  maxWidth: _screenGlobalWidth - 180,
                                ),
                                child: Text(
                                  data['type'] == 'joined'
                                      ? 'Coming'
                                      : data['type'] == 'call_request'
                                      ? 'Requested for joining the Group!'
                                      : data['type'] == 'cancel_request'
                                      ? 'Canceled the joining request!'
                                      : data['type'] == 'emoji'
                                      ? 'sent ${data['emoji'] is Emoji ? data['emoji'].char : data['emoji']}'
                                      : data['type'] == 'gift'
                                      ? 'sent ${data['diamonds']}-diamonds gift to ${data['receiver_full_name']}'
                                      : '${data['text']}',
                                  style: TextStyle(
                                    color:
                                        data['type'] == 'joined' ||
                                            data['type'] == 'call_request' ||
                                            data['type'] == 'cancel_request' ||
                                            data['type'] == 'gift'
                                        ? AppColors.premium
                                        : data['type'] == 'emoji'
                                        ? AppColors.error
                                        : AppColors.surface,
                                    fontStyle:
                                        data['type'] == 'joined' ||
                                            data['type'] == 'call_request' ||
                                            data['type'] == 'cancel_request' ||
                                            data['type'] == 'emoji' ||
                                            data['type'] == 'gift'
                                        ? FontStyle.italic
                                        : FontStyle.normal,
                                    fontWeight:
                                        data['type'] == 'joined' ||
                                            data['type'] == 'call_request' ||
                                            data['type'] == 'cancel_request' ||
                                            data['type'] == 'emoji' ||
                                            data['type'] == 'gift'
                                        ? FontWeight.w700
                                        : FontWeight.normal,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(width: 4.0),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  void _useIsolateSortingUserJoined({
    required List<dynamic> listViewers,
  }) async {
    var recievePort = ReceivePort(); //creating new port to listen data
    await Isolate.spawn(sortingUserJoined, [
      recievePort.sendPort,
      // _livekitStreamingController.viewersTemp.toList(),
      listViewers,
    ]); //spawing/creating new thread as isolates.
    recievePort.listen((data) {
      //listening data from isolate
      if (data != null) {
        // print(data[0]['contribution_rank']);
        _livekitStreamingController.setViewList(data);
      }
    });
  }
}

class _RoomEntryEffect {
  const _RoomEntryEffect({required this.effect, this.userName});

  final EntryEffect effect;
  final String? userName;
}

void sortingUserJoined(List<dynamic> args) {
  SendPort resultPort = args[0];
  List<dynamic> viewers = args[1];
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

      // viewers.sort((a, b) => (b['vvip_or_vip_preference']['rank'])
      //     .compareTo(a['vvip_or_vip_preference']['rank']));
    } catch (e) {
      //
    }
  }
  Isolate.exit(resultPort, viewers);
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
