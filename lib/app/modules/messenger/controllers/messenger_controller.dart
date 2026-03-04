import 'package:dio/dio.dart';
import 'package:doyel_live/app/utils/api_endpoints.dart';
import 'package:doyel_live/app/utils/drf_api_key.dart';
import 'package:get/get.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';

class MessengerController extends GetxController {
  final AuthController _authController = Get.find();

  final loadingLastMessageList = false.obs;
  final loadingMessageList = false.obs;
  final loadingChatBlock = false.obs;

  // Chat
  final isChatBlocked = false.obs;
  final chatBlockedBy = 0.obs;
  final messageText = ''.obs;
  final listLastMessage = [].obs;
  final listChatMessage = [].obs;
  final listChatBlock = [].obs;

  // Chat: Pagination Links
  Rx<String> lastMessagesNextUrl = ''.obs;
  Rx<String> lastMessagesPreviousUrl = ''.obs;
  Rx<String> chatMessagesNextUrl = ''.obs;
  Rx<String> chatMessagesPreviousUrl = ''.obs;

  void setClearChatMessages() {
    isChatBlocked.value = false;
    chatBlockedBy.value = 0;
    chatMessagesNextUrl.value = '';
    chatMessagesPreviousUrl.value = '';
    listChatMessage.clear();
  }

  void setClearLastMessages() {
    lastMessagesNextUrl.value = '';
    lastMessagesPreviousUrl.value = '';
    listLastMessage.clear();
  }

  void setMessageText({required String text}) {
    messageText.value = text.trim();
  }

  void clearMessageText() {
    messageText.value = '';
  }

  void tryToFetchLastChatessages({
    required int uid,
    String? url,
  }) async {
    if (loadingLastMessageList.value) {
      return;
    }
    url ??= kLastChatMessageListUrl(userId: uid);

    loadingLastMessageList.value = true;

    var dio = Dio();
    try {
      final response = await dio.get(
        url,
        options: Options(headers: {
          'accept': '*/*',
          // 'Authorization': 'Token ${authController.token.value}',
          'X-Api-Key': DRF_API_KEY,
        }),
      );
      int? statusCode = response.statusCode;
      loadingLastMessageList.value = false;
      if (statusCode == 200) {
        if (lastMessagesNextUrl.isEmpty) {
          listLastMessage
              .assignAll(response.data['results']['last_message_list']);
        } else {
          listLastMessage.assignAll([
            ...listLastMessage,
            ...response.data['results']['last_message_list']
          ]);
        }
        lastMessagesNextUrl.value = response.data['next'] ?? '';
        lastMessagesPreviousUrl.value = response.data['previous'] ?? '';
      }
    } catch (e) {
      loadingLastMessageList.value = false;
    }
  }

  void loadLastMessagesMoreData({
    required int uid,
  }) {
    if (lastMessagesNextUrl.isNotEmpty) {
      tryToFetchLastChatessages(uid: uid, url: lastMessagesNextUrl.value);
    }
  }

  void tryToFetchChatMessages({
    required String chatId,
    String? url,
  }) async {
    if (loadingMessageList.value) {
      return;
    }
    url ??= kChatMessageListUrl(chatId: chatId);
    loadingMessageList.value = true;
    dynamic data = {
      'user_id': _authController.profile.value.user!.uid!,
    };
    var dio = Dio();
    try {
      final response = await dio.get(
        url,
        queryParameters: data,
        options: Options(headers: {
          'accept': '*/*',
          // 'Authorization': 'Token ${authController.token.value}',
          'X-Api-Key': DRF_API_KEY,
        }),
      );
      int? statusCode = response.statusCode;
      loadingMessageList.value = false;
      if (statusCode == 200) {
        dynamic responseData = response.data;
        if (chatMessagesNextUrl.isEmpty) {
          listChatMessage.assignAll(responseData['results']['message_list']);
        } else {
          listChatMessage.assignAll([
            ...listChatMessage,
            ...responseData['results']['message_list'],
          ]);
        }
        chatMessagesNextUrl.value = responseData['next'] ?? '';
        chatMessagesPreviousUrl.value = responseData['previous'] ?? '';
        if (responseData['results']['is_blocked'] != null) {
          isChatBlocked.value = responseData['results']['is_blocked'];
          chatBlockedBy.value = responseData['results']['blocked_by'];
        }
      }
    } catch (e) {
      loadingMessageList.value = false;
    }
  }

  void loadChatMessagesMoreData({
    required String chatId,
  }) {
    if (chatMessagesNextUrl.isNotEmpty) {
      tryToFetchChatMessages(chatId: chatId, url: chatMessagesNextUrl.value);
    }
  }

  void tryToSendChatMessage({
    required dynamic data,
  }) async {
    var dio = Dio();
    try {
      final response = await dio.post(
        kChatMessageCreateUrl,
        data: data,
        options: Options(headers: {
          'accept': '*/*',
          // 'Authorization': 'Token ${authController.token.value}',
          'X-Api-Key': DRF_API_KEY,
        }),
      );
      // int? statusCode = response.statusCode;
      // if (statusCode == 201) {
      //   // Created
      // }
    } catch (e) {
      //
    }
  }

  Future<bool> tryToDeleteChatMessage({
    required dynamic data,
  }) async {
    var dio = Dio();
    try {
      final response = await dio.post(
        kChatMessageDeleteUrl,
        data: data,
        options: Options(headers: {
          'accept': '*/*',
          // 'Authorization': 'Token ${authController.token.value}',
          'X-Api-Key': DRF_API_KEY,
        }),
      );
      int? statusCode = response.statusCode;
      if (statusCode == 200) {
        // Deleted
        if (data['action'] == 'last_message') {
          listLastMessage
              .removeWhere((element) => element['chat_id'] == data['chat_id']);
        } else if (data['action'] == 'one_message') {
          listChatMessage.removeWhere((element) =>
              element['chat_id'] == data['chat_id'] &&
              (element['id'] == data['message_id'] ||
                  element['key'] == data['key']));
        }
      }
    } catch (e) {
      //
    }
    return true;
  }

  Future<bool> tryToUpdateChatBlock({
    required String chatId,
  }) async {
    loadingChatBlock.value = true;
    int myUid = _authController.profile.value.user!.uid!;
    dynamic data = {
      'chat_id': chatId,
      'user_id': myUid,
    };
    var dio = Dio();
    try {
      final response = await dio.put(
        kChatBlockUpdateUrl,
        data: data,
        options: Options(headers: {
          'accept': '*/*',
          // 'Authorization': 'Token ${authController.token.value}',
          'X-Api-Key': DRF_API_KEY,
        }),
      );
      int? statusCode = response.statusCode;

      loadingChatBlock.value = false;
      if (statusCode == 200) {
        isChatBlocked.value = response.data['is_blocked'];
        chatBlockedBy.value = response.data['blocked_by'];

        if (!response.data['is_blocked'] && listChatBlock.isNotEmpty) {
          List<dynamic> ids = chatId.split('_');
          int receiverID = 0;
          if (int.parse(ids[0].toString()) == myUid) {
            receiverID = int.parse(ids[1].toString());
          } else {
            receiverID = int.parse(ids[0].toString());
          }
          listChatBlock
              .removeWhere((element) => element['user_id'] == receiverID);
        }
      }
    } catch (e) {
      loadingChatBlock.value = false;
    }
    return true;
  }

  void tryToFetchChatBlockList() async {
    if (loadingChatBlock.value) {
      return;
    }
    loadingChatBlock.value = true;

    var dio = Dio();
    try {
      final response = await dio.get(
        kChatBlockListUrl(userId: _authController.profile.value.user!.uid!),
        options: Options(headers: {
          'accept': '*/*',
          // 'Authorization': 'Token ${authController.token.value}',
          'X-Api-Key': DRF_API_KEY,
        }),
      );
      int? statusCode = response.statusCode;
      loadingChatBlock.value = false;
      if (statusCode == 200) {
        listChatBlock.assignAll(response.data['block_list']);
      }
    } catch (e) {
      loadingChatBlock.value = false;
    }
  }
}
