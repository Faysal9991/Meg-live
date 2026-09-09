import 'package:doyel_live/app/widgets/app_design_widgets.dart';
import 'package:doyel_live/app/modules/products/controllers/vvip_or_vip_package_controller.dart';
import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:doyel_live/app/widgets/animated_media_widget.dart';
import 'package:doyel_live/app/widgets/reusable_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:loading_overlay/loading_overlay.dart';

class EntryEffectPackageView extends StatefulWidget {
  const EntryEffectPackageView({super.key});

  @override
  State<EntryEffectPackageView> createState() => _EntryEffectPackageViewState();
}

class _EntryEffectPackageViewState extends State<EntryEffectPackageView> {
  late final VVIPorVipPackageController _packageController;

  @override
  void initState() {
    super.initState();
    _packageController = Get.isRegistered<VVIPorVipPackageController>()
        ? Get.find<VVIPorVipPackageController>()
        : Get.put(VVIPorVipPackageController());
    if (_packageController.entryEffectPackageList.isEmpty &&
        _packageController.purchasedEntryEffectPackage.isEmpty) {
      _packageController.loadEntryEffectPackageList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Obx(
        () => LoadingOverlay(
          isLoading:
              _packageController.loadingEntryEffectPackageList.value ||
              _packageController.purchasingEntryEffectPackage.value,
          progressIndicator: SpinKitCubeGrid(
            color: Theme.of(context).primaryColor,
            size: 50,
          ),
          child: Scaffold(
            appBar: AppBar(title: const Text('Entry Effect Packages')),
            body: Obx(
              () => ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  if (_packageController.purchasedEntryEffectPackage.isNotEmpty)
                    ..._purchasedSection(),
                  if (_packageController.entryEffectPackageList.isNotEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8),
                      child: Text(
                        'Purchase Entry Effect:',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ..._packageController.entryEffectPackageList.map(
                    (package) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _packageItem(package: package),
                    ),
                  ),
                  if (!_packageController.loadingEntryEffectPackageList.value &&
                      _packageController.entryEffectPackageList.isEmpty &&
                      _packageController.purchasedEntryEffectPackage.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 48),
                      child: Center(
                        child: Text('No entry effect packages available.'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _purchasedSection() {
    final purchased = _packageController.purchasedEntryEffectPackage;
    final packageData = purchased['entry_effect_package'];
    if (packageData is! Map) return const <Widget>[];

    return [
      const Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Text(
          'Your Purchased:',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      _packageItem(
        package: Map<String, dynamic>.from(packageData),
        isPurchased: true,
        expirationDateTime: purchased['expired_datetime']?.toString(),
      ),
      const SizedBox(height: 16),
    ];
  }

  Widget _packageItem({
    required Map<String, dynamic> package,
    bool isPurchased = false,
    String? expirationDateTime,
  }) {
    final packageId = int.tryParse(package['id']?.toString() ?? '');
    final price = _packageController.entryEffectDiamondCost(package);
    return AppCard(
      margin: EdgeInsets.zero,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _mediaPreview(package),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    package['title']?.toString() ?? 'Entry Effect',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$price Diamonds',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text('${package['days'] ?? 0} days validity'),
                  if (package['audio'] != null)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.volume_up_outlined, size: 16),
                          SizedBox(width: 4),
                          Text('Includes sound'),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (isPurchased)
                    Text(
                      _expirationLabel(expirationDateTime),
                      style: const TextStyle(fontSize: 12),
                    )
                  else
                    rPrimaryElevatedButton(
                      onPressed: () => _purchase(packageId, price),
                      primaryColor: AppColors.primary,
                      buttonText:
                          _packageController
                                  .purchasingEntryEffectPackageId
                                  .value ==
                              packageId
                          ? 'Purchasing...'
                          : 'Purchase',
                      fontSize: 14,
                      buttonTextColor: AppColors.textOnPrimary,
                      borderRadius: 60,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mediaPreview(Map<String, dynamic> package) {
    final source = AnimatedMediaSource.fromMap(
      package,
      includeGiftImage: false,
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox.square(
        dimension: 76,
        child: AnimatedMediaWidget(
          source: source,
          fit: BoxFit.cover,
          errorWidget: _mediaPlaceholder('Effect'),
        ),
      ),
    );
  }

  Widget _mediaPlaceholder(String type) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: AppColors.onMediaMuted,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome_motion, size: 30),
          const SizedBox(height: 3),
          Text(type, style: const TextStyle(fontSize: 11)),
        ],
      ),
    );
  }

  Future<void> _purchase(int? packageId, int price) async {
    if (packageId == null) {
      _showMessage('Invalid entry effect package.', AppColors.error);
      return;
    }
    if (_packageController.currentDiamondBalance < price) {
      _showMessage(
        'You need $price diamonds, but you have ${_packageController.currentDiamondBalance}.',
        AppColors.error,
      );
      return;
    }

    final statusCode = await _packageController.purchaseEntryEffectPackage(
      packageId: packageId,
    );
    if (!mounted || statusCode == -1) return;
    if (statusCode == 200 || statusCode == 201) {
      _showMessage(
        'Entry effect package purchased successfully.',
        AppColors.success,
      );
    } else if (statusCode == 203) {
      _showMessage(
        'You do not have enough diamonds to purchase this package.',
        AppColors.error,
      );
    } else if (statusCode == 204) {
      Get.defaultDialog(
        title: 'Locked',
        middleText: 'Your diamonds has been locked.',
        titleStyle: const TextStyle(color: AppColors.error),
      );
    } else {
      _showMessage('Something went wrong. Please try again.', AppColors.error);
    }
  }

  void _showMessage(String message, Color color) {
    rShowSnackBar(
      context: context,
      title: message,
      color: color,
      durationInSeconds: 4,
    );
  }

  String _expirationLabel(String? value) {
    final expiration = value == null ? null : DateTime.tryParse(value);
    if (expiration == null) return 'Purchased';
    return 'Expired on: ${DateFormat.yMMMEd().add_jm().format(expiration.toLocal())}';
  }
}
