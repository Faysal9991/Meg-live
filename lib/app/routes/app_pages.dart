import 'package:doyel_live/app/modules/live_streaming/views/streaming_list_view.dart';
import 'package:get/get.dart';

import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/live_streaming/bindings/live_streaming_binding.dart';
import '../modules/live_streaming/views/broadcast/live_streaming_view.dart';
import '../modules/messenger/bindings/messenger_binding.dart';
import '../modules/messenger/views/messenger_view.dart';
import '../modules/nav/bindings/nav_binding.dart';
import '../modules/nav/views/nav_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.LIVE_STREAMING,
      page: () => StreamingListView(),
      binding: LiveStreamingBinding(),
    ),
    GetPage(
      name: _Paths.AUTH,
      page: () => AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.NAV,
      page: () => NavView(),
      binding: NavBinding(),
    ),
    GetPage(
      name: _Paths.MESSENGER,
      page: () => const MessengerView(),
      binding: MessengerBinding(),
    ),
  ];
}
