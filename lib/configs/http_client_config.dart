/// Cabeçalhos alinhados ao tráfego típico do **Android** (WebView/Chrome mobile),
/// para APIs e CDNs que se comportam de forma diferente sem `User-Agent` (ex.: iOS).
class HttpClientConfig {
  static const Map<String, String> androidLikeHeaders = {
    'User-Agent':
        'Mozilla/5.0 (Linux; Android 14; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36 VGSTVPlay/1.0',
    'Accept': 'application/json, text/plain, image/*, */*',
  };
}
