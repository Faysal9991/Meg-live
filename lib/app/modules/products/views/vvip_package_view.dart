import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:doyel_live/app/modules/products/controllers/vvip_or_vip_package_controller.dart';
import 'package:doyel_live/app/widgets/reusable_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_overlay/loading_overlay.dart';

class VVIPPackageView extends StatefulWidget {
  const VVIPPackageView({super.key});

  @override
  State<VVIPPackageView> createState() => _VVIPPackageViewState();
}

class _VVIPPackageViewState extends State<VVIPPackageView> {
  final VVIPorVipPackageController _vvipOrVipPackageController = Get.put(
    VVIPorVipPackageController(),
  );

  @override
  void initState() {
    super.initState();
    _vvipOrVipPackageController.loadAllVVIPPackageList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(
        () => LoadingOverlay(
          isLoading:
              _vvipOrVipPackageController.loadingAllVVIPPackageList.value,
          progressIndicator: SpinKitCubeGrid(
            color: Theme.of(context).primaryColor,
            size: 50.0,
          ),
          child: Scaffold(
            appBar: AppBar(title: const Text('VVIP Package')),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Obx(
                () => SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _vvipOrVipPackageController
                                  .purchasedVVipPackage
                                  .value['id'] !=
                              null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    'Your Purchased:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                gifItem(
                                  data: _vvipOrVipPackageController
                                      .purchasedVVipPackage
                                      .value['vvip_package'],
                                  isPurchased: true,
                                  expirationDateTime:
                                      _vvipOrVipPackageController
                                          .purchasedVVipPackage
                                          .value['expired_datetime'],
                                ),
                                const SizedBox(height: 8),
                              ],
                            )
                          : Container(),
                      _vvipOrVipPackageController.listAllVvipPackage.isNotEmpty
                          ? const Padding(
                              padding: EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                'Purchase VVIP Package:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 20,
                                ),
                              ),
                            )
                          : Container(),
                      ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _vvipOrVipPackageController
                            .listAllVvipPackage
                            .length,
                        itemBuilder: (context, index) {
                          dynamic data = _vvipOrVipPackageController
                              .listAllVvipPackage[index];
                          return gifItem(data: data);
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(height: 8);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget gifItem({
    required dynamic data,
    bool isPurchased = false,
    String? expirationDateTime,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 5,
      child: ListTile(
        leading: CachedNetworkImage(
          imageUrl: data['gif'],
          width: 50,
          height: 50,
          fit: BoxFit.contain,
          placeholder: (context, url) =>
              const Center(child: CircularProgressIndicator()),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${data['price']} BDT',
              textAlign: TextAlign.center,
              style: const TextStyle(
                // color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            !isPurchased
                ? Text(
                    '${data['days']} days validity',
                    // style: const TextStyle(
                    //   color: Colors.white,
                    // ),
                  )
                : Container(),
            !isPurchased
                ? rPrimaryElevatedButton(
                    onPressed: () async {
                      Get.defaultDialog(
                        title: 'Contact to Purchase',
                        content: SizedBox(
                          height: MediaQuery.of(context).size.height * .4,
                          width: MediaQuery.of(context).size.width,
                          child: SingleChildScrollView(
                            child: Html(
                              shrinkWrap: true,
                              data:
                                  _vvipOrVipPackageController
                                      .vVipPackageOrderingInfo
                                      .value['context'] ??
                                  'No contact info',
                            ),
                          ),
                        ),
                        onCancel: () => Get.close,
                        textCancel: 'Close',
                      );
                    },
                    primaryColor: Colors.white54,
                    buttonText: 'Purchase',
                    fontSize: 14.0,
                    buttonTextColor: Colors.black,
                    borderRadius: 60.0,
                    // fixedSize: const Size(154, 38),
                  )
                : Text(
                    'Expired on: ${DateFormat.yMMMEd().add_jm().format(DateTime.parse(expirationDateTime!).toLocal())}',
                    style: const TextStyle(fontSize: 12),
                  ),
          ],
        ),
      ),
    );
  }
}
