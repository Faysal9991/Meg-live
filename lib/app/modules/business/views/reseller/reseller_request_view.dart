import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:doyel_live/app/modules/business/controllers/business_controller.dart';
import 'package:doyel_live/app/widgets/reusable_widgets.dart';

class ResellerRequestView extends StatefulWidget {
  const ResellerRequestView({Key? key}) : super(key: key);

  @override
  _ResellerRequestViewState createState() => _ResellerRequestViewState();
}

class _ResellerRequestViewState extends State<ResellerRequestView> {
  final BusinessController _businessController = Get.find();

  @override
  void initState() {
    super.initState();
    _businessController.loadResellerRequest();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Reseller Request')),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * .20),
              Obx(() {
                return _businessController.loadingResellerRequest.value
                    ? const SpinKitCircle(color: Colors.red)
                    : _businessController.resellerRequestedData.value['id'] !=
                          null
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Card(
                              elevation: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  "Your Reseller request is pending. Please wait for authority confirmation.\n\nDatetime: ${DateFormat.yMEd().add_jms().format(DateTime.parse(_businessController.resellerRequestedData.value['datetime']).toLocal())}",
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.orange,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            rPrimaryElevatedIconButton(
                              onPressed: () {
                                Get.defaultDialog(
                                  title: 'Reseller Request',
                                  content: const Text(
                                    'Do you wanna remove Reseller request?',
                                  ),
                                  onConfirm: () {
                                    _businessController
                                        .tryToRemoveResellerRequest();
                                    Navigator.of(context).pop();
                                  },
                                  confirmTextColor: Colors.white,
                                  onCancel: () => Navigator.of(context).pop(),
                                );
                              },
                              primaryColor: Colors.red,
                              buttonText: 'Remove Request',
                              fontSize: 16,
                              iconData: Icons.close,
                            ),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Icon(Icons.business_center, size: 86),
                          rPrimaryElevatedIconButton(
                            onPressed: () {
                              Get.defaultDialog(
                                title: 'Reseller Request',
                                content: const Text(
                                  'Do you wanna send Reseller request?',
                                ),
                                onConfirm: () {
                                  _businessController
                                      .tryToSendResellerRequest();
                                  Navigator.of(context).pop();
                                },
                                confirmTextColor: Colors.white,
                                onCancel: () => Navigator.of(context).pop(),
                              );
                            },
                            primaryColor: Theme.of(context).primaryColorLight,
                            buttonText: 'Sent Reseller Request',
                            fontSize: 16,
                            iconData: Icons.touch_app,
                          ),
                        ],
                      );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
