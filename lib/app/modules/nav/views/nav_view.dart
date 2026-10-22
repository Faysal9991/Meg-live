import 'dart:async';
import 'package:doyel_live/app/theme/app_colors.dart';

import 'package:camera/camera.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/views/leaderboard_view.dart';
import 'package:doyel_live/app/modules/live_streaming/views/broadcast/prepare_to_live_view.dart';
import 'package:doyel_live/app/modules/live_streaming/views/streaming_list_view.dart';
import 'package:doyel_live/app/modules/messenger/views/messenger_view.dart';
import 'package:doyel_live/app/modules/profile/controllers/profile_controller.dart';
import 'package:doyel_live/app/modules/profile/views/profile_view.dart';
// import 'package:doyel_live/app/modules/profile/views/search_view.dart';
import 'package:doyel_live/app/utils/NetworkConnectivity.dart';
import 'package:doyel_live/app/utils/constants.dart';
import 'package:doyel_live/app/utils/firebase_stuffs/firebase_functions.dart';
import 'package:doyel_live/app/utils/firebase_stuffs/helper_functions.dart';
import 'package:doyel_live/app/widgets/app_design_widgets.dart';
import 'package:doyel_live/app/widgets/app_bottom_nav.dart';
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
    case STREAMING_LIST:
      return StreamingListView();
    // Search is under construction and hidden from the production navigation.
    // case SEARCH:
    //   return SearchView();
    // case LIVE_STREAM:
    //   // No need any view
    //   return const StreamingView(
    //     camera: null,
    //   );
    case CHATS:
      return MessengerView();
    case PROFILE:
      return ProfileView();

    default:
  }
  return Container();
}

class _NavViewState extends State<NavView> with WidgetsBindingObserver {
  late LiveStreamingController _livekitStreamingController;
  late ProfileController _profileController;
  late NavController _navController;
  late AuthController _authController;
  bool isFirstTime = true, _isDisposed = false;
  bool _checkingForceUpdate = false;
  bool _showingForceUpdateDialog = false;

  late NetworkConnectivity _networkConnectivity;
  StreamSubscription<dynamic>? _networkSubscription;
  StreamSubscription<bool>? _internetSubscription;
  bool _wasBackgrounded = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _networkConnectivity = NetworkConnectivity.instance;

    _authController = Get.find();
    _livekitStreamingController = Get.find();
    _navController = Get.put(NavController());
    _profileController = Get.put(ProfileController());
    _initializeNetworkConnectivity();

    _internetSubscription = _authController.preferences
        .getBool('internet', defaultValue: false)
        .distinct()
        .listen((bool connected) {
          if (_isDisposed) return;
          if (connected) {
            _performDuringInternetConnection();
          } else {
            _livekitStreamingController.isStreamingWebSocketConnected.value =
                false;
          }
        });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _isDisposed = true;
    _networkSubscription?.cancel();
    _internetSubscription?.cancel();
    _navController.dispose();
    _profileController.dispose();
    super.dispose();
  }

  void _performDuringInternetConnection() {
    if (_isDisposed) return;
    _checkAndForceUpdate();
    unawaited(_livekitStreamingController.initWebSocketClient());
    // The socket library reconnects automatically; connectivity notifications
    // must not start another round of dashboard/profile API requests.
    if (!isFirstTime) return;
    isFirstTime = false;
    unawaited(_livekitStreamingController.refreshStreamingHomeFeed());
    unawaited(_livekitStreamingController.refreshLoggedInProfile());
    _navController.tryUserDeviceInfoUpdate();
    if (_livekitStreamingController.listNormalGift.isEmpty) {
      _livekitStreamingController.fetchGiftList();
    }
    HelperFunctions().initDynamicLinks();
    getFCMDeviceToken().then((token) {
      if (token != null) updateFCMDeviceToken(fcmDeviceToken: token);
    });
    onFCMDeviceTokenRefresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isDisposed) return;
    switch (state) {
      case AppLifecycleState.resumed:
        _initializeNetworkConnectivity();
        unawaited(_livekitStreamingController.initWebSocketClient());
        if (_wasBackgrounded) {
          _wasBackgrounded = false;
          unawaited(_livekitStreamingController.recoverDashboardState());
        }
        _checkAndForceUpdate();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _wasBackgrounded = true;
        break;
      case AppLifecycleState.detached:
        _authController.preferences.setBool('internet', false);
        break;
      case AppLifecycleState.inactive:
        break;
    }
  }

  void _initializeNetworkConnectivity() {
    _networkConnectivity.initialise();
    // Resume calls this again; keep a single listener.
    _networkSubscription ??= _networkConnectivity.myStream.listen((source) {
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
              'A new version is available on Play Store. Please update to continue using Ringo Live.',
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

  Future<void> _showTopRankings() async {
    await Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute(
        builder: (_) => LeaderboardView(
          controller: _livekitStreamingController,
          currentUserId: _authController.profile.value.user?.uid,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: DefaultTabController(
          length: 4,
          child: Obx(() {
            return Scaffold(
              // Keep every tab's scrollable content above the floating-style
              // navigation bar. When this is true, Scaffold intentionally
              // lays the body out behind the bottomNavigationBar.
              extendBody: false,
              appBar: _navController.pageIndex.value != LIVE_STREAM
                  ? AppBar(
                      leading: Center(
                        child: Image.asset(
                          'assets/logos/ringo.png',
                          width: 46,
                          height: 46,
                        ),
                      ),
                      title: const Text(
                        'Ringo Live',
                        style: TextStyle(color: AppColors.textPrimary),
                      ),
                      actions: [
                        Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: AppIconButton(
                            tooltip: 'Top Hosts and Contributors',
                            imagePadding: 8,
                            onPressed: _showTopRankings,
                            image: AssetImage("assets/others/ranking.png"),
                            iconColor: AppColors.gold,
                            size: 38,
                            iconSize: 20,
                          ),
                        ),
                      ],
                      backgroundColor: AppColors.bg,
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
                padding: const EdgeInsets.only(bottom: 16),
                child: AppBottomNav(
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
                      if (_livekitStreamingController.liveSession
                          .restoreIfActive()) {
                        return;
                      }
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
