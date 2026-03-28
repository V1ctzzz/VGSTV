/// Cabeçalhos alinhados ao tráfego típico do **Android** (WebView/Chrome mobile),
/// para APIs e CDNs que se comportam de forma diferente sem `User-Agent` (ex.: iOS).
class HttpClientConfig {
  static const Map<String, String> androidLikeHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 14; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36 VGSTVPlay/1.0',
    'Accept': 'application/json, text/plain, image/*, */*',
  };

  /// iTunes Search API responde melhor com UA estilo Safari (evita corpo vazio em alguns clientes).
  static const Map<String, String> itunesSearchHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Safari/605.1.15 VGSTVPlay/1.0',
    'Accept': 'application/json',
  };

  /// Pedidos a partir do iPhone (currentsong, imagens); alguns servidores tratam mal o UA “Android”.
  static const Map<String, String> iosSafariLikeHeaders = {
    'User-Agent':
        'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1 VGSTVPlay/1.0',
    'Accept': 'application/json, text/plain, image/*, */*',
  };
}
