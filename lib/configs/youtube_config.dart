import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// ID do canal YouTube.
///
/// **Android (referência):** `android/app/src/main/res/values/youtube.xml` →
/// `youtube_channel_id`, exposto via [MethodChannel] em [MainActivity].
///
/// **iOS:** o mesmo valor deve existir em `ios/Runner/Info.plist` na chave
/// `YoutubeChannelId` (a app lê por canal nativo com o mesmo nome de channel).
class YoutubeConfig {
  YoutubeConfig._();

  static const MethodChannel _channel =
      MethodChannel('com.vgstv.radioapp/config');

  static String? _cachedChannelId;

  /// Resolve o ID do canal (primeira chamada contacta a plataforma).
  static Future<String> resolveChannelId() async {
    if (_cachedChannelId != null) {
      return _cachedChannelId!;
    }
    try {
      final id = await _channel.invokeMethod<String>('getYoutubeChannelId');
      final trimmed = id?.trim();
      if (trimmed != null && trimmed.isNotEmpty) {
        _cachedChannelId = trimmed;
        return trimmed;
      }
    } on PlatformException catch (e, st) {
      debugPrint('YoutubeConfig.resolveChannelId: $e\n$st');
    } catch (e, st) {
      debugPrint('YoutubeConfig.resolveChannelId: $e\n$st');
    }

    _cachedChannelId = _fallbackChannelId;
    return _cachedChannelId!;
  }

  /// Se o recurso nativo falhar (ex.: testes sem engine).
  static const String _fallbackChannelId = 'UChYtmLWQYG6FOHaBtTfUX-Q';

  /// Chave **YouTube Data API v3**. No Google Cloud, permitir Android
  /// `com.vgstv.radioapp` e iOS `com.vgstv.playerplayer` na mesma chave, se
  /// usares restrições por aplicação.
  static const apikey = 'AIzaSyCyuOhTQtKT2AIVRfPWPgdu_6eeT9ti0EA';
}
