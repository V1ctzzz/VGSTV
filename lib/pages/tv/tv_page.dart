import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/services.dart';
import 'package:vgs/configs/tv_config.dart';
import 'package:video_player/video_player.dart';

class TvPage extends StatefulWidget {
  const TvPage({super.key});

  @override
  State<TvPage> createState() => _TvPageState();
}

class _TvPageState extends State<TvPage> {
  final videoPlayerController =
      VideoPlayerController.networkUrl(Uri.parse(TvConfig.host));
  ChewieController? chewieController;

  @override
  void initState() {
    super.initState();
    // Força orientação landscape (deitada) ao entrar na tela de TV
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _initPlayer();
  }

  void _initPlayer() async {
    await videoPlayerController.initialize();
    setState(() {
      chewieController ??= ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: true,
        allowMuting: true,
        draggableProgressBar: false,
        fullScreenByDefault: false,
        showOptions: false,
        isLive: true,
        allowPlaybackSpeedChanging: false,
        allowFullScreen: false,
      );
    });
  }

  @override
  void dispose() {
    // Restaura orientação portrait ao sair
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    videoPlayerController.dispose();
    chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Garante orientação landscape
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    Chewie? playerWidget;
    if (chewieController != null) {
      playerWidget = Chewie(
        controller: chewieController!,
      );
    }

    return PopScope(
      onPopInvokedWithResult: (didPop, value) {
        if (didPop) {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: null,
        body: Stack(
          children: [
            playerWidget != null
                ? SizedBox.expand(child: playerWidget)
                : const Center(child: CircularProgressIndicator()),
            // Botão de voltar no canto superior esquerdo
            Positioned(
              top: 16,
              left: 16,
              child: SafeArea(
                child: Material(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(30),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () {
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.portraitUp,
                        DeviceOrientation.portraitDown,
                      ]);
                      Navigator.of(context).pop();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
