import 'package:dio/dio.dart';

class OpenSubtitlesSubtitle {
  final String id;
  final String display;
  final String language;
  final String format;
  final String release;
  final String url;
  final int downloadCount;
  final bool isHearingImpaired;
  final bool isTrusted;
  final String origin;
  final String? flagUrl;

  OpenSubtitlesSubtitle({
    required this.id,
    required this.display,
    required this.language,
    required this.format,
    required this.release,
    required this.url,
    required this.downloadCount,
    required this.isHearingImpaired,
    required this.isTrusted,
    required this.origin,
    this.flagUrl,
  });
}

class OpenSubtitlesService {
  final Dio _dio;
  static const _baseUrl = 'https://subs.bright67.online';

  OpenSubtitlesService([Dio? dio]) : _dio = dio ?? Dio();

  Future<String?> fetchImdbId({
    required Dio tmdbDio,
    required int tmdbId,
    required String mediaType,
  }) async {
    try {
      final type = mediaType == 'tv' ? 'tv' : 'movie';
      final response = await tmdbDio.get('/$type/$tmdbId/external_ids');
      final data = response.data as Map<String, dynamic>?;
      final imdbId = data?['imdb_id'] as String?;
      if (imdbId != null && imdbId.isNotEmpty) return imdbId;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<OpenSubtitlesSubtitle>> search({
    required String id,
    int? season,
    int? episode,
  }) async {
    final queryParams = <String, dynamic>{'id': id};
    if (season != null) queryParams['season'] = season;
    if (episode != null) queryParams['episode'] = episode;

    final response = await _dio.get<List>(
      '$_baseUrl/search',
      queryParameters: queryParams,
      options: Options(headers: {'Accept': 'application/json'}),
    );

    final data = response.data ?? [];
    return data
        .map((e) => OpenSubtitlesSubtitle(
              id: (e['id'] ?? '').toString(),
              display: (e['display'] ?? '').toString(),
              language: (e['language'] ?? '').toString(),
              format: (e['format'] ?? '').toString(),
              release: (e['release'] ?? e['fileName'] ?? '').toString(),
              url: (e['url'] ?? e['r2Url'] ?? '').toString(),
              downloadCount: e['downloadCount'] ?? 0,
              isHearingImpaired: e['isHearingImpaired'] ?? false,
              isTrusted: e['isTrusted'] ?? false,
              origin: (e['origin'] ?? '').toString(),
              flagUrl: e['flagUrl'],
            ))
        .toList();
  }

  Future<String?> downloadSubtitle(String subtitleIdOrUrl) async {
    try {
      final String downloadUrl;
      final Map<String, dynamic>? queryParams;
      if (subtitleIdOrUrl.startsWith('http://') ||
          subtitleIdOrUrl.startsWith('https://')) {
        downloadUrl = subtitleIdOrUrl;
        queryParams = null;
      } else {
        downloadUrl = '$_baseUrl/download';
        queryParams = {'id': subtitleIdOrUrl};
      }

      final response = await _dio.get<String>(
        downloadUrl,
        queryParameters: queryParams,
        options: Options(
          responseType: ResponseType.plain,
          headers: {'Accept': 'text/plain'},
        ),
      );
      return response.data;
    } catch (_) {
      return null;
    }
  }
}
