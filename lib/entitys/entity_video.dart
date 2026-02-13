class EntityVideo {
  late final String id;
  late final String title;
  late final String description;
  late final String thumbnail;

  EntityVideo();

  factory EntityVideo.fromJson(Map<String, dynamic> json) {
    var snippet = json['snippet'];
    var lReturn = EntityVideo()
      ..id = json['contentDetails']['upload']['videoId']
      ..title = snippet['title']
      ..description = snippet['description'];
    lReturn.thumbnail = snippet['thumbnails']['high']['url'];

    return lReturn;
  }
}
