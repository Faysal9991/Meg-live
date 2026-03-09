import 'package:cached_network_image/cached_network_image.dart';
import 'package:doyel_live/app/modules/products/controllers/vvip_or_vip_package_controller.dart';
import 'package:doyel_live/app/widgets/reusable_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_overlay/loading_overlay.dart';

class KingPackageView extends StatefulWidget {
  const KingPackageView({super.key});

  @override
  State<KingPackageView> createState() => _KingPackageViewState();
}

class _KingPackageViewState extends State<KingPackageView> {
  late final VVIPorVipPackageController _packageController;

  @override
  void initState() {
    super.initState();
    _packageController = Get.isRegistered<VVIPorVipPackageController>()
        ? Get.find<VVIPorVipPackageController>()
        : Get.put(VVIPorVipPackageController());
    if (_packageController.listAllKingPackage.isEmpty &&
        _packageController.purchasedKingPackage.value == null) {
      _packageController.loadAllKingPackageList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(
        () => LoadingOverlay(
          isLoading: _packageController.loadingAllKingPackageList.value,
          progressIndicator: SpinKitCubeGrid(
            color: Theme.of(context).primaryColor,
            size: 50.0,
          ),
          child: Scaffold(
            appBar: AppBar(title: const Text('King Package')),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Obx(
                () => SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      _packageController
                                  .purchasedKingPackage
                                  .value
                                  ?.kingPackage !=
                              null
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                _buildPackageItem(
                                  context: context,
                                  data: _packageController
                                      .purchasedKingPackage
                                      .value!
                                      .kingPackage!
                                      .raw,
                                  isPurchased: true,
                                  expirationDateTime: _packageController
                                      .purchasedKingPackage
                                      .value!
                                      .expiredDatetime,
                                ),
                                const SizedBox(height: 8),
                              ],
                            )
                          : Container(),
                      _packageController.listAllKingPackage.isNotEmpty
                          ? const Padding(
                              padding: EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                'Purchase King Package:',
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
                        itemCount: _packageController.listAllKingPackage.length,
                        itemBuilder: (context, index) {
                          final data =
                              _packageController.listAllKingPackage[index].raw;
                          return _buildPackageItem(
                            context: context,
                            data: data,
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
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

  Widget _buildPackageItem({
    required BuildContext context,
    required Map<String, dynamic> data,
    bool isPurchased = false,
    String? expirationDateTime,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 5,
      child: ListTile(
        leading: CachedNetworkImage(
          imageUrl: (data['gif'] ?? data['image'] ?? '').toString(),
          width: 50,
          height: 50,
          fit: BoxFit.contain,
          fadeInDuration: Duration.zero,
          fadeOutDuration: Duration.zero,
          placeholder: (context, url) =>
              const Center(child: Icon(Icons.image_outlined)),
          errorWidget: (context, url, error) =>
              const Center(child: Icon(Icons.broken_image_outlined)),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${data['price']} BDT',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            !isPurchased ? Text('${data['days']} days validity') : Container(),
            !isPurchased
                ? rPrimaryElevatedButton(
                    onPressed: () {
                      Get.defaultDialog(
                        title: 'Contact to Purchase',
                        content: SizedBox(
                          height: MediaQuery.of(context).size.height * .4,
                          width: MediaQuery.of(context).size.width,
                          child: SingleChildScrollView(
                            child: Html(
                              shrinkWrap: true,
                              data:
                                  _packageController
                                      .kingPackageOrderingInfo['context'] ??
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
                  )
                : Text(
                    expirationDateTime == null
                        ? 'Purchased'
                        : 'Expired on: ${DateFormat.yMMMEd().add_jm().format(DateTime.parse(expirationDateTime).toLocal())}',
                    style: const TextStyle(fontSize: 12),
                  ),
          ],
        ),
      ),
    );
  }
}
