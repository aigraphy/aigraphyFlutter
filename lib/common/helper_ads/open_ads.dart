import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_lovin_utils.dart';

class AppLifecycleReactor {
  const AppLifecycleReactor();

  void listenToAppStateChanges(BuildContext context) {
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream
        .forEach((state) => _onAppStateChanged(state, context));
  }

  void _onAppStateChanged(AppState appState, BuildContext context) {
    if (appState == AppState.foreground) {
      AdLovinUtils().showAdIfReady();
    }
  }
}
