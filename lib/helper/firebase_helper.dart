import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

FirebaseHelper? firebaseHelper;

class FirebaseHelper {
  FirebaseAnalytics? analytics;
  FirebaseApp? app;

  FirebaseHelper();

  Future<void> init() async {
    app = await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey:
                'AIzaSyAGpdLlQOKdet05kK1_-yllQpB6IkENDgM', //'AIzaSyC5hJ_D8Z88tbQuUBuoNiquDMp6cns9myk',
            appId:
                '1:64541701192:android:43928c85bfedfab0b7d47d', //'1:203886889190:android:187be44d128a5150f35327',
            messagingSenderId: '8602189615',
            projectId: 'vgstv-play'));
    analytics = FirebaseAnalytics.instance;
    if (kDebugMode) {
      print('FirebaseHelper inicializado');
    }
  }

  void appOpen() async {
    if (kDebugMode) {
      print('App Open');
    }
    await analytics?.logAppOpen();
  }

  void screenView(String screenName) async {
    if (kDebugMode) {
      print('Screen View - $screenName');
    }
    await analytics?.logEvent(
      name: screenName,
    );
  }
}
