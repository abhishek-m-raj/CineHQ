import 'package:dio/dio.dart';
import '../../domain/repositories/movie_repository.dart';
import '../../domain/entities/movie.dart';
import '../../domain/entities/movie_detail.dart';
import '../datasources/movie_remote_data_source.dart';
import '../../../../core/errors/failure.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource _remoteDataSource;

  MovieRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<Movie>> getNowPlayingMovies() async {
    try {
      return await _remoteDataSource.getNowPlayingMovies();
    } on DioException catch (e) {
      throw ServerFailure(_handleDioError(e));
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<Movie>> getPopularMovies() async {
    try {
      return await _remoteDataSource.getPopularMovies();
    } on DioException catch (e) {
      throw ServerFailure(_handleDioError(e));
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<Movie>> getTopRatedMovies() async {
    try {
      return await _remoteDataSource.getTopRatedMovies();
    } on DioException catch (e) {
      throw ServerFailure(_handleDioError(e));
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<MovieDetail> getMovieDetails(int id) async {
    try {
      return await _remoteDataSource.getMovieDetails(id);
    } on DioException catch (e) {
      throw ServerFailure(_handleDioError(e));
    } catch (e) {
      throw ServerFailure(e.toString());
    }
  }

  @override
  Future<List<Movie>> searchMovies(String query) async {
    try {
      return await _remoteDataSource.searchMovies(query);
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
