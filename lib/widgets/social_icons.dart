import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vgs/configs/social_config.dart';

class SocialIcons extends StatelessWidget {
  const SocialIcons({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 130,
      right: 0,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
          color: Colors.teal,
        ),
        child: Column(
          children: [
            Visibility(
              visible: SocialConfig.facebook.isNotEmpty,
              child: Padding(
                padding: const EdgeInsets.only(right: 1.0),
                child: IconButton(
                  icon: const FaIcon(FontAwesomeIcons.facebook,
                      size: 35.0, color: Colors.white),
                  onPressed: () {
                    launchUrl(Uri.parse(SocialConfig.facebook));
                  },
                ),
              ),
            ),
            Visibility(
              visible: SocialConfig.instagram.isNotEmpty,
              child: Padding(
                padding: const EdgeInsets.only(right: 1.0),
                child: IconButton(
                  icon: const FaIcon(FontAwesomeIcons.instagram,
                      size: 35.0, color: Colors.white),
                  onPressed: () {
                    launchUrl(Uri.parse(SocialConfig.instagram));
                  },
                ),
              ),
            ),
            Visibility(
              visible: SocialConfig.email.isNotEmpty,
              child: Padding(
                padding: const EdgeInsets.only(right: 1.0),
                child: IconButton(
                  icon:
                      const Icon(Icons.email, size: 35.0, color: Colors.white),
                  // FaIcon(FontAwesomeIcons.mailchimp, size: 35.0, color: Colors.white),
                  onPressed: () {
                    launchUrl(Uri.parse(SocialConfig.email));
                  },
                ),
              ),
            ),
            Visibility(
              visible: SocialConfig.whatsapp.isNotEmpty,
              child: Padding(
                padding: const EdgeInsets.only(right: 1.0),
                child: IconButton(
                  icon: const FaIcon(FontAwesomeIcons.whatsapp,
                      size: 35.0, color: Colors.white),
                  onPressed: () {
                    launchUrl(Uri.parse(SocialConfig.whatsapp));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
