class EntityVideo {
  late final String id;
  late final String title;
  late final String description;
  late final String thumbnail;

  EntityVideo();

  /// Resposta de [playlistItems](https://developers.google.com/youtube/v3/docs/playlistItems/list).
  factory EntityVideo.fromPlaylistItem(Map<String, dynamic> json) {
    final snippet = json['snippet'];
    if (snippet is! Map<String, dynamic>) {
      throw const FormatException('snippet inválido');
    }
    final resourceId = snippet['resourceId'];
    if (resourceId is! Map<String, dynamic>) {
      throw const FormatException('resourceId inválido');
    }
    final videoId = resourceId['videoId']?.toString();
    if (videoId == null || videoId.isEmpty) {
      throw const FormatException('videoId em falta');
    }
    final thumbs = snippet['thumbnails'];
    String thumbUrl = '';
    if (thumbs is Map<String, dynamic>) {
      thumbUrl = (thumbs['high']?['url'] as String?) ??
          (thumbs['medium']?['url'] as String?) ??
          (thumbs['default']?['url'] as String?) ??
          '';
    }
    return EntityVideo()
      ..id = videoId
      ..title = snippet['title']?.toString() ?? ''
      ..description = snippet['description']?.toString() ?? ''
      ..thumbnail = thumbUrl;
  }

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
