import 'dart:convert';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:doyel_live/app/data/profile_model.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/views/broadcast/prepare_to_live_view.dart';
import 'package:doyel_live/app/modules/live_streaming/views/streaming_list_view.dart';
import 'package:doyel_live/app/modules/messenger/views/messenger_view.dart';
import 'package:doyel_live/app/modules/profile/controllers/profile_controller.dart';
import 'package:doyel_live/app/modules/profile/views/profile_view.dart';
import 'package:doyel_live/app/modules/profile/views/search_view.dart';
import 'package:doyel_live/app/utils/NetworkConnectivity.dart';
import 'package:doyel_live/app/utils/api_endpoints.dart';
import 'package:doyel_live/app/utils/constants.dart';
import 'package:doyel_live/app/utils/drf_api_key.dart';
import 'package:doyel_live/app/utils/firebase_stuffs/firebase_functions.dart';
import 'package:doyel_live/app/utils/firebase_stuffs/helper_functions.dart';
import 'package:doyel_live/app/widgets/custom_tab_bar.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:new_version_plus/new_version_plus.dart';

import 'package:get/get.dart';
import '../controllers/nav_controller.dart';

class NavView extends StatefulWidget {
  NavView({Key? key}) : super(key: key);

  @override
  State<NavView> createState() => _NavViewState();
}

Widget _loadView({required int index}) {
  switch (index) {
    case 0:
      return StreamingListView();
    case 1:
      return SearchView();
    // case 2:
    //   // No need any view
    //   return const StreamingView(
    //     camera: null,
    //   );
    case 3:
      return MessengerView();
    case 4:
      return ProfileView();

    default:
  }
  return Container();
}

List<IconData> _icons = [
  Icons.home,
  Icons.search,
  MdiIcons.video,
  MdiIcons.chat,
  Icons.person,
];

_advancedStatusCheck({required BuildContext context}) async {
  // Instantiate NewVersion manager object (Using GCP Console app as example)
  final newVersion = NewVersionPlus();
  final status = await newVersion.getVersionStatus();

  if (status != null && status.canUpdate == true) {
    newVersion.showUpdateDialog(
      context: context,
      versionStatus: status,
      allowDismissal: false,
      dialogTitle: "Update Available",
      dialogText:
          "Please update the app from ${status.localVersion} to ${status.storeVersion}",
      launchModeVersion: LaunchModeVersion.external,
      updateButtonText: 'Update',
    );
  }
}

class _NavViewState extends State<NavView> with WidgetsBindingObserver {
  late LiveStreamingController _livekitStreamingController;
  late ProfileController _profileController;
  late NavController _navController;
  late AuthController _authController;
  bool isFirstTime = true, _isDisposed = false;

  late NetworkConnectivity _networkConnectivity;

  void _useIsolateToFetchProfile() async {
    var recievePort = ReceivePort(); //creating new port to listen data
    await Isolate.spawn(_fetchProfile, [
      recievePort.sendPort,
      _authController.token.value,
      _authController.profile.value.user!.uid!,
    ]); //spawing/creating new thread as isolates.
    recievePort.listen((data) {
      //listening data from isolate
      if (data != null) {
        _authController.profile.value = Profile();
        _authController.profile.value = Profile.fromJson(data['profile']);
        _authController.preferences.setString(
          'profile',
          jsonEncode(data['profile']),
        );
        _livekitStreamingController.liveRoomSocketBaseUrl =
            data['websocket_base_url'];
      }
    });
  }

  void _useIsolateToFetchGiftList() async {
    var recievePort = ReceivePort(); //creating new port to listen data
    await Isolate.spawn(_fetchGiftList, [
      recievePort.sendPort,
      _authController.token.value,
    ]); //spawing/creating new thread as isolates.
    recievePort.listen((data) {
      //listening data from isolate
      if (data != null) {
        // Loading gifts
        _livekitStreamingController.listNormalGift.clear();
        _livekitStreamingController.listAnimatedGift.clear();
        _livekitStreamingController.listNormalGift.addAll(data['normal_gifts']);
        _livekitStreamingController.listAnimatedGift.addAll(
          data['animated_gifts'],
        );
      }
    });
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _networkConnectivity = NetworkConnectivity.instance;
    _initializeNetworkConnectivity();

    _authController = Get.find();
    _livekitStreamingController = Get.find();
    _navController = Get.put(NavController());
    _profileController = Get.put(ProfileController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Same fetching during internet reconnection
      _livekitStreamingController.tryToLoadLiveRoomList();
    });

    _authController.preferences.getBool('internet', defaultValue: false).listen(
      (bool connected) {
        if (connected) {
          _performDuringInternetConnection();
        } else {
          _livekitStreamingController.isStreamingWebSocketConnected.value =
              false;
        }
      },
    );
    _livekitStreamingController.initTopAgentRankingList();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _isDisposed = true;
    _navController.dispose();
    _profileController.dispose();
    super.dispose();
  }

  void _performDuringInternetConnection() {
    if (!_livekitStreamingController.isStreamingWebSocketConnected.value) {
      _livekitStreamingController.isStreamingWebSocketConnected.value = true;

      // For only Temporary hide
      try {
        _advancedStatusCheck(context: context);
      } catch (e) {
        //
      }
      // _livekitStreamingController.initLiveListStateChanges();
      if (!isFirstTime) {
        _livekitStreamingController.tryToLoadLiveRoomList();
      }
      _livekitStreamingController.initWebSocketClient();

      // _initWebSocketConnectionForGlobal();
      _navController.tryUserDeviceInfoUpdate();
      // TODO: Need to use this
      if (_livekitStreamingController.listNormalGift.isEmpty) {
        _useIsolateToFetchGiftList();
      }
      _useIsolateToFetchProfile();
      if (isFirstTime) {
        isFirstTime = false;

        // Loading dynamic links
        HelperFunctions().initDynamicLinks();

        getFCMDeviceToken().then((token) {
          updateFCMDeviceToken(fcmDeviceToken: token!);
        });
        onFCMDeviceTokenRefresh();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _isDisposed = false;
        _initializeNetworkConnectivity();

        // print("app in resumed");
        break;
      case AppLifecycleState.inactive:
        // print("app in inactive");
        break;
      case AppLifecycleState.paused:
        // print("app in paused");
        break;
      case AppLifecycleState.detached:
        // print("app in detached");
        _isDisposed = true;
        _authController.preferences.setBool('internet', false);
        _networkConnectivity.disposeStream();

        break;

      case AppLifecycleState.hidden:
        break;
    }
  }

  void _initializeNetworkConnectivity() {
    _networkConnectivity.initialise();
    _networkConnectivity.myStream.listen((source) {
      // _newtworkSource = source;
      // print(
      //     'source $source............................................................');
      // print(
      //     '${source.values.toList()[0]}.................................................');
      // 1.

      // switch (source.keys.toList()[0]) {
      switch (source.keys.toList()[0][0]) {
        case ConnectivityResult.mobile:
          if (source.values.toList()[0]) {
            _authController.preferences.setBool('internet', true);
          } else {
            _authController.preferences.setBool('internet', false);
          }

          break;
        case ConnectivityResult.wifi:
          if (source.values.toList()[0]) {
            _authController.preferences.setBool('internet', true);
          } else {
            _authController.preferences.setBool('internet', false);
          }

          break;
        // Testing
        case ConnectivityResult.bluetooth:
          if (source.values.toList()[0]) {
            _authController.preferences.setBool('internet', true);
          } else {
            _authController.preferences.setBool('internet', false);
          }
          break;
        case ConnectivityResult.ethernet:
          if (source.values.toList()[0]) {
            _authController.preferences.setBool('internet', true);
          } else {
            _authController.preferences.setBool('internet', false);
          }
          break;
        case ConnectivityResult.vpn:
          if (source.values.toList()[0]) {
            _authController.preferences.setBool('internet', true);
          } else {
            _authController.preferences.setBool('internet', false);
          }
          break;
        case ConnectivityResult.other:
          if (source.values.toList()[0]) {
            _authController.preferences.setBool('internet', true);
          } else {
            _authController.preferences.setBool('internet', false);
          }
          break;
        case ConnectivityResult.none:
          _authController.preferences.setBool('internet', false);
          break;
        default:
      }
      // print(
      //     "_authController.preferences.setBool('internet', true) Streaming__ListView: ${_authController.preferences.getBool('internet', defaultValue: false).getValue()}................................................................");

      // if (!_isDisposed &&
      //     !_authController.preferences
      //         .getBool('internet', defaultValue: false)
      //         .getValue()) {
      //   rShowSnackBar(
      //       context: context,
      //       title: "You are offline now",
      //       color: Colors.orange,
      //       durationInSeconds: 1);
      //   // rShowSnackBar(
      //   //     context: context,
      //   //     title:
      //   //         "${_authController.preferences.getBool('internet', defaultValue: false).getValue() ? 'You are online now' : 'You are offline now'}",
      //   //     color: _authController.preferences
      //   //             .getBool('internet', defaultValue: false)
      //   //             .getValue()
      //   //         ? Colors.green
      //   //         : Colors.red,
      //   //     durationInSeconds: 1);
      // }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: DefaultTabController(
          length: _icons.length,
          child: Obx(() {
            return Scaffold(
              appBar: _navController.pageIndex.value != LIVE_STREAM
                  ? AppBar(
                      leading: Center(
                        child: Image.asset(
                          'assets/logos/doyel_live.png',
                          width: 46,
                          height: 46,
                        ),
                      ),
                      title: const Text(
                        'Doyel Live',
                        style: TextStyle(color: Colors.black),
                      ),
                      backgroundColor: Colors.white,
                    )
                  : null,
              body: Column(
                children: [
                  Expanded(
                    child: Obx(
                      () => _loadView(index: _navController.pageIndex.value),
                    ),
                  ),
                  // Obx(() {
                  //   return _rewardAdsController.bannerAdLoaded.value
                  //       ? Container(
                  //           color: Colors.black38,
                  //           alignment: Alignment.bottomCenter,
                  //           // width: _rewardAdsController.bannerAd!.size.width
                  //           //     .toDouble(),
                  //           width: MediaQuery.of(context).size.width,
                  //           height: _rewardAdsController.bannerAd!.size.height
                  //               .toDouble(),
                  //           child: AdWidget(ad: _rewardAdsController.bannerAd!),
                  //         )
                  //       : Container();
                  // }),
                ],
              ),
              bottomNavigationBar: Container(
                padding: const EdgeInsets.only(bottom: 12.0),
                color: Colors.white,
                child: CustomTabBar(
                  icons: _icons,
                  selectedIndex: _navController.pageIndex.value,
                  onTap: (index) async {
                    if (index == _navController.pageIndex.value) {
                      return;
                    }

                    // 2 is the broadcast streaming
                    // if (index == CHATS) {
                    //   Navigator.of(context).pushNamedAndRemoveUntil(
                    //       Routes.CHAT, (Route<dynamic> route) => false);
                    // } else

                    if (index != LIVE_STREAM) {
                      _navController.setPageIndex(index: index);
                    } else {
                      // if (_authController.showingLiveStreamingWidget.value) {
                      //   Get.snackbar(
                      //     'Not allowed',
                      //     "You have to end recent streaming.",
                      //     backgroundColor: Colors.orange,
                      //     colorText: Colors.white,
                      //     snackPosition: SnackPosition.BOTTOM,
                      //     duration: const Duration(seconds: 2),
                      //   );
                      //   return;
                      // }
                      // if (_authController.showingCallWidget.value) {
                      //   Get.snackbar(
                      //     'Not allowed',
                      //     "You are already in call.",
                      //     backgroundColor: Colors.orange,
                      //     colorText: Colors.white,
                      //     snackPosition: SnackPosition.BOTTOM,
                      //     duration: const Duration(seconds: 2),
                      //   );
                      //   return;
                      // }
                      await availableCameras().then(
                        (value) => Get.to(
                          () => PrepareToLiveView(
                            camera: value[1],
                            // onUpdateLiveStreamStatus: onUpdateLiveStreamStatus,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

void _fetchGiftList(List<dynamic> args) async {
  SendPort sendPort = args[0];
  String token = args[1];
  var dio = Dio();
  try {
    final response = await dio.get(
      kGiftListUrl,
      options: Options(
        headers: {
          'accept': '*/*',
          'Authorization': 'Token $token',
          'X-Api-Key': DRF_API_KEY,
        },
      ),
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

void _fetchProfile(List<dynamic> args) async {
  SendPort sendPort = args[0];
  String token = args[1];
  int userId = args[2];
  var dio = Dio();
  try {
    final response = await dio.get(
      kProfileRetrieveUrl(userId),
      options: Options(
        headers: {
          'accept': '*/*',
          'Authorization': 'Token $token',
          'X-Api-Key': DRF_API_KEY,
        },
      ),
    );
    int? statusCode = response.statusCode;
    if (statusCode == 200) {
      Isolate.exit(sendPort, response.data);
    }
    Isolate.exit(sendPort);
  } catch (e) {
    Isolate.exit(sendPort);
  }
}
