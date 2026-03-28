import 'package:dio/dio.dart';
import 'package:vgs/configs/http_client_config.dart';
import 'package:vgs/configs/youtube_config.dart';
import 'package:vgs/entitys/entity_video.dart';

/// Lista vídeos via playlist de uploads do canal (mais fiável que `activities`,
/// que muitas vezes devolve `items: []`).
class ModelYoutube {
  static const String _apiBase = 'https://www.googleapis.com/youtube/v3';

  Future<List<EntityVideo>> getVideos({int maxResults = 15}) async {
    final channelId = await YoutubeConfig.resolveChannelId();

    final dio = Dio(
        BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        validateStatus: (_) => true,
        headers: {
          ...HttpClientConfig.androidLikeHeaders,
          'Accept': 'application/json',
        },
      ),
    );

    final uploadsPlaylistId = await _fetchUploadsPlaylistId(dio, channelId);
    if (uploadsPlaylistId == null || uploadsPlaylistId.isEmpty) {
      throw Exception(
        'Canal não encontrado ou ID incorreto ($channelId). '
        'Referência Android: edita `android/app/src/main/res/values/youtube.xml` '
        '(youtube_channel_id). No iOS, espelha em Info.plist → YoutubeChannelId.',
      );
    }

    final response = await dio.get(
      '$_apiBase/playlistItems',
      queryParameters: <String, dynamic>{
        'part': 'snippet,contentDetails',
        'playlistId': uploadsPlaylistId,
        'maxResults': maxResults,
        'key': YoutubeConfig.apikey,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(_youtubeErrorMessage(response));
    }

    final raw = response.data;
    if (raw is! Map<String, dynamic>) {
      throw Exception('Resposta YouTube inválida.');
    }
    final items = raw['items'];
    if (items is! List<dynamic>) {
      return [];
    }

    final out = <EntityVideo>[];
    for (final item in items) {
      if (item is! Map<String, dynamic>) continue;
      try {
        out.add(EntityVideo.fromPlaylistItem(item));
      } catch (_) {
        continue;
      }
    }
    return out;
  }

  Future<String?> _fetchUploadsPlaylistId(Dio dio, String channelId) async {
    final response = await dio.get(
      '$_apiBase/channels',
      queryParameters: <String, dynamic>{
        'part': 'contentDetails',
        'id': channelId,
        'key': YoutubeConfig.apikey,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(_youtubeErrorMessage(response));
    }

    final raw = response.data;
    if (raw is! Map<String, dynamic>) return null;
    final items = raw['items'];
    if (items is! List<dynamic> || items.isEmpty) return null;

    final first = items.first;
    if (first is! Map<String, dynamic>) return null;
    final details = first['contentDetails'];
    if (details is! Map<String, dynamic>) return null;
    final related = details['relatedPlaylists'];
    if (related is! Map<String, dynamic>) return null;
    final uploads = related['uploads']?.toString();
    return uploads;
  }

  static String _youtubeErrorMessage(Response<dynamic> response) {
    final data = response.data;
    if (data is Map<String, dynamic>) {
      final err = data['error'];
      if (err is Map<String, dynamic>) {
        final msg = err['message']?.toString();
        if (msg != null && msg.isNotEmpty) {
          final hint = response.statusCode == 403
              ? ' Referência Android: pacote com.vgstv.radioapp. iOS: '
                  'com.vgstv.playerplayer. No Google Cloud → Credenciais, a mesma '
                  'chave deve permitir ambas as apps (ou desativa restrição de app '
                  'para testes).'
              : '';
          return 'YouTube API ($msg)$hint';
        }
      }
    }
    return 'YouTube API: HTTP ${response.statusCode}';
  }
}
