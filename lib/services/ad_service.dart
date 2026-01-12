import 'package:flutter/foundation.dart';

/// Mock Ad Service for Judge It app.
/// 
/// This service handles interstitial ad logic. Currently prints to console.
/// Replace with real AdMob implementation later.
class AdService {
  static final AdService _instance = AdService._internal();
  
  factory AdService() => _instance;
  
  AdService._internal();

  /// Shows an interstitial ad.
  /// Currently prints to console - replace with AdMob later.
  void showInterstitialAd() {
    debugPrint('📺 Ad Shown - Interstitial ad triggered');
    // TODO: Replace with real AdMob implementation
    // await InterstitialAd.load(
    //   adUnitId: 'ca-app-pub-xxx/yyy',
    //   request: AdRequest(),
    //   adLoadCallback: ...
    // );
  }
}
