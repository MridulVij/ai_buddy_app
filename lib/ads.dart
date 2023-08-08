import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class Ads {
  InterstitialAd? interstitialAd;
  int interstitialAttempts = 0;

  void createInterstitialAd() {
    InterstitialAd.load(
      // image ad
      adUnitId: 'ca-app-pub-5498431563071990/4756838043',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          interstitialAd = ad;
          interstitialAttempts = 0;
        },
        onAdFailedToLoad: (error) {
          interstitialAttempts++;
          interstitialAd = null;
          if (kDebugMode) {
            print('failed to load${error.message}');
          }

          if (interstitialAttempts <= 5) {
            createInterstitialAd();
          }
        },
      ),
    );
  }

  showInterstitialAd() {
    if (interstitialAd == null) {
      if (kDebugMode) {
        print('trying to show before loading');
      }
      return;
    }
    interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) => print('ad showed $ad'),
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        if (kDebugMode) {
          print('failed to show the ad $ad');
        }
        createInterstitialAd();
      },
    );
    interstitialAd!.show();
    interstitialAd = null;
  }
}
