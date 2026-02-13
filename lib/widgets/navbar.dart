import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vgs/configs/social_config.dart';

const Color _corClara = Color.fromARGB(255, 1, 159, 102);
const Color _corEscuro = Color.fromARGB(255, 1, 100, 65);

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  static Future<void> handleMenuSelection(BuildContext context, String value) async {
    String? privacyPolicy;
    String? aboutUs;
    
    // Carregar assets
    var dataPrivacyPolicy =
        await rootBundle.loadString('assets/texts/privacy_policy.txt');
    var dataAboutUs = await rootBundle.loadString('assets/texts/about_us.txt');
    privacyPolicy = dataPrivacyPolicy;
    aboutUs = dataAboutUs;
    
    switch (value) {
      case 'about':
        _showAboutDialog(context, aboutUs);
        break;
      case 'privacy':
        _showPrivacyDialog(context, privacyPolicy);
        break;
      case 'share':
        _handleShare();
        break;
      case 'rate':
        _handleRate();
        break;
    }
  }

  static void _showAboutDialog(BuildContext context, String? aboutUs) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: _corEscuro,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/vgstv.png',
                        width: (MediaQuery.of(context).size.width / 2.6) - 10,
                        fit: BoxFit.fitHeight,
                      ),
                      Image.asset(
                        'assets/images/ceres87-transparente.png',
                        width: (MediaQuery.of(context).size.width / 2.6) - 10,
                        fit: BoxFit.fitHeight,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: _corClara,
                  ),
                  child: Text(
                    aboutUs ?? '',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 25),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: _corClara,
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Copyright(c) - VGSTV Play & Ceres FM 87.9',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Versão: 1.0.0',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  static void _showPrivacyDialog(BuildContext context, String? privacyPolicy) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Text(
              privacyPolicy ?? '',
              style: const TextStyle(),
            ),
          ),
        );
      },
    );
  }

  static void _handleShare() {
    if (Platform.isAndroid) {
      Share.share(
          'Confira esse app https://play.google.com/store/apps/details?id=com.vgstv.player');
    } else if (Platform.isIOS) {
      Share.share(
          'Confira esse app https://apps.apple.com/app/id[SEU_APP_ID]');
    }
  }

  static void _handleRate() {
    if (Platform.isAndroid) {
      launchUrl(
        Uri.parse(
            'https://play.google.com/store/apps/details?id=com.vgstv.player'),
        mode: LaunchMode.externalApplication,
      );
    } else if (Platform.isIOS) {
      launchUrl(
        Uri.parse('https://apps.apple.com/app/id[SEU_APP_ID]'),
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
  String? _privacyPolicy;
  String? _aboutUs;


  Widget _buildListTile({
    IconData? icon,
    required String title,
    required Function() onTap,
  }) =>
      ListTile(
        leading: Icon(
          icon,
          size: 24,
          semanticLabel: '$title Icon',
          color: Colors.white,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.lerp(
              FontWeight.w500,
              FontWeight.w700,
              0.9,
            ),
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        onTap: onTap,
      );

  List<Widget> _buildItems(BuildContext context) {
    return [
      // About Us
      _buildListTile(
        icon: Icons.group_outlined,
        title: 'Sobre nós',
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                backgroundColor: _corEscuro,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      // const SizedBox(height: 10),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/vgstv.png',
                              width: (MediaQuery.of(context).size.width / 2.6) -
                                  10,
                              fit: BoxFit.fitHeight,
                            ),
                            Image.asset(
                              'assets/images/ceres87-transparente.png',
                              width: (MediaQuery.of(context).size.width / 2.6) -
                                  10,
                              fit: BoxFit.fitHeight,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: _corClara,
                        ),
                        child: Text(
                          _aboutUs ?? '',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 25),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: _corClara,
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Copyright(c) - VGSTV Play & Ceres FM 87.9',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Versão: 1.0.0',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // Privacy Policy
      _buildListTile(
        icon: Icons.description_outlined,
        title: 'Política de Privacidade',
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return Dialog(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    _privacyPolicy ?? '',
                    style: const TextStyle(),
                  ),
                ),
              );
            },
          );
        },
      ),

      // Share
      _buildListTile(
          icon: Icons.share_outlined,
          title: 'Compartilhar',
          onTap: () {
            if (Platform.isAndroid) {
              Share.share(
                  'Confira esse app https://play.google.com/store/apps/details?id=com.vgstv.player');
            } else if (Platform.isIOS) {
              Share.share(
                  'Confira esse app https://apps.apple.com/app/id[SEU_APP_ID]');
            }
          }),
      // Rate Us
      _buildListTile(
        icon: Icons.star_outline,
        title: 'Avalie o aplicativo',
        onTap: () {
          if (Platform.isAndroid) {
            launchUrl(
              Uri.parse(
                  'https://play.google.com/store/apps/details?id=com.vgstv.player'),
              mode: LaunchMode.externalApplication,
            );
          } else if (Platform.isIOS) {
            launchUrl(
              Uri.parse('https://apps.apple.com/app/id[SEU_APP_ID]'),
              mode: LaunchMode.externalApplication,
            );
          }
        },
      ),
      // Divider
      const Divider(color: Colors.white24, height: 20),
      // Social Media Section
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          'Redes Sociais',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      // Facebook
      if (SocialConfig.facebook.isNotEmpty)
        _buildListTile(
          icon: FontAwesomeIcons.facebook,
          title: 'Facebook',
          onTap: () {
            launchUrl(
              Uri.parse(SocialConfig.facebook),
              mode: LaunchMode.externalApplication,
            );
          },
        ),
      // Instagram
      if (SocialConfig.instagram.isNotEmpty)
        _buildListTile(
          icon: FontAwesomeIcons.instagram,
          title: 'Instagram',
          onTap: () {
            launchUrl(
              Uri.parse(SocialConfig.instagram),
              mode: LaunchMode.externalApplication,
            );
          },
        ),
      // Email
      if (SocialConfig.email.isNotEmpty)
        _buildListTile(
          icon: Icons.email,
          title: 'E-mail',
          onTap: () {
            launchUrl(
              Uri.parse(SocialConfig.email),
              mode: LaunchMode.externalApplication,
            );
          },
        ),
      // WhatsApp
      if (SocialConfig.whatsapp.isNotEmpty)
        _buildListTile(
          icon: FontAwesomeIcons.whatsapp,
          title: 'WhatsApp',
          onTap: () {
            launchUrl(
              Uri.parse(SocialConfig.whatsapp),
              mode: LaunchMode.externalApplication,
            );
          },
        ),
    ];
  }

  @override
  void initState() {
    loadAsset();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: _corEscuro,
      child: ListView(
        padding: const EdgeInsets.only(top: 0),
        children: [
          Container(
            color: _corClara,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: DrawerHeader(
              margin: EdgeInsets.zero,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'assets/images/vgstv.png',
                    width: 150,
                    fit: BoxFit.fitWidth,
                  ),
                  Text(
                    'VGSTV Play & Ceres FM',
                    style: TextStyle(
                      fontWeight: FontWeight.lerp(
                          FontWeight.w500, FontWeight.w700, 0.9),
                      fontSize: 20,
                      height: 1.8,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ..._buildItems(context),
        ],
      ),
    );
  }

  Future<void> loadAsset() async {
    var dataPrivacyPolicy =
        await rootBundle.loadString('assets/texts/privacy_policy.txt');
    var dataAboutUs = await rootBundle.loadString('assets/texts/about_us.txt');
    _privacyPolicy = dataPrivacyPolicy;
    _aboutUs = dataAboutUs;
  }

}
