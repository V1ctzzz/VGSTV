import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vgs/controllers/controller_youtube.dart';
import 'package:vgs/entitys/entity_video.dart';
import 'package:vgs/widgets/widget_video.dart';

class VideosPage extends StatefulWidget {
  const VideosPage({super.key});

  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  final _controllerYoutube = ControllerYoutube();
  List<EntityVideo> videos = <EntityVideo>[];

  Future<void> _getVideos() async {
    var lvideos = await _controllerYoutube.getVideos();
    setState(() {
      videos = lvideos;
    });
  }

  @override
  void initState() {
    super.initState();
    // Força orientação portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _getVideos();
  }

  @override
  Widget build(BuildContext context) {
    // Garante orientação portrait
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/vgs_background.jpg'),
          fit: BoxFit.fitHeight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(top: 10.0, left: 0.0),
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
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
          child: Center(
            child: videos.isEmpty
                ? const CircularProgressIndicator()
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: videos.length,
                    itemBuilder: (context, index) {
                      return WidgetVideo(video: videos[index]);
                    },
                  ),
          ),
        ),
      ),
    );
  }
}
