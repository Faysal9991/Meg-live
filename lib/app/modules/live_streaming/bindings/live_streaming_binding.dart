import 'package:get/get.dart';

import '../controllers/live_streaming_controller.dart';

class LiveStreamingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LiveStreamingController>(
      () => LiveStreamingController(),
    );
  }
}
