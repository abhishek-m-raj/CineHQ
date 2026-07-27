import 'track.dart';

abstract class Datasource {
  final String? title;
  final String? subtitle;
  final String? server;
  final String? coverImg;
  final List<VidTrack>? tracks;
  final Map<String, String>? headers;

  Datasource({this.title, this.subtitle, this.server, this.coverImg, this.tracks, this.headers});

  String? get thumbnailVttUrl {
    try {
      return tracks?.firstWhere((i) => i.type == VidTrackType.thumbnail).url;
    } catch (_) {
      return null;
    }
  }
}

class SingleDatasource extends Datasource {
  final String url;
  SingleDatasource({
    super.title,
    super.subtitle,
    super.server,
    super.coverImg,
    required this.url,
    super.tracks,
    super.headers,
  });
}

class MultiDatasource extends Datasource {
  final Map<int, String> links;
  MultiDatasource({
    super.title,
    super.subtitle,
    super.server,
    super.coverImg,
    required this.links,
    super.tracks,
    super.headers,
  });
}

class FileDatasource extends Datasource {
  final String path;
  FileDatasource({super.title, super.subtitle, super.coverImg, required this.path});
}
