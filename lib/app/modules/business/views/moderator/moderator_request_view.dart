import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:doyel_live/app/modules/business/controllers/business_controller.dart';
import 'package:doyel_live/app/widgets/reusable_widgets.dart';

class ModeratorRequestView extends StatefulWidget {
  const ModeratorRequestView({Key? key}) : super(key: key);

  @override
  _ModeratorRequestViewState createState() => _ModeratorRequestViewState();
}

class _ModeratorRequestViewState extends State<ModeratorRequestView> {
  final BusinessController _businessController = Get.find();

  @override
  void initState() {
    super.initState();
    _businessController.loadModeratorRequest();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Moderator Request')),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * .20),
              Obx(() {
                return _businessController.loadingModeratorRequest.value
                    ? const SpinKitCircle(color: Colors.red)
                    : _businessController.moderatorRequestedData.value['id'] !=
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
                                  "Your Moderator request is pending. Please wait for authority confirmation.\n\nDatetime: ${DateFormat.yMEd().add_jms().format(DateTime.parse(_businessController.moderatorRequestedData.value['datetime']).toLocal())}",
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
                                  title: 'Moderator Request',
                                  content: const Text(
                                    'Do you wanna remove Moderator request?',
                                  ),
                                  onConfirm: () {
                                    _businessController
                                        .tryToRemoveModeratorRequest();
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
                          const Icon(Icons.add_moderator, size: 86),
                          rPrimaryElevatedIconButton(
                            onPressed: () {
                              Get.defaultDialog(
                                title: 'Moderator Request',
                                content: const Text(
                                  'Do you wanna send Moderator request?',
                                ),
                                onConfirm: () {
                                  _businessController
                                      .tryToSendModeratorRequest();
                                  Navigator.of(context).pop();
                                },
                                confirmTextColor: Colors.white,
                                onCancel: () => Navigator.of(context).pop(),
                              );
                            },
                            primaryColor: Theme.of(context).primaryColorLight,
                            buttonText: 'Sent Moderator Request',
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
