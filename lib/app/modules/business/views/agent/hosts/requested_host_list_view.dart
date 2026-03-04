import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:doyel_live/app/modules/business/controllers/business_controller.dart';
import 'package:doyel_live/app/widgets/reusable_widgets.dart';

class RequestedHostListView extends StatefulWidget {
  const RequestedHostListView({Key? key, this.agentUserId}) : super(key: key);
  final int? agentUserId;

  @override
  _RequestedHostListViewState createState() => _RequestedHostListViewState();
}

class _RequestedHostListViewState extends State<RequestedHostListView> {
  final BusinessController _businessController = Get.find();
  late TextEditingController _editingControllerSearchUid;

  @override
  void initState() {
    super.initState();
    _editingControllerSearchUid = TextEditingController();
    _businessController.loadHostRequestList(agentUserId: widget.agentUserId);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(() {
            return _businessController.loadingHostRequestList.value ||
                    _businessController.loadingHostRequestConfirmation.value
                ? const SpinKitCircle(
                    color: Colors.red,
                  )
                : _businessController.hostRequestList.isEmpty
                    ? const Card(
                        elevation: 5,
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "No request available now",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    : Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            rPrimaryTextField(
                              controller: _editingControllerSearchUid,
                              keyboardType: TextInputType.number,
                              borderColor: Theme.of(context).primaryColor,
                              hintText: 'Search user with UserID here',
                              suffixIcon: IconButton(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  if (_businessController
                                      .loadingHostRequestSearch.value) {
                                    rShowSnackBar(
                                      context: context,
                                      title: 'You already searching a user',
                                      color: Colors.orange,
                                    );
                                    return;
                                  }
                                  if (_businessController
                                      .loadingHostRequestConfirmation.value) {
                                    rShowSnackBar(
                                      context: context,
                                      title:
                                          'Host request confirmation is processing...',
                                      color: Colors.orange,
                                    );
                                    return;
                                  }
                                  try {
                                    int uid = int.parse(
                                        _editingControllerSearchUid.text);
                                    if (uid > 0) {
                                      _editingControllerSearchUid.clear();
                                      _businessController
                                          .tryToSearchHostRequest(
                                        userId: uid,
                                        agentUserId: widget.agentUserId,
                                      );
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
                            Obx(() {
                              if (_businessController
                                  .loadingHostRequestSearch.value) {
                                return const SpinKitCircle(
                                  color: Colors.red,
                                );
                              }
                              if (_businessController
                                      .searchedHostRequestedData.value['id'] ==
                                  null) {
                                return Container();
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('You searched:'),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 2),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                      horizontal: 16.0,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        Get.defaultDialog(
                                          title:
                                              'User ID: ${_businessController.searchedHostRequestedData['profile']['user']['uid']}',
                                          content: const Text(
                                              'Do you wanna accept host request?'),
                                          onConfirm: () {
                                            _businessController
                                                .tryToConfirmHostRequest(
                                              userId: _businessController
                                                      .searchedHostRequestedData[
                                                  'profile']['user']['uid'],
                                              agentUserId: widget.agentUserId,
                                            );
                                            Get.close;
                                          },
                                          confirmTextColor: Colors.white,
                                          onCancel: () => Get.close,
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    'Type: ${_businessController.searchedHostRequestedData['is_allow_video_live'] ? 'Video Live' : 'Audio Live'}'),
                                                Text(
                                                    'User ID: ${_businessController.searchedHostRequestedData['profile']['user']['uid']}'),
                                                Text(
                                                    'Name: ${_businessController.searchedHostRequestedData['profile']['full_name']}'),
                                                Text(
                                                    'Diamonds: ${_businessController.searchedHostRequestedData['profile']['diamonds']}'),
                                                Text(
                                                    'Requested at: ${DateFormat.yMEd().add_jms().format(DateTime.parse(_businessController.searchedHostRequestedData['datetime']).toLocal())}'),
                                              ],
                                            ),
                                          ),
                                          const Icon(Icons.touch_app),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                  const Divider(
                                    color: Colors.white,
                                  ),
                                  const SizedBox(
                                    height: 4,
                                  ),
                                ],
                              );
                            }),
                            Expanded(
                              child: ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  dynamic hostRequestData = _businessController
                                      .hostRequestList[index];
                                  return Container(
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 2),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                      horizontal: 16.0,
                                    ),
                                    decoration: BoxDecoration(
                                      // color: Theme.of(context).primaryColor,
                                      gradient: const LinearGradient(
                                        colors: [
                                          Colors.grey,
                                          Colors.white,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        Get.defaultDialog(
                                          title:
                                              'User ID: ${hostRequestData['profile']['user']['uid']}',
                                          content: const Text(
                                              'Do you wanna accept host request?'),
                                          onConfirm: () {
                                            _businessController
                                                .tryToConfirmHostRequest(
                                              userId: hostRequestData['profile']
                                                  ['user']['uid'],
                                              agentUserId: widget.agentUserId,
                                            );
                                            Get.close;
                                          },
                                          confirmTextColor: Colors.white,
                                          onCancel: () => Get.close,
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    'Type: ${hostRequestData['is_allow_video_live'] ? 'Video Live' : 'Audio Live'}'),
                                                Text(
                                                    'User ID: ${hostRequestData['profile']['user']['uid']}'),
                                                Text(
                                                    'Name: ${hostRequestData['profile']['full_name']}'),
                                                Text(
                                                    'Diamonds: ${hostRequestData['profile']['diamonds']}'),
                                                Text(
                                                    'Requested at: ${DateFormat.yMEd().add_jms().format(DateTime.parse(hostRequestData['datetime']).toLocal())}'),
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
                                    _businessController.hostRequestList.length,
                              ),
                            ),
                          ],
                        ),
                      );
          }),
        ],
      ),
    );
  }
}
