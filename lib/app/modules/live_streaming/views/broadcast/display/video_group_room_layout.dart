import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/views/broadcast/display/room_display_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';

class VideoGroupRoomLayout {
  static Widget generateGroupRooms({
    required double screenGlobalWidth,
    required double screenGlobalHeight,
    required String channelName,
    required bool isBroadcaster,
    required BuildContext context,
    required Function onUpdateAction,
    required LiveStreamingController livekitStreamingController,
    required AuthController authController,
  }) {
    int myUid = authController.profile.value.user!.uid!;
    final views = livekitStreamingController.listRenderView;

    double activeCallerScreenWidth = screenGlobalWidth * .33;
    // working 1
    switch (livekitStreamingController.listActiveCall.length) {
      case 1:
        return Obx(() {
          return Container(
            margin: EdgeInsets.zero,
            alignment: Alignment.topRight,
            child: RoomDisplayLayout.displayScreenView(
              view: views.firstWhereOrNull(
                (element) =>
                    element.participant.identity ==
                    livekitStreamingController.listActiveCall[0]['uid']
                        .toString(),
              ),
              data: livekitStreamingController.listActiveCall[0],
              roomWidth: screenGlobalWidth,
              roomHeight: screenGlobalHeight,
              channelName: channelName,
              myUid: myUid,
              isBroadcaster: isBroadcaster,
              onUpdateAction: onUpdateAction,
              livekitStreamingController: livekitStreamingController,
              authController: authController,
              context: context,
            ),
          );
        });
      case 2:
        return Obx(() {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    RoomDisplayLayout.displayScreenView(
                      view: views.firstWhereOrNull(
                        (element) =>
                            element.participant.identity ==
                            livekitStreamingController.listActiveCall[0]['uid']
                                .toString(),
                      ),
                      data: livekitStreamingController.listActiveCall[0],
                      roomWidth: screenGlobalWidth / 2,
                      roomHeight: screenGlobalHeight * .40,
                      channelName: channelName,
                      myUid: myUid,
                      isBroadcaster: isBroadcaster,
                      onUpdateAction: onUpdateAction,
                      livekitStreamingController: livekitStreamingController,
                      authController: authController,
                      context: context,
                    ),

                    RoomDisplayLayout.displayScreenView(
                      view: views.firstWhereOrNull(
                        (element) =>
                            element.participant.identity ==
                            livekitStreamingController.listActiveCall[1]['uid']
                                .toString(),
                      ),
                      data: livekitStreamingController.listActiveCall[1],
                      roomWidth: screenGlobalWidth / 2,
                      roomHeight: screenGlobalHeight * .40,
                      channelName: channelName,
                      myUid: myUid,
                      isBroadcaster: isBroadcaster,
                      onUpdateAction: onUpdateAction,
                      livekitStreamingController: livekitStreamingController,
                      authController: authController,
                      context: context,
                    ),
                  ],
                ),
              ],
            ),
          );
        });
      case 3:
        return Obx(() {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    RoomDisplayLayout.displayScreenView(
                      view: views.firstWhereOrNull(
                        (element) =>
                            element.participant.identity ==
                            livekitStreamingController.listActiveCall[0]['uid']
                                .toString(),
                      ),
                      data: livekitStreamingController.listActiveCall[0],
                      roomWidth: screenGlobalWidth / 2,
                      roomHeight: screenGlobalHeight * .30,
                      channelName: channelName,
                      myUid: myUid,
                      isBroadcaster: isBroadcaster,
                      onUpdateAction: onUpdateAction,
                      livekitStreamingController: livekitStreamingController,
                      authController: authController,
                      context: context,
                    ),

                    RoomDisplayLayout.displayScreenView(
                      view: views.firstWhereOrNull(
                        (element) =>
                            element.participant.identity ==
                            livekitStreamingController.listActiveCall[1]['uid']
                                .toString(),
                      ),
                      data: livekitStreamingController.listActiveCall[1],
                      roomWidth: screenGlobalWidth / 2,
                      roomHeight: screenGlobalHeight * .30,
                      channelName: channelName,
                      myUid: myUid,
                      isBroadcaster: isBroadcaster,
                      onUpdateAction: onUpdateAction,
                      livekitStreamingController: livekitStreamingController,
                      authController: authController,
                      context: context,
                    ),
                  ],
                ),
                RoomDisplayLayout.displayScreenView(
                  view: views.firstWhereOrNull(
                    (element) =>
                        element.participant.identity ==
                        livekitStreamingController.listActiveCall[2]['uid']
                            .toString(),
                  ),
                  data: livekitStreamingController.listActiveCall[2],
                  roomWidth: screenGlobalWidth / 2,
                  roomHeight: screenGlobalHeight * .30,
                  channelName: channelName,
                  myUid: myUid,
                  isBroadcaster: isBroadcaster,
                  onUpdateAction: onUpdateAction,
                  livekitStreamingController: livekitStreamingController,
                  authController: authController,
                  context: context,
                ),
              ],
            ),
          );
        });

      case 4:
        return Obx(() {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    RoomDisplayLayout.displayScreenView(
                      view: views.firstWhereOrNull(
                        (element) =>
                            element.participant.identity ==
                            livekitStreamingController.listActiveCall[0]['uid']
                                .toString(),
                      ),
                      data: livekitStreamingController.listActiveCall[0],
                      roomWidth: screenGlobalWidth / 2,
                      roomHeight: screenGlobalHeight * .30,
                      channelName: channelName,
                      myUid: myUid,
                      isBroadcaster: isBroadcaster,
                      onUpdateAction: onUpdateAction,
                      livekitStreamingController: livekitStreamingController,
                      authController: authController,
                      context: context,
                    ),

                    RoomDisplayLayout.displayScreenView(
                      view: views.firstWhereOrNull(
                        (element) =>
                            element.participant.identity ==
                            livekitStreamingController.listActiveCall[1]['uid']
                                .toString(),
                      ),
                      data: livekitStreamingController.listActiveCall[1],
                      roomWidth: screenGlobalWidth / 2,
                      roomHeight: screenGlobalHeight * .30,
                      channelName: channelName,
                      myUid: myUid,
                      isBroadcaster: isBroadcaster,
                      onUpdateAction: onUpdateAction,
                      livekitStreamingController: livekitStreamingController,
                      authController: authController,
                      context: context,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    RoomDisplayLayout.displayScreenView(
                      view: views.firstWhereOrNull(
                        (element) =>
                            element.participant.identity ==
                            livekitStreamingController.listActiveCall[2]['uid']
                                .toString(),
                      ),
                      data: livekitStreamingController.listActiveCall[2],
                      roomWidth: screenGlobalWidth / 2,
                      roomHeight: screenGlobalHeight * .30,
                      channelName: channelName,
                      myUid: myUid,
                      isBroadcaster: isBroadcaster,
                      onUpdateAction: onUpdateAction,
                      livekitStreamingController: livekitStreamingController,
                      authController: authController,
                      context: context,
                    ),

                    RoomDisplayLayout.displayScreenView(
                      view: views.firstWhereOrNull(
                        (element) =>
                            element.participant.identity ==
                            livekitStreamingController.listActiveCall[3]['uid']
                                .toString(),
                      ),
                      data: livekitStreamingController.listActiveCall[3],
                      roomWidth: screenGlobalWidth / 2,
                      roomHeight: screenGlobalHeight * .30,
                      channelName: channelName,
                      myUid: myUid,
                      isBroadcaster: isBroadcaster,
                      onUpdateAction: onUpdateAction,
                      livekitStreamingController: livekitStreamingController,
                      authController: authController,
                      context: context,
                    ),
                  ],
                ),
              ],
            ),
          );
        });

      case 5:
      case 6:
      case 7:
      case 8:
      case 9:
      // Using more than 9 to support room hiding issue
      case 10:
      case 11:
      case 12:
      case 13:
      case 14:
      case 15:
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Host,2,3
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RoomDisplayLayout.displayScreenView(
                    view: views.firstWhereOrNull(
                      (element) =>
                          element.participant.identity ==
                          livekitStreamingController.listActiveCall[0]['uid']
                              .toString(),
                    ),
                    data: livekitStreamingController.listActiveCall[0],
                    serial: 'Host',
                    roomWidth: activeCallerScreenWidth * 2,
                    channelName: channelName,
                    myUid: myUid,
                    isBroadcaster: isBroadcaster,
                    onUpdateAction: onUpdateAction,
                    livekitStreamingController: livekitStreamingController,
                    authController: authController,
                    context: context,
                  ),

                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RoomDisplayLayout.displayScreenView(
                        view: views.firstWhereOrNull(
                          (element) =>
                              element.participant.identity ==
                              livekitStreamingController
                                  .listActiveCall[1]['uid']
                                  .toString(),
                        ),
                        data: livekitStreamingController.listActiveCall[1],
                        serial: '2',
                        roomWidth: activeCallerScreenWidth,
                        channelName: channelName,
                        myUid: myUid,
                        isBroadcaster: isBroadcaster,
                        onUpdateAction: onUpdateAction,
                        livekitStreamingController: livekitStreamingController,
                        authController: authController,
                        context: context,
                      ),

                      RoomDisplayLayout.displayScreenView(
                        view: views.firstWhereOrNull(
                          (element) =>
                              element.participant.identity ==
                              livekitStreamingController
                                  .listActiveCall[2]['uid']
                                  .toString(),
                        ),
                        data: livekitStreamingController.listActiveCall[2],
                        serial: '3',
                        roomWidth: activeCallerScreenWidth,
                        channelName: channelName,
                        myUid: myUid,
                        isBroadcaster: isBroadcaster,
                        onUpdateAction: onUpdateAction,
                        livekitStreamingController: livekitStreamingController,
                        authController: authController,
                        context: context,
                      ),
                    ],
                  ),
                ],
              ),
              // 4,5,6
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RoomDisplayLayout.displayScreenView(
                    view: views.firstWhereOrNull(
                      (element) =>
                          element.participant.identity ==
                          livekitStreamingController.listActiveCall[3]['uid']
                              .toString(),
                    ),
                    data: livekitStreamingController.listActiveCall[3],
                    serial: '4',
                    roomWidth: activeCallerScreenWidth,
                    channelName: channelName,
                    myUid: myUid,
                    isBroadcaster: isBroadcaster,
                    onUpdateAction: onUpdateAction,
                    livekitStreamingController: livekitStreamingController,
                    authController: authController,
                    context: context,
                  ),
                  RoomDisplayLayout.displayScreenView(
                    view: views.firstWhereOrNull(
                      (element) =>
                          element.participant.identity ==
                          livekitStreamingController.listActiveCall[4]['uid']
                              .toString(),
                    ),
                    data: livekitStreamingController.listActiveCall[4],
                    serial: '5',
                    roomWidth: activeCallerScreenWidth,
                    channelName: channelName,
                    myUid: myUid,
                    isBroadcaster: isBroadcaster,
                    onUpdateAction: onUpdateAction,
                    livekitStreamingController: livekitStreamingController,
                    authController: authController,
                    context: context,
                  ),
                  livekitStreamingController.listActiveCall.length < 6
                      ? Container()
                      : RoomDisplayLayout.displayScreenView(
                          view: views.firstWhereOrNull(
                            (element) =>
                                element.participant.identity ==
                                livekitStreamingController
                                    .listActiveCall[5]['uid']
                                    .toString(),
                          ),
                          data: livekitStreamingController.listActiveCall[5],
                          serial: '6',
                          roomWidth: activeCallerScreenWidth,
                          channelName: channelName,
                          myUid: myUid,
                          isBroadcaster: isBroadcaster,
                          onUpdateAction: onUpdateAction,
                          livekitStreamingController:
                              livekitStreamingController,
                          authController: authController,
                          context: context,
                        ),
                ],
              ),
              // 7,8,9
              livekitStreamingController.listActiveCall.length < 7
                  ? Container()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        RoomDisplayLayout.displayScreenView(
                          view: views.firstWhereOrNull(
                            (element) =>
                                element.participant.identity ==
                                livekitStreamingController
                                    .listActiveCall[6]['uid']
                                    .toString(),
                          ),
                          data: livekitStreamingController.listActiveCall[6],
                          serial: '7',
                          roomWidth: activeCallerScreenWidth,
                          channelName: channelName,
                          myUid: myUid,
                          isBroadcaster: isBroadcaster,
                          onUpdateAction: onUpdateAction,
                          livekitStreamingController:
                              livekitStreamingController,
                          authController: authController,
                          context: context,
                        ),
                        livekitStreamingController.listActiveCall.length < 8
                            ? Container()
                            : RoomDisplayLayout.displayScreenView(
                                view: views.firstWhereOrNull(
                                  (element) =>
                                      element.participant.identity ==
                                      livekitStreamingController
                                          .listActiveCall[7]['uid']
                                          .toString(),
                                ),
                                data: livekitStreamingController
                                    .listActiveCall[7],
                                serial: '8',
                                roomWidth: activeCallerScreenWidth,
                                channelName: channelName,
                                myUid: myUid,
                                isBroadcaster: isBroadcaster,
                                onUpdateAction: onUpdateAction,
                                livekitStreamingController:
                                    livekitStreamingController,
                                authController: authController,
                                context: context,
                              ),
                        livekitStreamingController.listActiveCall.length < 9
                            ? Container()
                            : RoomDisplayLayout.displayScreenView(
                                view: views.firstWhereOrNull(
                                  (element) =>
                                      element.participant.identity ==
                                      livekitStreamingController
                                          .listActiveCall[8]['uid']
                                          .toString(),
                                ),
                                data: livekitStreamingController
                                    .listActiveCall[8],
                                serial: '9',
                                roomWidth: activeCallerScreenWidth,
                                channelName: channelName,
                                myUid: myUid,
                                isBroadcaster: isBroadcaster,
                                onUpdateAction: onUpdateAction,
                                livekitStreamingController:
                                    livekitStreamingController,
                                authController: authController,
                                context: context,
                              ),
                      ],
                    ),

              // 10,11,12
              livekitStreamingController.listActiveCall.length < 10
                  ? Container()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        RoomDisplayLayout.displayScreenView(
                          view: views.firstWhereOrNull(
                            (element) =>
                                element.participant.identity ==
                                livekitStreamingController
                                    .listActiveCall[9]['uid']
                                    .toString(),
                          ),
                          data: livekitStreamingController.listActiveCall[9],
                          serial: '10',
                          roomWidth: activeCallerScreenWidth,
                          channelName: channelName,
                          myUid: myUid,
                          isBroadcaster: isBroadcaster,
                          onUpdateAction: onUpdateAction,
                          livekitStreamingController:
                              livekitStreamingController,
                          authController: authController,
                          context: context,
                        ),
                        livekitStreamingController.listActiveCall.length < 11
                            ? Container()
                            : RoomDisplayLayout.displayScreenView(
                                view: views.firstWhereOrNull(
                                  (element) =>
                                      element.participant.identity ==
                                      livekitStreamingController
                                          .listActiveCall[10]['uid']
                                          .toString(),
                                ),
                                data: livekitStreamingController
                                    .listActiveCall[10],
                                serial: '11',
                                roomWidth: activeCallerScreenWidth,
                                channelName: channelName,
                                myUid: myUid,
                                isBroadcaster: isBroadcaster,
                                onUpdateAction: onUpdateAction,
                                livekitStreamingController:
                                    livekitStreamingController,
                                authController: authController,
                                context: context,
                              ),
                        livekitStreamingController.listActiveCall.length < 12
                            ? Container()
                            : RoomDisplayLayout.displayScreenView(
                                view: views.firstWhereOrNull(
                                  (element) =>
                                      element.participant.identity ==
                                      livekitStreamingController
                                          .listActiveCall[11]['uid']
                                          .toString(),
                                ),
                                data: livekitStreamingController
                                    .listActiveCall[11],
                                serial: '12',
                                roomWidth: activeCallerScreenWidth,
                                channelName: channelName,
                                myUid: myUid,
                                isBroadcaster: isBroadcaster,
                                onUpdateAction: onUpdateAction,
                                livekitStreamingController:
                                    livekitStreamingController,
                                authController: authController,
                                context: context,
                              ),
                      ],
                    ),
            ],
          ),
        );

      default:
        return Container();
    }
  }
}
