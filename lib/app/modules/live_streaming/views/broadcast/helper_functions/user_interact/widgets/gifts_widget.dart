import 'package:doyel_live/app/theme/app_radius.dart';
import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doyel_live/app/modules/auth/controllers/auth_controller.dart';
import 'package:doyel_live/app/modules/live_streaming/controllers/live_streaming_controller.dart';
import 'package:doyel_live/app/widgets/animated_media_widget.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GiftsWidget extends StatefulWidget {
  const GiftsWidget({
    super.key,
    required this.streamingController,
    required this.authController,
    required this.data,
    required this.onUpdateAction,
  });
  final LiveStreamingController streamingController;
  final AuthController authController;
  final dynamic data;
  final Function onUpdateAction;

  @override
  State<GiftsWidget> createState() => _GiftsWidgetState();
}

class _GiftsWidgetState extends State<GiftsWidget> {
  /// Receivers explicitly picked in the sheet. When empty, the gift goes to
  /// the user whose sheet was opened (see [_effectiveReceiverUids]).
  final RxSet<int> _selectedUids = <int>{}.obs;

  LiveStreamingController get streamingController => widget.streamingController;
  AuthController get authController => widget.authController;
  dynamic get data => widget.data;

  int get _myUid => authController.profile.value.user!.uid!;

  static int? _uidOf(dynamic user) =>
      user == null ? null : int.tryParse('${user['uid']}');

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (streamingController.listAnimatedGift.isEmpty ||
          streamingController.listNormalGift.isEmpty) {
        streamingController.fetchGiftList();
      }
    });
  }

  /// Everyone in the room who can receive a gift: on-mic users first (host
  /// leads [LiveStreamingController.listActiveCall]), then listeners.
  List<dynamic> _receiverCandidates() {
    final seen = <int>{_myUid};
    final candidates = <dynamic>[];
    void addAll(Iterable<dynamic> users) {
      for (final user in users) {
        final uid = _uidOf(user);
        if (uid != null && seen.add(uid)) candidates.add(user);
      }
    }

    addAll(streamingController.listActiveCall);
    addAll(streamingController.viewers);
    // The profile the sheet was opened from may not be in either list yet.
    if (data is Map && !seen.contains(_uidOf(data))) addAll([data]);
    return candidates;
  }

  Set<int> _onMicUids() =>
      streamingController.listActiveCall.map(_uidOf).whereType<int>().toSet();

  Set<int> _effectiveReceiverUids(List<dynamic> candidates) {
    final available = candidates.map(_uidOf).whereType<int>().toSet();
    final picked = _selectedUids.intersection(available);
    if (picked.isNotEmpty) return picked;
    final fallback = _uidOf(data);
    return fallback != null && available.contains(fallback) ? {fallback} : {};
  }

  void _toggleReceiver(int uid, Set<int> effective) {
    final next = {...effective};
    if (!next.remove(uid)) next.add(uid);
    _selectedUids
      ..clear()
      ..addAll(next);
  }

  void _toggleAll(List<dynamic> candidates, bool allSelected) {
    _selectedUids.clear();
    if (!allSelected) {
      _selectedUids.addAll(candidates.map(_uidOf).whereType<int>());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (streamingController.loadingGfitList.value) {
        return const SizedBox(
          height: 300,
          child: Center(
            child: SpinKitChasingDots(
              color: AppColors.textSecondary,
              size: 50.0,
            ),
          ),
        );
      }
      final candidates = _receiverCandidates();
      final receivers = _effectiveReceiverUids(candidates);
      return SizedBox(
        height: 300,
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              if (candidates.isNotEmpty)
                _receiverSelector(candidates, receivers),
              _tabBar(),
              Expanded(
                child: TabBarView(
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _giftGrid(
                      gifts: streamingController.listAnimatedGift,
                      emptyText: 'No animated gifts available',
                    ),
                    _giftGrid(
                      gifts: streamingController.listNormalGift,
                      emptyText: 'No gifts available',
                    ),
                  ],
                ),
              ),
              _sendBar(context, candidates, receivers),
            ],
          ),
        ),
      );
    });
  }

  Widget _receiverSelector(List<dynamic> candidates, Set<int> receivers) {
    final onMic = _onMicUids();
    final allSelected =
        candidates.length > 1 && receivers.length == candidates.length;
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 0),
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: candidates.length,
              separatorBuilder: (context, index) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final user = candidates[index];
                final uid = _uidOf(user)!;
                return _receiverAvatar(
                  user: user,
                  selected: receivers.contains(uid),
                  onMic: onMic.contains(uid),
                  onTap: () => _toggleReceiver(uid, receivers),
                );
              },
            ),
          ),
          if (candidates.length > 1) ...[
            Container(width: 1, height: 36, color: AppColors.divider),
            _selectAllButton(
              allSelected: allSelected,
              count: candidates.length,
              onTap: () => _toggleAll(candidates, allSelected),
            ),
          ],
        ],
      ),
    );
  }

  Widget _receiverAvatar({
    required dynamic user,
    required bool selected,
    required bool onMic,
    required VoidCallback onTap,
  }) {
    final image = user['profile_image'] ?? user['photo_url'];
    final name = '${user['full_name'] ?? '#${user['uid']}'}';
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        width: 44,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: 36,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        width: 2,
                        color: selected
                            ? AppColors.primary
                            : AppColors.transparent,
                      ),
                    ),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 150),
                      opacity: selected ? 1 : 0.55,
                      child: ClipOval(
                        child: image == null
                            ? Image.asset(
                                'assets/others/person.jpg',
                                width: 28,
                                height: 28,
                                fit: BoxFit.cover,
                              )
                            : CachedNetworkImage(
                                imageUrl: '$image',
                                width: 28,
                                height: 28,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    Container(color: AppColors.surfaceInset),
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                      'assets/others/person.jpg',
                                      fit: BoxFit.cover,
                                    ),
                              ),
                      ),
                    ),
                  ),
                  if (onMic)
                    const Positioned(
                      bottom: -1,
                      left: -1,
                      child: CircleAvatar(
                        radius: 7,
                        backgroundColor: AppColors.cyan,
                        child: Icon(
                          Icons.mic_rounded,
                          size: 9,
                          color: AppColors.onLight,
                        ),
                      ),
                    ),
                  if (selected)
                    const Positioned(
                      top: -1,
                      right: -1,
                      child: CircleAvatar(
                        radius: 7,
                        backgroundColor: AppColors.primary,
                        child: Icon(
                          Icons.check_rounded,
                          size: 10,
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 3),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? AppColors.pinkLight : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _selectAllButton({
    required bool allSelected,
    required int count,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 12, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 32,
              height: 32,
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: allSelected ? AppColors.primary : AppColors.surfaceInset,
                border: Border.all(
                  color: allSelected ? AppColors.primary : AppColors.border,
                ),
              ),
              child: Icon(
                allSelected ? Icons.done_all_rounded : Icons.groups_rounded,
                size: 18,
                color: allSelected
                    ? AppColors.textOnPrimary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              'All ($count)',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: allSelected
                    ? AppColors.pinkLight
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabBar() {
    return Container(
      height: 36,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceInset,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: TabBar(
        dividerColor: AppColors.transparent,
        indicatorSize: TabBarIndicatorSize.tab,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        labelColor: AppColors.textOnPrimary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        splashBorderRadius: BorderRadius.circular(AppRadius.pill),
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, size: 14),
                SizedBox(width: 6),
                Text('Animated'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.card_giftcard, size: 14),
                SizedBox(width: 6),
                Text('Normal'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _giftGrid({required List<dynamic> gifts, required String emptyText}) {
    if (gifts.isEmpty) {
      return Center(
        child: Text(
          emptyText,
          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: gifts.length,
      itemBuilder: (context, index) => giftItem(
        streamingController: streamingController,
        authController: authController,
        giftData: gifts[index],
      ),
    );
  }

  Widget _sendBar(
    BuildContext context,
    List<dynamic> candidates,
    Set<int> receivers,
  ) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          _balancePill(),
          const Spacer(),
          Obx(() {
            final selectedGiftId = streamingController.selectedGift['id'];
            final isSending = streamingController.loadingGiftSend.value != -1;
            final baseDiamonds =
                int.tryParse(
                  streamingController.selectedGift['diamonds'].toString(),
                ) ??
                0;
            final totalGiftDiamonds = baseDiamonds * receivers.length;
            final canSend =
                selectedGiftId != 0 && receivers.isNotEmpty && !isSending;
            return _sendButton(
              context: context,
              canSend: canSend,
              isSending: isSending,
              totalDiamonds: selectedGiftId != 0 && receivers.isNotEmpty
                  ? totalGiftDiamonds
                  : null,
              onSend: () => _sendGift(context, candidates, receivers),
            );
          }),
        ],
      ),
    );
  }

  /// Wallet balance with an inline "+" so recharge reads as part of the
  /// balance instead of a competing primary action.
  Widget _balancePill() {
    return Material(
      color: AppColors.surfaceInset,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        onTap: () => Get.snackbar(
          'Oops',
          "Coming Soon!",
          backgroundColor: AppColors.warning,
          colorText: AppColors.onLight,
          snackPosition: SnackPosition.TOP,
        ),
        child: Container(
          height: 32,
          padding: const EdgeInsets.only(left: 10, right: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/others/diamond.png', width: 14, height: 14),
              const SizedBox(width: 5),
              Obx(() {
                return Text(
                  '${authController.profile.value.diamonds ?? 0}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gold,
                  ),
                );
              }),
              const SizedBox(width: 8),
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  size: 16,
                  color: AppColors.onLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sendButton({
    required BuildContext context,
    required bool canSend,
    required bool isSending,
    required VoidCallback onSend,
    int? totalDiamonds,
  }) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: canSend || isSending ? 1 : 0.5,
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          onTap: canSend ? onSend : null,
          child: Ink(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              gradient: canSend || isSending
                  ? AppGradients.brand
                  : const LinearGradient(
                      colors: [AppColors.disabled, AppColors.disabled],
                    ),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: isSending
                  ? const [
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                    ]
                  : [
                      const Text(
                        'Send',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textOnPrimary,
                        ),
                      ),
                      if (totalDiamonds != null) ...[
                        Container(
                          width: 1,
                          height: 14,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: AppColors.onMediaSubtle,
                        ),
                        Image.asset(
                          'assets/others/diamond.png',
                          width: 12,
                          height: 12,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '$totalDiamonds',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textOnPrimary,
                          ),
                        ),
                      ],
                    ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendGift(
    BuildContext context,
    List<dynamic> candidates,
    Set<int> receivers,
  ) async {
    final selectedGift = streamingController.selectedGift;
    if (selectedGift['id'] == 0 || receivers.isEmpty) return;

    final listReceiver = candidates
        .where((user) => receivers.contains(_uidOf(user)))
        .toList();
    final listReceiverIds = listReceiver.map(_uidOf).toList();
    final names = listReceiver.map((user) => '${user['full_name']}').toList();
    // Keep the activity text short when gifting a large audience.
    final receiverFullNames = names.length > 3
        ? '${names.take(3).join(', ')} +${names.length - 3} more'
        : names.join(', ');

    final diamonds = int.parse(selectedGift['diamonds'].toString());
    final giftDiamonds = diamonds * listReceiver.length;
    if (authController.profile.value.diamonds! < giftDiamonds) {
      Get.snackbar(
        'Failed',
        "You've no sufficient diamonds. Please +Recharge.",
        backgroundColor: AppColors.error,
        colorText: AppColors.onLight,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    if (streamingController.loadingGiftSend.value != -1) return;

    await streamingController.tryToSendGiftOnLiveStreaming(
      channelName: streamingController.channelName.value,
      giftType: selectedGift['gift_type'].toString(),
      giftId: int.parse(selectedGift['id'].toString()),
      context: context,
      totalDiamonds: giftDiamonds,
      diamonds: diamonds,
      vat: int.parse(selectedGift['vat'].toString()),
      receiverFullNames: receiverFullNames,
      receiverUids: listReceiverIds,
      giftImage: selectedGift['gift_image'] as String?,
      svga: selectedGift['svga'] as String?,
      gif: selectedGift['gif'] as String?,
      audio: selectedGift['audio'] as String?,
    );
  }
}

class giftItem extends StatelessWidget {
  const giftItem({
    Key? key,
    required this.streamingController,
    required this.authController,
    required this.giftData,
  }) : super(key: key);

  final LiveStreamingController streamingController;
  final AuthController authController;
  final dynamic giftData;

  @override
  Widget build(BuildContext context) {
    final isAnimated = giftData['svga'] != null || giftData['gif'] != null;
    return GestureDetector(
      onTap: () {
        if (authController.profile.value.diamonds! < giftData['diamonds']) {
          Get.snackbar(
            'Failed',
            "You've no sufficient diamonds. Please +Recharge.",
            backgroundColor: AppColors.error,
            colorText: AppColors.onLight,
            snackPosition: SnackPosition.TOP,
          );
          return;
        }
        streamingController.setSelectedGift(
          giftType: isAnimated ? 'animation' : 'normal',
          id: giftData['id'],
          diamonds: giftData['diamonds'],
          vat: giftData['vat'],
          giftImage: giftData['gift_image'],
          svga: giftData['svga'],
          gif: giftData['gif'],
          audio: giftData['audio'],
        );
      },
      child: Obx(() {
        final selectedGift = streamingController.selectedGift;
        final isSelected =
            selectedGift['id'] == giftData['id'] &&
            selectedGift['gift_type'] == (isAnimated ? 'animation' : 'normal');
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primarySoft
                : AppColors.surfaceHighlight,
            borderRadius: BorderRadius.circular(AppRadius.small),
            border: Border.all(
              width: isSelected ? 2 : 1,
              color: isSelected ? AppColors.primary : AppColors.divider,
            ),
          ),
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 8, 6, 2),
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 150),
                        scale: isSelected ? 1.1 : 1.0,
                        child: AnimatedBuilder(
                          animation:
                              ModalRoute.of(context)?.animation ??
                              const AlwaysStoppedAnimation<double>(1),
                          builder: (context, _) {
                            final route = ModalRoute.of(context);
                            return AnimatedMediaWidget(
                              source: AnimatedMediaSource.fromMap(
                                giftData is Map ? giftData as Map : const {},
                              ),
                              enableSvgaAudio:
                                  isSelected &&
                                  (ModalRoute.isCurrentOf(context) ?? true) &&
                                  route?.animation?.status !=
                                      AnimationStatus.reverse,
                              fit: BoxFit.contain,
                              placeholder: const Center(
                                child: SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/others/diamond.png',
                          width: 12,
                          height: 12,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${giftData['diamonds']}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (isAnimated)
                const Positioned(
                  top: 4,
                  right: 4,
                  child: Icon(
                    Icons.play_circle_fill,
                    size: 12,
                    color: AppColors.premium,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
