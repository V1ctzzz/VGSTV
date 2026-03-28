// import 'package:flutter_radio_player/models/frp_source_modal.dart';

class RadioConfig {
  static const host = 'https://stm50.srvstm.com:11828/;?type=http&nocache=5';
  static const title = 'Ceres FM 87.9';
  static const description = 'VGS Radio';

  /// Mesmo endpoint que o `fetch("metadata.php")` do **iTune.js** (tem de ser URL **absoluta**).
  /// Ex.: se o player web está em `https://radio.exemplo.com/app/`, e o JS chama `metadata.php`,
  /// usa `https://radio.exemplo.com/app/metadata.php` ou `https://radio.exemplo.com/metadata.php`.
  /// Deixa vazio para usar só o fallback abaixo.
  static const String metadataPhpUrl = '';

  /// Fallback quando [metadataPhpUrl] está vazio (API típica Shoutcast/Icecast).
  static const String nowPlayingFallbackUrl =
      'https://stm50.srvstm.com:11828/currentsong?sid=1';

  /// Intervalo do `setInterval` do iTune.js (10 s).
  static const Duration nowPlayingPollInterval = Duration(seconds: 10);

  // static MediaSources source() => MediaSources(
  //     url: host,
  //     title: title,
  //     description: description,
  //     isPrimary: true,
  //     isAac: false);
}
