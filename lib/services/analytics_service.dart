
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart' show Firebase, FirebaseOptions;
import 'package:flutter/cupertino.dart';
import 'package:firebase_analytics/observer.dart';

import '../firebase_options.dart';


class AnalyticsService {

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver appAnalyticsObserver() =>
        FirebaseAnalyticsObserver(analytics: _analytics);

  Future logScreens({@required String? name}) async {
    await _analytics.setCurrentScreen(screenName: name);
  }

}




