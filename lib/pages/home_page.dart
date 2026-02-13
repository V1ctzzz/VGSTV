import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vgs/configs/portal_config.dart';
import 'package:vgs/helper/firebase_helper.dart';
import 'package:vgs/pages/radio/radio_page.dart';
import 'package:vgs/pages/tv/tv_page.dart';
import 'package:vgs/pages/youtube/videos_page.dart';
import 'package:vgs/widgets/bannerad_widget.dart';
import 'package:vgs/widgets/menu_button.dart';
import 'package:vgs/widgets/navbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Força orientação portrait quando a HomePage é criada
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Garante orientação portrait quando a HomePage está visível
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    // Força portrait a cada build para garantir
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    
    return Scaffold(
      key: GlobalKey<ScaffoldState>(),
      backgroundColor: Colors.transparent,
      drawer: const Navbar(),
      body: Stack(
        children: [
          // Background com gradiente verde/teal - funciona em iOS e Android
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF1B5E3E), // Verde escuro no topo
                  const Color(0xFF2E7D5A), // Verde médio
                  const Color(0xFF3FB393), // Verde claro/teal
                  const Color(0xFF4FD4B8), // Teal claro na parte inferior
                ],
                stops: const [0.0, 0.4, 0.7, 1.0],
              ),
            ),
          ),
          // Formas circulares decorativas
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Positioned(
            top: 150,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            right: 50,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: 200,
            left: -60,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            top: 350,
            right: 80,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          // Conteúdo principal
          SafeArea(
            child: Column(
              children: [
                // AppBar customizado
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 0.0),
                        child: Container(
                          height: 80,
                          width: 80,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            color: Color.fromARGB(255, 62, 223, 207),
                          ),
                          child: Builder(
                            builder: (context) => IconButton(
                              icon: const FaIcon(FontAwesomeIcons.bars),
                              onPressed: () {
                                Scaffold.of(context).openDrawer();
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Corpo principal
                Expanded(
                  child: Center(
                    child: Stack(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                MenuButton(
                                    iconType: IconType.youtube,
                                    onPressed: () {
                                      firebaseHelper?.screenView('Youtube');
                                      Navigator.of(context).push(MaterialPageRoute(
                                          builder: (context) => const VideosPage()));
                                    }),
                                MenuButton(
                                    iconType: IconType.portal,
                                    onPressed: () {
                                      firebaseHelper?.screenView('Portal');
                                      launchUrl(
                                        Uri.parse(PortalConfig.host),
                                        mode: LaunchMode.externalApplication,
                                      );
                                    }),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                MenuButton(
                                    iconType: IconType.radio,
                                    onPressed: () {
                                      firebaseHelper?.screenView('Radio');
                                      Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => const RadioPage(
                                          key: Key('Radio Page'),
                                        ),
                                      ));
                                    }),
                                MenuButton(
                                    iconType: IconType.tv,
                                    onPressed: () {
                                      firebaseHelper?.screenView('TV');
                                      Navigator.of(context).push(MaterialPageRoute(
                                        builder: (context) => const TvPage(),
                                      ));
                                    }),
                              ],
                            ),
                          ],
                        ),
                        const BannerAdWidget()
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
