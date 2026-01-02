import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'package:foodiy/shared/services/ads_service.dart';

class BannerAdContainer extends StatefulWidget {
  const BannerAdContainer({super.key, required this.showAds});

  final bool showAds;

  @override
  State<BannerAdContainer> createState() => _BannerAdContainerState();
}

class _BannerAdContainerState extends State<BannerAdContainer> {
  BannerAd? _bannerAd;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _maybeLoadAd();
  }

  @override
  void didUpdateWidget(covariant BannerAdContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showAds != widget.showAds) {
      if (widget.showAds) {
        _maybeLoadAd();
      } else {
        _disposeAd();
      }
    }
  }

  void _maybeLoadAd() {
    if (!widget.showAds) return;
    _disposeAd();
    final banner = BannerAd(
      size: AdSize.banner,
      adUnitId: AdsService.bannerAdUnitIdTest,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _loaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          setState(() {
            _loaded = false;
            _bannerAd = null;
          });
        },
      ),
      request: const AdRequest(),
    );
    banner.load();
    _bannerAd = banner;
  }

  @override
  void dispose() {
    _disposeAd();
    super.dispose();
  }

  void _disposeAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _loaded = false;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showAds) return const SizedBox.shrink();
    final height = AdSize.banner.height.toDouble();
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      height: height,
      child: _loaded && _bannerAd != null
          ? AdWidget(ad: _bannerAd!)
          : SizedBox(height: height),
    );
  }
}
