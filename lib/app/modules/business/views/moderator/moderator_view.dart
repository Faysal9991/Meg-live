import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doyel_live/app/modules/business/controllers/devices_controller.dart';
import 'package:doyel_live/app/modules/business/views/moderator/moderator_device_blocking_history_list_view.dart';
import 'package:doyel_live/app/modules/business/views/moderator/moderator_device_blocking_view.dart';

class ModeratorView extends StatelessWidget {
  final DevicesController _devicesController = Get.put(DevicesController());

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Moderator Activity'),
            bottom: const TabBar(
              tabs: [
                Tab(
                  icon: Icon(Icons.no_accounts_rounded),
                  text: "Blocking",
                  iconMargin: EdgeInsets.zero,
                ),
                Tab(
                  icon: Icon(Icons.history),
                  text: "Histories",
                  iconMargin: EdgeInsets.zero,
                ),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              ModeratorDeviceBlockingView(),
              ModeratorDeviceBlockingHistoryListView(),
            ],
          ),
        ),
      ),
    );
  }
}
