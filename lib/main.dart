import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:vgs/controllers/radio_controller.dart';
// import 'package:vgs/controllers/radio_controller.dart';
import 'package:vgs/helper/firebase_helper.dart';
import 'package:vgs/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  radioController = RadioController();
  firebaseHelper = FirebaseHelper();
  try {
    await firebaseHelper?.init();
  } catch (e) {
    debugPrint('Falha ao inicializar Firebase: $e');
  }

  try {
    await MobileAds.instance.initialize();
  } catch (e) {
    debugPrint('Falha ao inicializar Mobile Ads: $e');
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    firebaseHelper?.appOpen();
    return const MaterialApp(
      title: 'VGSTV',
      debugShowCheckedModeBanner: false,
      home: HomePage(
        key: Key('HomePage'),
      ),
    );
  }
}
