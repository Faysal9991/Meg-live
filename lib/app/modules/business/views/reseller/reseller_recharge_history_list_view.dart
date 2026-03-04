import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:doyel_live/app/modules/business/controllers/business_controller.dart';

class ResellerRechargeHistoryListView extends StatefulWidget {
  const ResellerRechargeHistoryListView({Key? key}) : super(key: key);

  @override
  _ResellerRechargeHistoryListViewState createState() =>
      _ResellerRechargeHistoryListViewState();
}

class _ResellerRechargeHistoryListViewState
    extends State<ResellerRechargeHistoryListView> {
  final BusinessController _businessController = Get.find();

  @override
  void initState() {
    super.initState();
    _businessController.loadResellerRechargeHistoryList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(() {
            return _businessController.loadingResellerRechargeHistoryList.value
                ? const SpinKitCircle(
                    color: Colors.red,
                  )
                : _businessController.resellerRechargeHistoryList.isEmpty
                    ? const Card(
                        elevation: 5,
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "No history",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.orange,
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
                            dynamic history = _businessController
                                .resellerRechargeHistoryList[index];
                            return Container(
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
                                            'User ID: ${history['profile']['user']['uid']}'),
                                        Text(
                                            'Name: ${history['profile']['full_name']}'),
                                        Text(
                                            'Recharged Diamonds: ${history['recharged_diamonds']}'),
                                        Text(
                                            'Datetime: ${DateFormat.yMEd().add_jms().format(DateTime.parse(history['datetime']).toLocal())}'),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      Get.defaultDialog(
                                        title:
                                            'Datetime: ${DateFormat.yMEd().add_jms().format(DateTime.parse(history['datetime']).toLocal())}',
                                        content: const Text(
                                            'Do you wanna delete history?'),
                                        onConfirm: () {
                                          _businessController
                                              .tryToDeleteResellerRechargeHistory(
                                            historyId: history['id'],
                                          );
                                          Navigator.of(context).pop();
                                        },
                                        confirmTextColor: Colors.white,
                                        onCancel: () =>
                                            Navigator.of(context).pop(),
                                      );
                                    },
                                    icon: const Icon(Icons.close),
                                  ),
                                ],
                              ),
                            );
                          },
                          itemCount: _businessController
                              .resellerRechargeHistoryList.length,
                        ),
                      );
          }),
        ],
      ),
    );
  }
}
