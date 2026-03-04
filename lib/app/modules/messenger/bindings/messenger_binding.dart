import 'package:get/get.dart';

import '../controllers/messenger_controller.dart';

class MessengerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MessengerController>(
      () => MessengerController(),
    );
  }
}
