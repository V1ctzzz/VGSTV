import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vgs/entitys/entity_video.dart';

class WidgetVideo extends StatelessWidget {
  const WidgetVideo({super.key, required this.video});
  final EntityVideo video;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () => launchUrl(
            Uri.parse('https://www.youtube.com/watch?v=${video.id}'),
            mode: LaunchMode.externalApplication),
        child: Container(
            height: 120,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: Image.network(
                video.thumbnail,
                width: 100,
                fit: BoxFit.fitWidth,
              ),
              title: Text(
                video.title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: SizedBox(
                height: 50,
                // child: SingleChildScrollView(
                child: Text(
                  video.description,
                  style: const TextStyle(fontSize: 12),
                ),
                // ),
              ),
            )),
      ),
    );
  }
}
