import 'dart:io';
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
            logoAssetPath: 'assets/images/logo_512.png')
        // .then((_) {play();})
        ;
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

  // Atualiza os metadados da notificação
  Future<void> updateNotificationMetadata({
    required String title,
    String? subtitle,
    String? albumArtPath,
  }) async {
    try {
      if (!_isPlaying) {
        print('⚠️ Rádio não está tocando, não atualizando notificação');
        return;
      }
      
      // Monta o título completo com artista se disponível
      String fullTitle = subtitle != null && subtitle.isNotEmpty
          ? '$title - $subtitle'
          : title;
      
      print('🔄 Atualizando notificação: $fullTitle');
      
      // Pausa brevemente para garantir que a atualização funcione
      bool wasPlaying = _isPlaying;
      
      // Atualiza a notificação usando o RadioPlayer
      // Nota: pode ser necessário recriar a estação para atualizar
      // Usa a capa do álbum se disponível, senão usa o logo padrão
      // Tenta usar o caminho do arquivo local diretamente
      String logoPath = 'assets/images/logo_512.png'; // Padrão: logo
      
      if (albumArtPath != null && albumArtPath.isNotEmpty) {
        // Verifica se o arquivo existe antes de usar
        try {
          final file = File(albumArtPath);
          if (await file.exists()) {
            // Tenta usar o caminho do arquivo local diretamente
            // O radio_player pode aceitar caminhos de arquivo locais no Android
            logoPath = albumArtPath;
            print('🖼️ Usando capa do álbum: $logoPath');
          } else {
            print('⚠️ Arquivo da capa não existe, usando logo padrão');
          }
        } catch (e) {
          print('⚠️ Erro ao verificar arquivo da capa: $e, usando logo padrão');
        }
      } else {
        print('🖼️ Usando logo padrão');
      }
      
      // Sempre atualiza o título, mesmo se a imagem falhar
      await RadioPlayer.setStation(
        title: fullTitle,
        url: RadioConfig.host,
        logoAssetPath: logoPath,
      );
      
      // Se estava tocando, continua tocando
      if (wasPlaying) {
        await RadioPlayer.play();
      }
      
      print('✅ Notificação atualizada no controller: $fullTitle');
    } catch (e, stackTrace) {
      print('❌ Erro ao atualizar notificação no controller: $e');
      print('📚 Stack trace: $stackTrace');
    }
  }
}
