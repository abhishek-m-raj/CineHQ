import 'package:dio/dio.dart';
import '../../domain/repositories/tv_show_repository.dart';
import '../../domain/entities/tv_show.dart';
import '../../domain/entities/tv_show_detail.dart';
import '../datasources/tv_show_remote_data_source.dart';
import '../../../../core/errors/failure.dart';

class TVShowRepositoryImpl implements TVShowRepository {
  final TVShowRemoteDataSource _remoteDataSource;

  TVShowRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<TVShow>> getAiringTodayTVShows() async {
    try {
      return await _remoteDataSource.getAiringTodayTVShows();
    } on DioException catch (e) {
      throw ServerFailure(_handleDioError(e));
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<TVShow>> getPopularTVShows() async {
    try {
      return await _remoteDataSource.getPopularTVShows();
    } on DioException catch (e) {
      throw ServerFailure(_handleDioError(e));
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<TVShow>> getTopRatedTVShows() async {
    try {
      return await _remoteDataSource.getTopRatedTVShows();
    } on DioException catch (e) {
      throw ServerFailure(_handleDioError(e));
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<TVShowDetail> getTVShowDetails(int id) async {
    try {
      return await _remoteDataSource.getTVShowDetails(id);
    } on DioException catch (e) {
      throw ServerFailure(_handleDioError(e));
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<TVShow>> searchTVShows(String query) async {
    try {
      return await _remoteDataSource.searchTVShows(query);
    } on DioException catch (e) {
      throw ServerFailure(_handleDioError(e));
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  String _handleDioError(DioException error) {
    if (error.response?.statusCode == 401) {
      return 'Invalid API Key. Please verify your TMDB credentials in settings.';
    }
    if (error.response?.statusCode == 404) {
      return 'Request URL or resource not found.';
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timed out. Please check your internet connectivity.';
    }
    
    final errorMsg = error.toString().toLowerCase();
    if (errorMsg.contains('connection reset') || 
        errorMsg.contains('connection closed') ||
        errorMsg.contains('broken pipe')) {
      return 'Connection reset by peer. This may be due to local ISP blocks, firewall rules, or DNS censorship on TMDB. Please try connecting via a VPN or switching networks.';
    }
    return error.message ?? 'An unexpected network error occurred.';
  }
}
