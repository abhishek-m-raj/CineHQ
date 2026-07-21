import 'package:dio/dio.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../storage/local_storage.dart';

class ApiClient {
  final Dio _dio;
  final LocalStorage _localStorage;
  final Talker _talker;

  ApiClient(this._dio, this._localStorage, this._talker) {
    // Using api.tmdb.org instead of api.themoviedb.org to bypass ISP-level SNI / DNS blocks
    // which frequently cause "Connection reset by peer" errors in various regions.
    _dio.options.baseUrl = 'https://api.tmdb.org/3';
    _dio.options.connectTimeout = const Duration(seconds: 15);
    _dio.options.receiveTimeout = const Duration(seconds: 15);
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['User-Agent'] = 'CineHQ/1.0 (Flutter; Mobile)';

    _dio.interceptors.add(
      TalkerDioLogger(
        talker: _talker,
        settings: const TalkerDioLoggerSettings(
          printRequestHeaders: true,
          printResponseHeaders: true,
          printResponseMessage: true,
        ),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final apiKey = dotenv.env['TMDB_API_KEY'] ?? '';
          if (apiKey.isNotEmpty) {
            // TMDB v3 API keys are 32 characters. If the key is a v3 key (length < 50),
            // use it as a query parameter. If it's a v4 access token, use it in the Authorization header.
            if (apiKey.length < 50) {
              options.headers.remove('Authorization');
              options.queryParameters['api_key'] = apiKey;
            } else {
              options.queryParameters.remove('api_key');
              options.headers['Authorization'] = 'Bearer $apiKey';
            }
          }

          final sessionId = _localStorage.getSessionId();
          if (sessionId != null && sessionId.isNotEmpty) {
            options.queryParameters['session_id'] = sessionId;
          }
          return handler.next(options);
        },
      ),
    );
  }

  Dio get dio => _dio;
}
