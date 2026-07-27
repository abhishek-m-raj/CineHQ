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
  static const _baseUrl = 'https://subs.videasy.to';

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

  Future<List<OpenSubtitlesSubtitle>> search({required String imdbId}) async {
    final response = await _dio.get<List>(
      '$_baseUrl/search',
      queryParameters: {'id': imdbId},
      options: Options(headers: {'Accept': 'application/json'}),
    );

    final data = response.data ?? [];
    return data
        .map((e) => OpenSubtitlesSubtitle(
              id: e['id'] ?? '',
              display: e['display'] ?? '',
              language: e['language'] ?? '',
              format: e['format'] ?? '',
              release: e['release'] ?? '',
              url: e['url'] ?? '',
              downloadCount: e['downloadCount'] ?? 0,
              isHearingImpaired: e['isHearingImpaired'] ?? false,
              isTrusted: e['isTrusted'] ?? false,
              origin: e['origin'] ?? '',
              flagUrl: e['flagUrl'],
            ))
        .toList();
  }

  Future<String?> downloadSubtitle(String subtitleId) async {
    try {
      final response = await _dio.get<String>(
        '$_baseUrl/download',
        queryParameters: {'id': subtitleId},
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
