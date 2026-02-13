import 'package:vgs/entitys/entity_video.dart';
import 'package:vgs/models/model_youtube.dart';

class ControllerYoutube {
  final _modelYoutube = ModelYoutube();

  Future<List<EntityVideo>> getVideos({int maxResults = 15}) async {
    List<EntityVideo> videos =
        await _modelYoutube.getVideos(maxResults: maxResults);

    return videos;
  }
}
