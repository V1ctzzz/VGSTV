import 'package:dio/dio.dart';
import 'package:vgs/configs/youtube_config.dart';
import 'package:vgs/entitys/entity_video.dart';

class ModelYoutube {
  Future<List<EntityVideo>> getVideos({int maxResults = 5}) async {
    final dio = Dio();
    final lReturn = <EntityVideo>[];
    final response = await dio.get(YoutubeConfig.host,
        queryParameters: {
          'part': 'id,snippet,contentDetails',
          'key': YoutubeConfig.apikey,
          'channelId': YoutubeConfig.channelID,
          'order': 'date',
          'maxResults': maxResults,
        },
        options: Options(
          validateStatus: (status) => true,
        ));

    if (response.statusCode == 200) {
      var json = response.data;
      var items = json['items'];
      for (var item in items) {
        if (item['snippet']['type'] != 'upload') continue;
        lReturn.add(EntityVideo.fromJson(item));
      }
    } else {
      throw Exception('Não foi possivel carregar os videos');
    }

    return lReturn;
  }
}
