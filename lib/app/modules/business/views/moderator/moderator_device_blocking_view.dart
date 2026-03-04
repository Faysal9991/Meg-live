import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:doyel_live/app/modules/business/controllers/devices_controller.dart';
import 'package:doyel_live/app/widgets/reusable_widgets.dart';

class ModeratorDeviceBlockingView extends StatefulWidget {
  const ModeratorDeviceBlockingView({Key? key}) : super(key: key);

  @override
  State<ModeratorDeviceBlockingView> createState() =>
      _ModeratorDeviceBlockingViewState();
}

class _ModeratorDeviceBlockingViewState
    extends State<ModeratorDeviceBlockingView> {
  late TextEditingController _editingControllerSearchUid;
  final DevicesController _devicesController = Get.find();

  @override
  void initState() {
    super.initState();
    _editingControllerSearchUid = TextEditingController();
  }

  @override
  void dispose() {
    _editingControllerSearchUid.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 16,
          ),
          rPrimaryTextField(
            controller: _editingControllerSearchUid,
            keyboardType: TextInputType.number,
            borderColor: Theme.of(context).primaryColorLight,
            hintText: 'Search user with UserID here',
            suffixIcon: IconButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                if (_devicesController.loadingUserDeviceInfo.value) {
                  rShowSnackBar(
                    context: context,
                    title: 'You already searching a user',
                    color: Colors.orange,
                  );
                  return;
                }

                try {
                  int uid = int.parse(_editingControllerSearchUid.text);
                  if (uid > 0) {
                    _editingControllerSearchUid.clear();
                    _devicesController.tryToSearchUserDevicesInfoForUserId(
                        userId: uid);
                  }
                } catch (e) {
                  rShowSnackBar(
                    context: context,
                    title: 'You must enter number for UserID',
                    color: Colors.orange,
                    durationInSeconds: 2,
                  );
                }
              },
              icon: const Icon(
                Icons.search,
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Obx(
            () => _devicesController.loadingUserDeviceInfo.value
                ? const Center(
                    child: SpinKitCircle(color: Colors.red),
                  )
                : _devicesController.userDevicesInfoList.isEmpty
                    ? const Text("User doesn't exists.")
                    : Expanded(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            dynamic userDeviceInfo =
                                _devicesController.userDevicesInfoList[index];
                            return InkWell(
                              onTap: () {
                                Get.defaultDialog(
                                  title:
                                      'User ID: ${userDeviceInfo['user_id']} >  ${userDeviceInfo['device_name']} >  ${userDeviceInfo['device_id']}',
                                  content: const Text(
                                      'Do you wanna block this device?'),
                                  onConfirm: () {
                                    _devicesController
                                        .tryToModeratorBlockUserDevice(
                                      userId: userDeviceInfo['user_id'],
                                      deviceId: userDeviceInfo['device_id'],
                                    );
                                    Navigator.of(context).pop();
                                  },
                                  confirmTextColor: Colors.white,
                                  onCancel: () => Navigator.of(context).pop(),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 2),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8.0,
                                  horizontal: 16.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColorLight,
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              'User ID: ${userDeviceInfo['user_id']}'),
                                          Text(
                                              'Device Name: ${userDeviceInfo['device_name']}'),
                                          Text(
                                              'Device ID: ${userDeviceInfo['device_id']}'),
                                          Text(
                                              'Entry Datetime: ${DateFormat.yMEd().add_jms().format(DateTime.parse(userDeviceInfo['entry_datetime']).toLocal())}'),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.touch_app),
                                  ],
                                ),
                              ),
                            );
                          },
                          itemCount:
                              _devicesController.userDevicesInfoList.length,
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
