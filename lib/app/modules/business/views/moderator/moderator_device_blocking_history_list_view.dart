import 'package:doyel_live/app/widgets/app_design_widgets.dart';
import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:doyel_live/app/modules/business/controllers/devices_controller.dart';

class ModeratorDeviceBlockingHistoryListView extends StatefulWidget {
  const ModeratorDeviceBlockingHistoryListView({Key? key}) : super(key: key);

  @override
  _ModeratorDeviceBlockingHistoryListViewState createState() =>
      _ModeratorDeviceBlockingHistoryListViewState();
}

class _ModeratorDeviceBlockingHistoryListViewState
    extends State<ModeratorDeviceBlockingHistoryListView> {
  final DevicesController _devicesController = Get.find();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
        (_) => _devicesController.loadModeratorBlockedUserDevices());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(() {
            return _devicesController.loadingBlockedDevicesHistories.value
                ? const SpinKitCircle(
                    color: AppColors.pinkLight,
                  )
                : _devicesController.userBlockedDevicesList.isEmpty
                    ? const AppCard(
                        elevation: 5,
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "No block",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.warning,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            dynamic userBlockedDevice = _devicesController
                                .userBlockedDevicesList[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 16.0,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceHigh,
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'User ID: ${userBlockedDevice['user_id']}'),
                                  Text(
                                      'Device Name: ${userBlockedDevice['device_name']}'),
                                  Text(
                                      'Device ID: ${userBlockedDevice['device_id']}'),
                                  Text(
                                      'Blocking Datetime: ${DateFormat.yMEd().add_jms().format(DateTime.parse(userBlockedDevice['blocked_datetime']).toLocal())}'),
                                ],
                              ),
                            );
                          },
                          itemCount:
                              _devicesController.userBlockedDevicesList.length,
                        ),
                      );
          }),
        ],
      ),
    );
  }
}
