import 'package:flutter/material.dart';
import 'package:radio_player/radio_player.dart';
import 'package:vgs/configs/radio_config.dart';

late final RadioController radioController;

class RadioController with ChangeNotifier {
  bool _isPlaying = false;

  bool get isPlaying => _isPlaying;

  RadioController() {
    RadioPlayer.setStation(
      title: RadioConfig.title,
      url: RadioConfig.host,
      logoAssetPath: 'assets/images/logo_512.png',
      parseStreamMetadata: true,
      // Mesma ideia do iTune.js: após ICY (artista/título), nativo consulta iTunes para a capa.
      lookupOnlineArtwork: true,
    );
  }

  void play() {
    _isPlaying = true;
    RadioPlayer.play();
    notifyListeners();
  }

  void pause() {
    _isPlaying = false;
    RadioPlayer.pause();
    notifyListeners();
  }

  /// Atualiza lock screen / notificação **sem** recriar o player (evita perder ICY no iOS).
  Future<void> updateNotificationMetadata({
    required String title,
    String? subtitle,
    String? artworkHttpUrl,
  }) async {
    try {
      if (!_isPlaying) {
        return;
      }

      await RadioPlayer.setCustomMetadata(
        artist: subtitle,
        title: title,
        artworkUrl: (artworkHttpUrl != null &&
                artworkHttpUrl.isNotEmpty &&
                artworkHttpUrl.startsWith('http'))
            ? artworkHttpUrl
            : null,
      );
    } catch (e, st) {
      debugPrint('updateNotificationMetadata: $e\n$st');
    }
  }
}
