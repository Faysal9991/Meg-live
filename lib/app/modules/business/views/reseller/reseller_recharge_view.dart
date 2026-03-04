import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/business/controllers/business_controller.dart';
import 'package:doyel_live/app/modules/profile/controllers/profile_controller.dart';
import 'package:doyel_live/app/widgets/reusable_widgets.dart';

class ResellerRechargeView extends StatefulWidget {
  const ResellerRechargeView({Key? key}) : super(key: key);

  @override
  State<ResellerRechargeView> createState() => _ResellerRechargeViewState();
}

class _ResellerRechargeViewState extends State<ResellerRechargeView> {
  late TextEditingController _editingControllerSearchUid,
      _editingControllerDiamonds;
  late ProfileController _profileController;
  final AuthController _authController = Get.find();
  final BusinessController _businessController = Get.find();

  @override
  void initState() {
    super.initState();
    _editingControllerSearchUid = TextEditingController();
    _editingControllerDiamonds = TextEditingController();
    _profileController = Get.put(ProfileController());
    _profileController.clearSearchField();
  }

  @override
  void dispose() {
    _editingControllerSearchUid.dispose();
    _editingControllerDiamonds.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Obx(
            () => Column(
              children: [
                const Text(
                  'You Have',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/others/diamond.png',
                      width: 32,
                      height: 32,
                    ),
                    Text(
                      '${_authController.profile.value.diamonds}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
                if (_profileController.loadingProfileSearch.value) {
                  rShowSnackBar(
                    context: context,
                    title: 'You already searching a user',
                    color: Colors.orange,
                  );
                  return;
                }
                if (_businessController.loadingResellerRecharge.value) {
                  rShowSnackBar(
                    context: context,
                    title: 'Recharge is processing...',
                    color: Colors.orange,
                  );
                  return;
                }
                try {
                  int uid = int.parse(_editingControllerSearchUid.text);
                  if (uid > 0) {
                    _editingControllerSearchUid.clear();
                    _profileController.tryToSearchProfile(userId: uid);
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
            () => _profileController.loadingProfileSearch.value ||
                    _businessController.loadingResellerRecharge.value
                ? const Center(
                    child: SpinKitCircle(color: Colors.red),
                  )
                : _profileController.searchedProfile.value['id'] == null
                    ? const Text("User doesn't exists.")
                    : InkWell(
                        onTap: () {
                          Get.defaultDialog(
                            barrierDismissible: false,
                            title:
                                'User ID: ${_profileController.searchedProfile.value['user']['uid']}',
                            content: rPrimaryTextField(
                              controller: _editingControllerDiamonds,
                              keyboardType: TextInputType.number,
                              borderColor: Theme.of(context).primaryColorLight,
                              hintText: 'Diamonds',
                              prefixIcon: const Icon(
                                Icons.diamond,
                                color: Colors.blue,
                                size: 32,
                              ),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  if (_businessController
                                      .loadingResellerRecharge.value) {
                                    rShowSnackBar(
                                      context: context,
                                      title: 'Recharge is processing...',
                                      color: Colors.orange,
                                    );
                                    return;
                                  }
                                  if (_profileController
                                      .loadingProfileSearch.value) {
                                    rShowSnackBar(
                                      context: context,
                                      title: 'You already searching a user',
                                      color: Colors.orange,
                                    );
                                    return;
                                  }
                                  try {
                                    int diamonds = int.parse(
                                        _editingControllerDiamonds.text);
                                    if (diamonds > 0) {
                                      _businessController
                                          .tryToRechargeResellerToClient(
                                        customerId: _profileController
                                            .searchedProfile
                                            .value['user']['uid'],
                                        diamonds: diamonds,
                                      );
                                      _editingControllerDiamonds.clear();
                                      Get.back();
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
                                  Icons.check_box,
                                ),
                              ),
                            ),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'User ID: ${_profileController.searchedProfile.value['user']['uid']}'),
                                    Text(
                                        'Name: ${_profileController.searchedProfile.value['full_name']}'),
                                    Text(
                                        'Diamonds: ${_profileController.searchedProfile.value['diamonds']}'),
                                  ],
                                ),
                              ),
                              const Icon(Icons.touch_app),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
