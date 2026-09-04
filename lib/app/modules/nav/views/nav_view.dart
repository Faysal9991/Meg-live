import 'package:doyel_live/app/theme/app_colors.dart';
import 'dart:convert';
import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:doyel_live/app/data/profile_model.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/models/top_host.dart';
import 'package:doyel_live/app/modules/live_streaming/views/broadcast/prepare_to_live_view.dart';
import 'package:doyel_live/app/modules/live_streaming/views/streaming_list_view.dart';
import 'package:doyel_live/app/modules/messenger/views/messenger_view.dart';
import 'package:doyel_live/app/modules/profile/controllers/profile_controller.dart';
import 'package:doyel_live/app/modules/profile/views/profile_view.dart';
import 'package:doyel_live/app/modules/profile/views/search_view.dart';
import 'package:doyel_live/app/utils/NetworkConnectivity.dart';
import 'package:doyel_live/app/utils/api_endpoints.dart';
import 'package:doyel_live/app/utils/api_logger.dart';
import 'package:doyel_live/app/utils/constants.dart';
import 'package:doyel_live/app/utils/drf_api_key.dart';
import 'package:doyel_live/app/utils/firebase_stuffs/firebase_functions.dart';
import 'package:doyel_live/app/utils/firebase_stuffs/helper_functions.dart';
import 'package:doyel_live/app/widgets/app_design_widgets.dart';
import 'package:doyel_live/app/widgets/custom_tab_bar.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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

const List<CustomTabItem> _navItems = [
  CustomTabItem(
    label: 'Home',
    activeIcon: EvaIcons.home,
    inactiveIcon: EvaIcons.homeOutline,
  ),
  CustomTabItem(
    label: 'Search',
    activeIcon: EvaIcons.search,
    inactiveIcon: EvaIcons.searchOutline,
  ),
  CustomTabItem(
    label: 'Live',
    activeIcon: EvaIcons.video,
    inactiveIcon: EvaIcons.videoOutline,
  ),
  CustomTabItem(
    label: 'Chat',
    activeIcon: EvaIcons.messageSquare,
    inactiveIcon: EvaIcons.messageSquareOutline,
  ),
  CustomTabItem(
    label: 'Profile',
    activeIcon: EvaIcons.person,
    inactiveIcon: EvaIcons.personOutline,
  ),
];

class _NavViewState extends State<NavView> with WidgetsBindingObserver {
  late LiveStreamingController _livekitStreamingController;
  late ProfileController _profileController;
  late NavController _navController;
  late AuthController _authController;
  bool isFirstTime = true, _isDisposed = false;
  bool _checkingForceUpdate = false;
  bool _showingForceUpdateDialog = false;

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
        ApiLogger.info(
          'Profile payload received and applied to AuthController.',
          tag: 'PROFILE DATA',
          data: data['profile'],
        );
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
    _livekitStreamingController.startLiveRoomListAutoRefresh();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Same fetching during internet reconnection
      _livekitStreamingController.refreshStreamingHomeFeed();
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
    _livekitStreamingController.stopLiveRoomListAutoRefresh();
    _navController.dispose();
    _profileController.dispose();
    super.dispose();
  }

  void _performDuringInternetConnection() {
    _checkAndForceUpdate();

    if (!_livekitStreamingController.isStreamingWebSocketConnected.value) {
      _livekitStreamingController.isStreamingWebSocketConnected.value = true;
      // _livekitStreamingController.initLiveListStateChanges();
      if (!isFirstTime) {
        _livekitStreamingController.refreshStreamingHomeFeed();
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
        _livekitStreamingController.startLiveRoomListAutoRefresh();
        _initializeNetworkConnectivity();
        _checkAndForceUpdate();

        // print("app in resumed");
        break;
      case AppLifecycleState.inactive:
        // print("app in inactive");
        break;
      case AppLifecycleState.paused:
        _livekitStreamingController.stopLiveRoomListAutoRefresh();
        // print("app in paused");
        break;
      case AppLifecycleState.detached:
        // print("app in detached");
        _isDisposed = true;
        _livekitStreamingController.stopLiveRoomListAutoRefresh();
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
      //       color: AppColors.warning,
      //       durationInSeconds: 1);
      //   // rShowSnackBar(
      //   //     context: context,
      //   //     title:
      //   //         "${_authController.preferences.getBool('internet', defaultValue: false).getValue() ? 'You are online now' : 'You are offline now'}",
      //   //     color: _authController.preferences
      //   //             .getBool('internet', defaultValue: false)
      //   //             .getValue()
      //   //         ? AppColors.success
      //   //         : AppColors.error,
      //   //     durationInSeconds: 1);
      // }
    });
  }

  Future<void> _checkAndForceUpdate() async {
    if (!mounted || _checkingForceUpdate || !GetPlatform.isAndroid) {
      return;
    }
    _checkingForceUpdate = true;
    try {
      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability != UpdateAvailability.updateAvailable) {
        return;
      }

      if (updateInfo.immediateUpdateAllowed) {
        try {
          await InAppUpdate.performImmediateUpdate();
          return;
        } catch (_) {
          // Fallback to a hard-blocking dialog if immediate update fails.
        }
      }

      await _showForceUpdateDialog();
    } catch (_) {
      // Silent fail to avoid crashing app startup on Play services issues.
    } finally {
      _checkingForceUpdate = false;
    }
  }

  Future<void> _showForceUpdateDialog() async {
    if (!mounted || _showingForceUpdateDialog) {
      return;
    }
    _showingForceUpdateDialog = true;
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text('Update Required'),
            content: const Text(
              'A new version is available on Play Store. Please update to continue using Biho Live.',
            ),
            actions: [
              FilledButton(
                onPressed: _openPlayStoreListing,
                child: const Text('Update Now'),
              ),
            ],
          ),
        );
      },
    );
    _showingForceUpdateDialog = false;
  }

  Future<void> _openPlayStoreListing() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final packageName = packageInfo.packageName;
    final marketUri = Uri.parse('market://details?id=$packageName');
    final webUri = Uri.parse(
      'https://play.google.com/store/apps/details?id=$packageName',
    );

    final openedMarket = await launchUrl(
      marketUri,
      mode: LaunchMode.externalApplication,
    );
    if (!openedMarket) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _showTopRankingsBottomSheet() async {
    _livekitStreamingController.loadTopHostList();
    _livekitStreamingController.loadTopContributorList();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return DefaultTabController(
          length: 2,
          child: SafeArea(
            child: SizedBox(
              height: MediaQuery.of(sheetContext).size.height * 0.72,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.workspace_premium,
                          color: AppColors.premium,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Top Rankings',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Obx(() {
                          final loading =
                              _livekitStreamingController
                                  .loadingTopHostList
                                  .value ||
                              _livekitStreamingController
                                  .loadingTopContributorList
                                  .value;
                          return IconButton(
                            tooltip: 'Refresh',
                            onPressed: loading
                                ? null
                                : () {
                                    _livekitStreamingController
                                        .loadTopHostList();
                                    _livekitStreamingController
                                        .loadTopContributorList();
                                  },
                            icon: loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.refresh),
                          );
                        }),
                        IconButton(
                          tooltip: 'Close',
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const TabBar(
                      tabs: [
                        Tab(text: 'Hosts'),
                        Tab(text: 'Contributors'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: TabBarView(
                        children: [
                          Obx(
                            () => _buildRankingList(
                              profiles: _livekitStreamingController.topHostList,
                              loading: _livekitStreamingController
                                  .loadingTopHostList
                                  .value,
                              emptyMessage: 'No top hosts found.',
                              trailingIcon: Icons.workspace_premium,
                            ),
                          ),
                          Obx(
                            () => _buildRankingList(
                              profiles: _livekitStreamingController
                                  .topContributorList,
                              loading: _livekitStreamingController
                                  .loadingTopContributorList
                                  .value,
                              emptyMessage: 'No top contributors found.',
                              trailingIcon: Icons.diamond_outlined,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRankingList({
    required List<TopHost> profiles,
    required bool loading,
    required String emptyMessage,
    required IconData trailingIcon,
  }) {
    if (loading && profiles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (profiles.isEmpty) {
      return Center(
        child: Text(
          emptyMessage,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    return ListView.separated(
      itemCount: profiles.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, index) => _buildRankingSheetItem(
        profile: profiles[index],
        trailingIcon: trailingIcon,
      ),
    );
  }

  Widget _buildRankingSheetItem({
    required TopHost profile,
    required IconData trailingIcon,
  }) {
    final hasImage =
        profile.profileImage != null && profile.profileImage!.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.disabledBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.overlayLight,
            backgroundImage: hasImage
                ? NetworkImage(profile.profileImage!)
                : null,
            child: hasImage ? null : const Icon(Icons.person),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'UID #${profile.uid}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatRankingSeconds(profile.seconds),
                  style: const TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(trailingIcon, color: AppColors.premium, size: 22),
        ],
      ),
    );
  }

  String _formatRankingSeconds(int seconds) {
    final duration = Duration(seconds: seconds);
    String twoDigits(int value) => value.toString().padLeft(2, '0');
    return [
      twoDigits(duration.inHours),
      twoDigits(duration.inMinutes.remainder(60)),
      twoDigits(duration.inSeconds.remainder(60)),
    ].join(':');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: DefaultTabController(
          length: _navItems.length,
          child: Obx(() {
            return Scaffold(
              // Keep every tab's scrollable content above the floating-style
              // navigation card. When this is true, Scaffold intentionally
              // lays the body out behind the bottomNavigationBar.
              extendBody: false,
              appBar: _navController.pageIndex.value != LIVE_STREAM
                  ? AppBar(
                      leading: Center(
                        child: Image.asset(
                          'assets/logos/biho.png',
                          width: 46,
                          height: 46,
                        ),
                      ),
                      title: const Text(
                        'Biho Live',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: NeumorphicIconButton(
                            tooltip: 'Top Hosts and Contributors',
                            onPressed: _showTopRankingsBottomSheet,
                            icon: Icons.workspace_premium,
                            iconColor: AppColors.primary,
                            size: 38,
                            iconSize: 20,
                          ),
                        ),
                      ],
                      backgroundColor: AppColors.secondary,
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
                  //           color: AppColors.overlay,
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
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: AppCard(
                  child: CustomTabBar(
                    items: _navItems,
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
                        //     backgroundColor: AppColors.warning,
                        //     colorText: AppColors.surface,
                        //     snackPosition: SnackPosition.BOTTOM,
                        //     duration: const Duration(seconds: 2),
                        //   );
                        //   return;
                        // }
                        // if (_authController.showingCallWidget.value) {
                        //   Get.snackbar(
                        //     'Not allowed',
                        //     "You are already in call.",
                        //     backgroundColor: AppColors.warning,
                        //     colorText: AppColors.surface,
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
  final url = kProfileRetrieveUrl(userId);
  try {
    ApiLogger.hit(method: 'GET', url: url);

    final response = await dio.get(
      url,
      options: Options(
        headers: {
          'accept': '*/*',
          'Authorization': 'Token $token',
          'X-Api-Key': DRF_API_KEY,
        },
      ),
    );
    ApiLogger.response(
      method: 'GET',
      url: url,
      statusCode: response.statusCode,
      data: response.data,
    );

    int? statusCode = response.statusCode;
    if (statusCode == 200) {
      Isolate.exit(sendPort, response.data);
    }
    Isolate.exit(sendPort);
  } catch (error, stackTrace) {
    ApiLogger.error(
      method: 'GET',
      url: url,
      error: error,
      stackTrace: stackTrace,
      statusCode: error is DioException ? error.response?.statusCode : null,
      data: error is DioException ? error.response?.data : null,
    );
    Isolate.exit(sendPort);
  }
}
