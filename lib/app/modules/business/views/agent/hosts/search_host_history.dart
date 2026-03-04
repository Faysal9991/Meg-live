import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:doyel_live/app/modules/profile/controllers/profile_controller.dart';
import 'package:doyel_live/app/modules/profile/views/broadcasting_histories.dart';
import 'package:doyel_live/app/widgets/reusable_widgets.dart';

class SearchHostHistory extends StatefulWidget {
  const SearchHostHistory({Key? key, this.agentUserId}) : super(key: key);
  final int? agentUserId;

  @override
  _SearchHostHistoryState createState() => _SearchHostHistoryState();
}

class _SearchHostHistoryState extends State<SearchHostHistory> {
  late TextEditingController _editingControllerSearchUid;
  late ProfileController _profileController;
  int _searchedUid = -1;

  @override
  void initState() {
    super.initState();
    _editingControllerSearchUid = TextEditingController();
    _profileController = Get.find();
    _profileController.listHostBroadcastingHistory.clear();
  }

  @override
  void dispose() {
    _editingControllerSearchUid.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 16,
          ),
          rPrimaryTextField(
            controller: _editingControllerSearchUid,
            keyboardType: TextInputType.number,
            borderColor: Theme.of(context).primaryColor,
            hintText: 'Search user with UserID here',
            suffixIcon: IconButton(
              onPressed: () {
                if (FocusScope.of(context).hasFocus) {
                  FocusScope.of(context).unfocus();
                  // if (_devicesController.loadingUserDeviceInfo.value) {
                  //   rShowSnackBar(
                  //     context: context,
                  //     title: 'You already searching a user',
                  //     color: Colors.orange,
                  //   );
                  //   return;
                  // }

                  try {
                    int uid = int.parse(_editingControllerSearchUid.text);
                    if (uid > 0) {
                      _editingControllerSearchUid.clear();
                      _profileController.tryToSearchHostBroadcastingHistories(
                        uid: uid,
                        agentUserId: widget.agentUserId,
                      );
                      setState(() {
                        _searchedUid = uid;
                      });

                      // _devicesController.tryToSearchUserDevicesInfoForUserId(
                      //     userId: uid);
                    } else {
                      _searchedUid = -1;
                    }
                  } catch (e) {
                    rShowSnackBar(
                      context: context,
                      title: 'You must enter number for UserID',
                      color: Colors.orange,
                      durationInSeconds: 2,
                    );
                  }
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
          _searchedUid > 0
              ? Text("Searching for host User ID:  $_searchedUid")
              : Container(),
          const SizedBox(
            height: 8,
          ),
          Obx(() {
            if (_profileController.loadingHostBroadcastingHistories.value) {
              return Center(
                child: SpinKitCubeGrid(
                  color: Theme.of(context).primaryColor,
                  size: 50.0,
                ),
              );
            }
            if (_searchedUid > 0 &&
                _profileController.listHostBroadcastingHistory.isEmpty) {
              return const Center(
                child: Text(
                  'No history',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              );
            }
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: ListView.separated(
                  // padding: EdgeInsets.zero,
                  itemCount:
                      _profileController.listHostBroadcastingHistory.length,
                  itemBuilder: (context, index) {
                    dynamic data =
                        _profileController.listHostBroadcastingHistory[index];
                    return HistoryItem(
                      data: data,
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(
                      height: 1,
                    );
                  },
                ),
              ),
            );
          })
          // : Container(),
        ],
      ),
    );
  }
}
