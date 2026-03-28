// import 'package:flutter_radio_player/models/frp_source_modal.dart';

class RadioConfig {
  /// URL usada pelo **radio_player** (Flutter). Outro caminho comum no mesmo servidor:
  /// ver [webPlayerStreamUrl] (player HTML `<audio src="...">`).
  static const host = 'https://stm50.srvstm.com:11828/;?type=http&nocache=5';
  static const title = 'Ceres FM 87.9';
  static const description = 'VGS Radio';

  /// Mesmo ficheiro que o `fetch("metadata.php")` no player web (relativo ao HTML).
  /// **Regra:** URL absoluta = origem do site + pasta do `.html` + `metadata.php`.
  /// Ex.: HTML em `https://meusite.com/radio/index.html` →
  /// `https://meusite.com/radio/metadata.php`.
  /// Se o PHP estiver na raiz do domínio: `https://meusite.com/metadata.php`.
  /// Deixa vazio para usar só [nowPlayingFallbackUrl].
  static const String metadataPhpUrl = '';

  /// Referência do teu player web (`<audio id="radio" src="...">`).
  static const String webPlayerStreamUrl =
      'https://stm50.srvstm.com:11828/stream';

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
