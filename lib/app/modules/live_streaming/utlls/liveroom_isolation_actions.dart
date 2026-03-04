import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:doyel_live/app/utils/api_endpoints.dart';
import 'package:doyel_live/app/utils/drf_api_key.dart';

class LiveRoomIsolationActions {
  static void useIsolateUpdateLiveRoom(
      {required dynamic submissionData}) async {
    var recievePort = ReceivePort(); //creating new port to listen data
    await Isolate.spawn(_tryToUpdatingLiveRoom, [
      recievePort.sendPort,
      submissionData,
    ]); //spawing/creating new thread as isolates.
    // recievePort.listen((data) {
    //   //listening data from isolate
    //   if (data != null) {
    //     // print(data[0]['contribution_rank']);
    //   }
    // });
  }

  static void useIsolateNotifyFollowerAboutLiveStreaming(
      {required String token}) async {
    var recievePort = ReceivePort(); //creating new port to listen data
    await Isolate.spawn(_tryToNotifyFollowerAboutLiveStreaming, [
      recievePort.sendPort,
      token,
    ]); //spawing/creating new thread as isolates.
  }

  static void useIsolateToDeleteContributionHistory(
      {required String token}) async {
    var recievePort = ReceivePort(); //creating new port to listen data
    await Isolate.spawn(_tryToDeleteContributionHistory, [
      recievePort.sendPort,
      token,
    ]); //spawing/creating new thread as isolates.
  }
}

void _tryToDeleteContributionHistory(List<dynamic> args) async {
  SendPort resultPort = args[0];
  dynamic token = args[1];

  var dio = Dio();
  try {
    await dio.delete(
      kContributionHistoryDeleteUrl,
      options: Options(headers: {
        'accept': '*/*',
        'Authorization': 'Token $token',
        'X-Api-Key': DRF_API_KEY,
      }),
    );
  } catch (e) {
    //
  }
  Isolate.exit(resultPort);
}

void _tryToUpdatingLiveRoom(List<dynamic> args) async {
  SendPort resultPort = args[0];
  dynamic submissionData = args[1];
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
      data: submissionData,
    );
  } catch (e) {
    //
  }
  Isolate.exit(resultPort);
}

void _tryToNotifyFollowerAboutLiveStreaming(List<dynamic> args) async {
  SendPort resultPort = args[0];
  dynamic token = args[1];

  var dio = Dio();
  try {
    await dio.post(
      kLiveStreamingNotifyFollowersCreateUrl,
      options: Options(headers: {
        'accept': '*/*',
        'Authorization': 'Token $token',
        'X-Api-Key': DRF_API_KEY,
      }),
    );
  } catch (e) {
    //
  }
  Isolate.exit(resultPort);
}
