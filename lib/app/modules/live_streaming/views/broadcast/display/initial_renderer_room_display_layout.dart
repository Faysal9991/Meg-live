import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/views/broadcast/display/room_display_layout.dart';
import 'package:flutter/material.dart';

class InitialRendererRoomDisplayLayout {
  static Widget initialRendererView({
    required double screenGlobalWidth,
    required double screenGlobalHeight,
    required LiveStreamingController livekitStreamingController,
  }) {
    double activeCallerScreenWidth = screenGlobalWidth * .33;

    switch (livekitStreamingController.listRenderView.length) {
      case 1:
        return RoomDisplayLayout.displayInitialRendererScreen(
          view: livekitStreamingController.listRenderView[0],
          roomWidth: screenGlobalWidth,
          roomHeight: screenGlobalHeight,
        );

      case 2:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                RoomDisplayLayout.displayInitialRendererScreen(
                  view: livekitStreamingController.listRenderView[0],
                  roomWidth: screenGlobalWidth / 2,
                  roomHeight: screenGlobalHeight * .40,
                ),
                RoomDisplayLayout.displayInitialRendererScreen(
                  view: livekitStreamingController.listRenderView[1],
                  roomWidth: screenGlobalWidth / 2,
                  roomHeight: screenGlobalHeight * .40,
                ),
              ],
            ),
          ],
        );
      case 3:
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[0],
                    roomWidth: activeCallerScreenWidth * 1.5,
                    roomHeight: screenGlobalHeight * .30,
                  ),
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[1],
                    roomWidth: activeCallerScreenWidth * 1.5,
                    roomHeight: screenGlobalHeight * .30,
                  ),
                ],
              ),
              RoomDisplayLayout.displayInitialRendererScreen(
                view: livekitStreamingController.listRenderView[2],
                roomWidth: activeCallerScreenWidth * 1.5,
                roomHeight: screenGlobalHeight * .30,
              ),
            ],
          ),
        );

      case 4:
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
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[0],
                    roomWidth: activeCallerScreenWidth * 1.5,
                    roomHeight: screenGlobalHeight * .30,
                  ),
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[1],
                    roomWidth: activeCallerScreenWidth * 1.5,
                    roomHeight: screenGlobalHeight * .30,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[2],
                    roomWidth: activeCallerScreenWidth * 1.5,
                    roomHeight: screenGlobalHeight * .30,
                  ),
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[3],
                    roomWidth: activeCallerScreenWidth * 1.5,
                    roomHeight: screenGlobalHeight * .30,
                  ),
                ],
              ),
            ],
          ),
        );
      case 5:
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[0],
                    roomWidth: activeCallerScreenWidth * 2,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RoomDisplayLayout.displayInitialRendererScreen(
                        view: livekitStreamingController.listRenderView[1],
                        roomWidth: activeCallerScreenWidth,
                      ),
                      RoomDisplayLayout.displayInitialRendererScreen(
                        view: livekitStreamingController.listRenderView[2],
                        roomWidth: activeCallerScreenWidth,
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[3],
                    roomWidth: activeCallerScreenWidth,
                  ),
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[4],
                    roomWidth: activeCallerScreenWidth,
                  ),
                ],
              ),
            ],
          ),
        );
      case 6:
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[0],
                    roomWidth: activeCallerScreenWidth * 2,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RoomDisplayLayout.displayInitialRendererScreen(
                        view: livekitStreamingController.listRenderView[1],
                        roomWidth: activeCallerScreenWidth,
                      ),
                      RoomDisplayLayout.displayInitialRendererScreen(
                        view: livekitStreamingController.listRenderView[2],
                        roomWidth: activeCallerScreenWidth,
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[3],
                    roomWidth: activeCallerScreenWidth,
                  ),
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[4],
                    roomWidth: activeCallerScreenWidth,
                  ),
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[5],
                    roomWidth: activeCallerScreenWidth,
                  ),
                ],
              ),
            ],
          ),
        );

      case 7:
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[0],
                    roomWidth: activeCallerScreenWidth * 2,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RoomDisplayLayout.displayInitialRendererScreen(
                        view: livekitStreamingController.listRenderView[1],
                        roomWidth: activeCallerScreenWidth,
                      ),
                      RoomDisplayLayout.displayInitialRendererScreen(
                        view: livekitStreamingController.listRenderView[2],
                        roomWidth: activeCallerScreenWidth,
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[3],
                    roomWidth: activeCallerScreenWidth,
                  ),
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[4],
                    roomWidth: activeCallerScreenWidth,
                  ),
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[5],
                    roomWidth: activeCallerScreenWidth,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[6],
                    roomWidth: activeCallerScreenWidth,
                  ),
                ],
              ),
            ],
          ),
        );
      case 8:
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[0],
                    roomWidth: activeCallerScreenWidth * 2,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RoomDisplayLayout.displayInitialRendererScreen(
                        view: livekitStreamingController.listRenderView[1],
                        roomWidth: activeCallerScreenWidth,
                      ),
                      RoomDisplayLayout.displayInitialRendererScreen(
                        view: livekitStreamingController.listRenderView[2],
                        roomWidth: activeCallerScreenWidth,
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[3],
                    roomWidth: activeCallerScreenWidth,
                  ),
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[4],
                    roomWidth: activeCallerScreenWidth,
                  ),
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[5],
                    roomWidth: activeCallerScreenWidth,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[6],
                    roomWidth: activeCallerScreenWidth,
                  ),
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[7],
                    roomWidth: activeCallerScreenWidth,
                  ),
                ],
              ),
            ],
          ),
        );
      case 9:
        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[0],
                    roomWidth: activeCallerScreenWidth * 2,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RoomDisplayLayout.displayInitialRendererScreen(
                        view: livekitStreamingController.listRenderView[1],
                        roomWidth: activeCallerScreenWidth,
                      ),
                      RoomDisplayLayout.displayInitialRendererScreen(
                        view: livekitStreamingController.listRenderView[2],
                        roomWidth: activeCallerScreenWidth,
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[3],
                    roomWidth: activeCallerScreenWidth,
                  ),
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[4],
                    roomWidth: activeCallerScreenWidth,
                  ),
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[5],
                    roomWidth: activeCallerScreenWidth,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[6],
                    roomWidth: activeCallerScreenWidth,
                  ),
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[7],
                    roomWidth: activeCallerScreenWidth,
                  ),
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[8],
                    roomWidth: activeCallerScreenWidth,
                  ),
                ],
              ),
            ],
          ),
        );

      // Using more than 9 to support room hiding issue
      case 10:
      case 11:
      case 12:
      case 13:
      case 14:
      case 15:
        return SingleChildScrollView(
          // 1,2,3
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[0],
                    roomWidth: activeCallerScreenWidth * 2,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RoomDisplayLayout.displayInitialRendererScreen(
                        view: livekitStreamingController.listRenderView[1],
                        roomWidth: activeCallerScreenWidth,
                      ),
                      RoomDisplayLayout.displayInitialRendererScreen(
                        view: livekitStreamingController.listRenderView[2],
                        roomWidth: activeCallerScreenWidth,
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
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[3],
                    roomWidth: activeCallerScreenWidth,
                  ),
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[4],
                    roomWidth: activeCallerScreenWidth,
                  ),
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[5],
                    roomWidth: activeCallerScreenWidth,
                  ),
                ],
              ),
              // 7,8,9
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[6],
                    roomWidth: activeCallerScreenWidth,
                  ),
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[7],
                    roomWidth: activeCallerScreenWidth,
                  ),
                  RoomDisplayLayout.displayInitialRendererScreen(
                    view: livekitStreamingController.listRenderView[8],
                    roomWidth: activeCallerScreenWidth,
                  ),
                ],
              ),
              // 10,11,12
              livekitStreamingController.listRenderView.length < 10
                  ? Container()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        RoomDisplayLayout.displayInitialRendererScreen(
                          view: livekitStreamingController.listRenderView[9],
                          roomWidth: activeCallerScreenWidth,
                        ),
                        livekitStreamingController.listRenderView.length < 11
                            ? Container()
                            : RoomDisplayLayout.displayInitialRendererScreen(
                                view: livekitStreamingController
                                    .listRenderView[10],
                                roomWidth: activeCallerScreenWidth,
                              ),
                        livekitStreamingController.listRenderView.length < 12
                            ? Container()
                            : RoomDisplayLayout.displayInitialRendererScreen(
                                view: livekitStreamingController
                                    .listRenderView[11],
                                roomWidth: activeCallerScreenWidth,
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
