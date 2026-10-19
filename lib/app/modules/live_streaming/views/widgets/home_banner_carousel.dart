import 'package:doyel_live/app/widgets/app_design_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:doyel_live/app/modules/live_streaming/models/home_banner.dart';
import 'package:doyel_live/app/theme/app_colors.dart';
import 'package:flutter/material.dart';

class HomeBannerCarousel extends StatefulWidget {
  const HomeBannerCarousel({super.key, required this.banners});

  final List<HomeBanner> banners;

  @override
  State<HomeBannerCarousel> createState() => _HomeBannerCarouselState();
}

class _HomeBannerCarouselState extends State<HomeBannerCarousel> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        AppCard(
          padding: const EdgeInsets.all(6),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CarouselSlider.builder(
              options: CarouselOptions(
                autoPlay:
                    widget.banners.length > 1 &&
                    !MediaQuery.disableAnimationsOf(context),
                autoPlayInterval: const Duration(seconds: 4),
                autoPlayAnimationDuration: const Duration(milliseconds: 700),
                autoPlayCurve: Curves.easeInOutCubic,
                height: 168,
                viewportFraction: 1.0,
                padEnds: false,
                enlargeCenterPage: false,
                onPageChanged: (index, _) {
                  if (!mounted) return;
                  setState(() {
                    _currentIndex = index;
                  });
                },
              ),
              itemCount: widget.banners.length,
              itemBuilder: (context, index, _) {
                final banner = widget.banners[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: banner.image,
                      fit: BoxFit.cover,
                      fadeInDuration: Duration.zero,
                      fadeOutDuration: Duration.zero,
                      placeholder: (context, url) => Container(
                        color: AppColors.black12,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_outlined),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.black12,
                        alignment: Alignment.center,
                        child: const Icon(Icons.broken_image_outlined),
                      ),
                    ),
                ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
