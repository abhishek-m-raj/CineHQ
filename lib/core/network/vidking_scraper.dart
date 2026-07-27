import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';
import '../di/service_locator.dart';

class VidkingScraper {
  final Dio _dio;

  static const List<int> Hl = [
    1116352408, 1899447441, 3049323471, 3921009573, 961987163, 1508970993,
    2453635748, 2870763221, 3624381080, 310598401, 607225278, 1426881987,
    1925078388, 2162078206, 2614888103, 3248222580
  ];
  static const int Js = 61;
  static const int Sf = 8;
  static const int ms = 2654435769;
  static const List<int> Ys = [109, 118, 109, 49]; // mvm1

  VidkingScraper([Dio? dio]) : _dio = dio ?? Dio();

  static int ui(int l) {
    l = l & 0xFFFFFFFF;
    l ^= (l >> 16);
    l = (l * 2246822507) & 0xFFFFFFFF;
    l ^= (l >> 13);
    l = (l * 3266489909) & 0xFFFFFFFF;
    l ^= (l >> 16);
    return l & 0xFFFFFFFF;
  }

  static int ps(int l, int o) {
    l = l & 0xFFFFFFFF;
    o &= 31;
    if (o == 0) return l;
    return ((l << o) | (l >> (32 - o))) & 0xFFFFFFFF;
  }

  static int vf(String l) {
    int o = 2166136261;
    for (int e = 0; e < l.length; e++) {
      o = ((o ^ l.codeUnitAt(e)) * 16777619) & 0xFFFFFFFF;
    }
    return ui(o);
  }

  static int Nf(int l, int o, int e) {
    return ((l ^ o) | (l & o & e)) & 0xFFFFFFFF;
  }

  static Map<String, dynamic> Rf(String l, int o) {
    List<int?> e = List.filled(Js, null);
    int i = ui(vf(l) ^ ui((o ^ ms) & 0xFFFFFFFF));
    for (int r = 0; r < Sf; r++) {
      int n = i % Js;
      i = ps((i + ms) & 0xFFFFFFFF, 7 + (r & 7));
      e[n] = (i ^ ui(i)) & 0xFFFFFFFF;
      i = ui((i + n) & 0xFFFFFFFF);
    }
    return {'S': e, 'acc': ui(i ^ 2779096485)};
  }

  static int Cf(Map<String, dynamic> state, int o) {
    List<int?> e = state['S'] as List<int?>;
    int i = state['acc'] as int;
    int r = i % Js;
    bool hasR = e[r] != null;
    int n = hasR ? -1 : 0;
    int u = e[r] ?? 0;
    int d = (ms * (o + 1)) & 0xFFFFFFFF;
    int g = Nf(i, (u ^ d) & 0xFFFFFFFF, n);
    g = (ps((g + i) & 0xFFFFFFFF, r & 31) ^ ps(i, (r * 7) & 31)) & 0xFFFFFFFF;
    i = ui((g + ms) & 0xFFFFFFFF);
    e[r] = i;
    state['acc'] = i;
    return i;
  }

  static List<int> xf(String l, int o, int len) {
    var state = Rf(l, o);
    var r = List<int>.filled(len, 0);
    int u = 0;
    int n = 0;
    while (u < len) {
      int d = Cf(state, n);
      n++;
      r[u] = d & 255;
      u++;
      if (u < len) {
        r[u] = (d >> 8) & 255;
        u++;
      }
      if (u < len) {
        r[u] = (d >> 16) & 255;
        u++;
      }
      if (u < len) {
        r[u] = (d >> 24) & 255;
        u++;
      }
    }
    return r;
  }

  static List<int> Df(String l) {
    String normalized = l.replaceAll('-', '+').replaceAll('_', '/');
    int padLen = (4 - normalized.length % 4) % 4;
    normalized += '=' * padLen;
    return base64.decode(normalized);
  }

  static String Pf(String encryptedStr, String seed, int tmdbId) {
    var encryptedBytes = Df(encryptedStr);
    var keystream = xf(seed, tmdbId, encryptedBytes.length);
    var decrypted = List<int>.filled(encryptedBytes.length, 0);
    for (int i = 0; i < encryptedBytes.length; i++) {
      decrypted[i] = encryptedBytes[i] ^ keystream[i];
    }
    for (int i = 0; i < Ys.length; i++) {
      if (decrypted[i] != Ys[i]) {
        throw Exception("Decrypt failed: bad seed or tampered payload");
      }
    }
    return utf8.decode(decrypted.sublist(Ys.length));
  }

  /// Scrape movie video source and subtitles
  Future<Map<String, dynamic>> scrapeMovie({
    required int tmdbId,
    required String title,
    required String releaseDate,
    String? imdbId,
  }) async {
    final year = releaseDate.length >= 4 ? releaseDate.substring(0, 4) : '';
    return _scrape(
      mediaType: 'movie',
      tmdbId: tmdbId,
      title: title,
      year: year,
      imdbId: imdbId ?? '',
      seasonId: 1,
      episodeId: 1,
    );
  }

  /// Scrape TV show episode video source and subtitles
  Future<Map<String, dynamic>> scrapeTVShow({
    required int tmdbId,
    required String title,
    required int seasonId,
    required int episodeId,
    required String firstAirDate,
    String? imdbId,
  }) async {
    final year = firstAirDate.length >= 4 ? firstAirDate.substring(0, 4) : '';
    return _scrape(
      mediaType: 'tv',
      tmdbId: tmdbId,
      title: title,
      year: year,
      imdbId: imdbId ?? '',
      seasonId: seasonId,
      episodeId: episodeId,
    );
  }

  Future<Map<String, dynamic>> _scrape({
    required String mediaType,
    required int tmdbId,
    required String title,
    required String year,
    required String imdbId,
    required int seasonId,
    required int episodeId,
  }) async {
    final talker = sl<Talker>();
    talker.info("VidkingScraper: Starting scrape for $mediaType '$title' (ID: $tmdbId, Year: $year)");

    const servers = [
      {'name': 'Hydrogen', 'endpoint': 'cdn/sources-with-title'},
      {'name': 'Titanium', 'endpoint': 'tejo/sources-with-title'},
      {'name': 'Oxygen', 'endpoint': 'neon2/sources-with-title'},
      {'name': 'Lithium', 'endpoint': 'downloader2/sources-with-title'},
      {'name': 'Helium', 'endpoint': '1movies/sources-with-title'},
    ];

    final customHeaders = {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36',
      'Accept': 'application/json, text/plain, */*',
      'Accept-Language': 'en-US,en;q=0.9',
      'Origin': 'https://www.vidking.net',
      'Referer': 'https://www.vidking.net/',
      'Sec-Fetch-Dest': 'empty',
      'Sec-Fetch-Mode': 'cors',
      'Sec-Fetch-Site': 'cross-site',
      'Connection': 'keep-alive',
    };

    // 1. Fetch seed from speedracelight.com with retry
    final seedUrl = 'https://api.speedracelight.com/seed?mediaId=$tmdbId';
    String seed = '';
    talker.info("VidkingScraper: Requesting decryption seed for TMDB $tmdbId");
    for (int attempt = 1; attempt <= 2; attempt++) {
      try {
        final seedResponse = await _dio.get<Map<String, dynamic>>(
          seedUrl,
          options: Options(
            headers: customHeaders,
            sendTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );
        seed = seedResponse.data?['seed'] as String? ?? '';
        if (seed.isNotEmpty) {
          talker.info("VidkingScraper: Successfully fetched seed ($seed) on attempt $attempt");
          break;
        }
      } catch (e) {
        talker.warning("VidkingScraper: Failed to fetch seed (attempt $attempt): $e");
        if (attempt == 2) {
          throw Exception("Failed to retrieve decryption seed from server. $e");
        }
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
    if (seed.isEmpty) {
      throw Exception("Empty seed string returned from server.");
    }

    // 2. Fetch from servers concurrently
    final t = DateTime.now().millisecondsSinceEpoch;
    talker.info("VidkingScraper: Triggering concurrent fetches across ${servers.length} mirror servers...");

    final List<Future<Map<String, dynamic>>> tasks = servers.map((server) async {
      final serverName = server['name']!;
      final endpoint = server['endpoint']!;

      final url = 'https://api.speedracelight.com/$endpoint';
      final queryParams = {
        'title': title,
        'mediaType': mediaType,
        'year': year,
        'episodeId': episodeId.toString(),
        'seasonId': seasonId.toString(),
        'tmdbId': tmdbId.toString(),
        'imdbId': imdbId,
        'enc': '2',
        'seed': seed,
        '_t': t.toString(),
      };

      try {
        talker.info("VidkingScraper: [$serverName] Fetching playlist streams...");
        final response = await _dio.get<String>(
          url,
          queryParameters: queryParams,
          options: Options(
            headers: customHeaders,
            responseType: ResponseType.plain,
            sendTimeout: const Duration(seconds: 8),
            receiveTimeout: const Duration(seconds: 8),
          ),
        );

        final encryptedText = response.data;
        if (encryptedText == null || encryptedText.isEmpty) {
          throw Exception("Empty encrypted body");
        }

        talker.info("VidkingScraper: [$serverName] Encrypted data received (len: ${encryptedText.length}), decrypting...");
        final decryptedText = Pf(encryptedText, seed, tmdbId);
        final Map<String, dynamic> data = json.decode(decryptedText);
        
        final sources = data['sources'] as List<dynamic>?;
        if (sources != null && sources.isNotEmpty) {
          talker.info("VidkingScraper: [$serverName] Successfully found and decrypted ${sources.length} sources!");
          return {
            'server': serverName,
            'sources': sources,
            'subtitles': data['subtitles'] ?? [],
            'thumbnail': data['thumbnail'] ?? '',
          };
        }
        throw Exception("Decrypted response contains no streams");
      } catch (e) {
        talker.warning("VidkingScraper: [$serverName] Mirror failed: $e");
        throw Exception("Server $serverName failed: $e");
      }
    }).toList();

    // Resolve as soon as the first server returns success, or fail if all fail
    return _firstSuccessful(tasks);
  }

  Future<Map<String, dynamic>> _firstSuccessful(List<Future<Map<String, dynamic>>> futures) async {
    final completer = Completer<Map<String, dynamic>>();
    int failCount = 0;
    final total = futures.length;
    final errors = <String>[];

    for (final f in futures) {
      f.then((value) {
        if (!completer.isCompleted) {
          completer.complete(value);
        }
      }).catchError((err) {
        failCount++;
        errors.add(err.toString());
        if (failCount == total && !completer.isCompleted) {
          completer.completeError(
            Exception("All Vidking servers failed to stream this content:\n${errors.join('\n')}")
          );
        }
      });
    }

    return completer.future;
  }
}
