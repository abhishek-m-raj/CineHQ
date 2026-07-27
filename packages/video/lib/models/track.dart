enum VidTrackType { caption, thumbnail }

class VidTrack {
  final VidTrackType type;
  final String? label;
  final String url;
  final Map<String, String>? headers;

  VidTrack({required this.type, this.label, required this.url, this.headers});
}
