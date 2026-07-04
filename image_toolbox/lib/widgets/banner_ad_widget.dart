import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

class BannerAdWidget extends StatelessWidget {
  const BannerAdWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final ad = AdService();
    if (!ad.isBannerLoaded || ad.bannerAd == null) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: ad.bannerAd!.size.height.toDouble(),
      width: ad.bannerAd!.size.width.toDouble(),
      child: AdWidget(ad: ad.bannerAd!),
    );
  }
}
