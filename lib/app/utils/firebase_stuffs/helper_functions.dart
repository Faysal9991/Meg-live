import 'dart:convert';

import 'package:app_links/app_links.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/views/broadcast/live_streaming_view.dart';
import 'package:doyel_live/app/utils/api_endpoints.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:share_plus/share_plus.dart';

class HelperFunctions {
  bool actionForBackPressed() {
    final LiveStreamingController livekitStreamingController = Get.find();
    if (livekitStreamingController.showCommentField.value) {
      livekitStreamingController.setShowCommentField(show: false);
      return false;
    }
    // exit(0);
    return true;
  }

  Future<void> initDynamicLinks() async {
    final appLinks = AppLinks(); // AppLinks is singleton
    try {
      final Uri uri = await appLinks.uriLinkStream.first;
      _handleMyLink(uri);
    } catch (_) {}

    appLinks.uriLinkStream.listen(
      (Uri? uri) {
        // Use the uri and warn the user, if it is not correct
        _handleMyLink(uri);
      },
      onError: (_) {
        // Handle exception by warning the user their action did not succeed
      },
    );
  }

  void _handleMyLink(Uri? uri) {
    if (uri == null || uri.queryParameters.isEmpty) return;

    if (uri.path.contains('/streaming/') &&
        uri.queryParameters.containsKey('data')) {
      String base64Data = uri.queryParameters['data']!;

      String decoded = decodeBase64Url(base64Data);

      // Parse the decoded query string manually
      Uri decodedUri = Uri.parse('$baseUrlAppLink/streaming/?$decoded');

      // Live Straming Link
      String? channelId = decodedUri.queryParameters['channel_id'];
      String? title = decodedUri.queryParameters['title'];
      String? image = decodedUri.queryParameters['image'];

      if (channelId != null) {
        showLiveStreaming(channelId: channelId, title: title, image: image);
      }
    }
  }

  void showLiveStreaming({
    required String channelId,
    required String? title,
    required String? image,
  }) async {
    AuthController authController = Get.find();
    if (channelId == authController.profile.value.user!.uid!.toString()) {
      Get.snackbar(
        'Not allowed',
        "You can't enter your own stream.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
      return;
    }

    LiveStreamingController streamingController = Get.find();

    dynamic streamingData = await streamingController.getLiveData(
      channelId: channelId,
    );
    if (streamingData != null) {
      // Live Lock
      if (streamingData['is_locked'] != null && streamingData['is_locked']) {
        if ((streamingData['group_caller_ids'] as List).firstWhereOrNull(
              (uid) => uid == authController.profile.value.user!.uid!,
            ) ==
            null) {
          Get.snackbar(
            'Not allowed',
            "Live is Locked.",
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 2),
          );
          return;
        }
      }
      streamingController.setBroadcastStreamingStuffs(
        brdchannelName: streamingData['channel_id'].toString(),
        broadcasterName: streamingData['owner_profile']['full_name'],
        brdImage: streamingData['owner_profile']['profile_image'],
        isBrdOwner: false,
        activeInCalls: [],
        brdViewers: [],
        brdFollowers: [],
        brdBlocks: streamingData['owner_profile']['blocks'],
        brdDiamonds: streamingData['owner_profile']['diamonds'] ?? 0,
        brdLoveReacts: streamingData['reacts'] ?? 0,
        brdLevel: null,
        fromLink: true,
      );
      Get.to(
        () => LiveStreamingView(
          channelName: channelId,
          isBroadcaster: false,
          fullName: title,
          profileImage: image,
          broadcasterDiamonds: streamingData['owner_profile']['diamonds'] ?? 0,
          followers: streamingData['owner_profile']['followers'] ?? [],
          blocks: streamingData['owner_profile']['blocks'] ?? [],
          level: null,
          vVipOrVipPreference: {
            'vvip_or_vip_preference': {
              'rank': streamingData['owner_profile']['vvip_rank'],
              'vvip_or_vip_gif': streamingData['owner_profile']['vvip_gif'],
            },
          },
        ),
      );
    } else {
      streamingController.setBroadcastStreamingStuffs(
        brdchannelName: channelId,
        broadcasterName: title,
        brdImage: image,
        isBrdOwner: false,
        activeInCalls: [],
        brdViewers: [],
        brdFollowers: [],
        brdBlocks: [],
        brdDiamonds: 0,
        brdLoveReacts: 0,
        brdLevel: null,
        fromLink: true,
      );
      Get.to(
        () => LiveStreamingView(
          channelName: channelId,
          isBroadcaster: false,
          fullName: title,
          profileImage: image,
          broadcasterDiamonds: 0,
          followers: const [],
          blocks: const [],
          level: null,
          vVipOrVipPreference: const {
            'vvip_or_vip_preference': {'rank': 0, 'vvip_or_vip_gif': null},
          },
        ),
      );
    }
  }

  /// Securely encode (URL safe)
  String encodeBase64Url(String input) {
    var bytes = utf8.encode(input);
    return base64UrlEncode(bytes); // URL-safe Base64
  }

  /// Securely decode (handles missing padding)
  String decodeBase64Url(String input) {
    String normalized = input;

    // Fix padding if removed
    while (normalized.length % 4 != 0) {
      normalized += '=';
    }

    var bytes = base64Url.decode(normalized);
    return utf8.decode(bytes);
  }

  buildDynamicLinksForLiveStreaming({
    required String title,
    required String description,
    String? image,
    required String channelId,
  }) async {
    String query = 'channel_id=$channelId&title=$title&image=$image';
    // Encode to Base64
    // String encoded = base64.encode(utf8.encode(query));
    String encoded = encodeBase64Url(query);

    String customUrl = '$baseUrlAppLink/streaming/?data=$encoded';

    String? desc = 'Doyel Live:\n$title\n$customUrl';

    await SharePlus.instance.share(
      ShareParams(text: desc, subject: title),
      // desc,
      // subject: title,
    );
  }
}
