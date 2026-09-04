import 'package:cached_network_image/cached_network_image.dart';
import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

const _vipFrameAsset = 'assets/logos/vip.png';
const _vvipFrameAsset = 'assets/logos/vvip.png';
const _vvipMinimumRank = 90000;

String? vipFrameAssetForPreference(dynamic preference) {
  if (preference is! Map) {
    return null;
  }

  final rawRank = preference['rank'];
  final rank = rawRank is num
      ? rawRank.toInt()
      : int.tryParse(rawRank?.toString() ?? '');
  if (rank == null || rank <= 0) {
    return null;
  }
  return rank >= _vvipMinimumRank ? _vvipFrameAsset : _vipFrameAsset;
}

class VipProfileAvatar extends StatelessWidget {
  const VipProfileAvatar({
    super.key,
    required this.profileImage,
    required this.vipPreference,
    this.frameSize = 104,
    this.unframedSize = 72,
  });

  final String? profileImage;
  final dynamic vipPreference;
  final double frameSize;
  final double unframedSize;

  @override
  Widget build(BuildContext context) {
    final frameAsset = vipFrameAssetForPreference(vipPreference);
    if (frameAsset == null) {
      return _buildPhoto(diameter: unframedSize, showBorder: true);
    }

    return SizedBox.square(
      dimension: frameSize,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          Align(
            alignment: const Alignment(0, 0.16),
            child: _buildPhoto(diameter: frameSize * 0.55),
          ),
          IgnorePointer(
            child: Image.asset(
              frameAsset,
              key: ValueKey(frameAsset),
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoto({required double diameter, bool showBorder = false}) {
    final imageUrl = profileImage?.trim();
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(width: 2, color: AppColors.surface)
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl == null || imageUrl.isEmpty
          ? Image.asset('assets/others/person.jpg', fit: BoxFit.cover)
          : CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.error,
                ),
              ),
              errorWidget: (_, __, ___) =>
                  Image.asset('assets/others/person.jpg', fit: BoxFit.cover),
            ),
    );
  }
}
