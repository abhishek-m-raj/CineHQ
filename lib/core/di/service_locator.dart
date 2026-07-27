import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../storage/local_storage.dart';
import '../network/api_client.dart';
import '../network/vidking_scraper.dart';

// Movie Feature
import '../../features/movies/data/datasources/movie_remote_data_source.dart';
import '../../features/movies/data/repositories/movie_repository_impl.dart';
import '../../features/movies/domain/repositories/movie_repository.dart';
import '../../features/movies/domain/usecases/get_movie_details.dart';
import '../../features/movies/domain/usecases/get_now_playing_movies.dart';
import '../../features/movies/domain/usecases/get_popular_movies.dart';
import '../../features/movies/domain/usecases/get_top_rated_movies.dart';
import '../../features/movies/domain/usecases/search_movies.dart';
import '../../features/movies/presentation/blocs/movies_bloc.dart';
import '../../features/movies/presentation/cubits/movie_detail_cubit.dart';
import '../../features/movies/presentation/cubits/favorites_cubit.dart';

// TV Show Feature
import '../../features/tv_shows/data/datasources/tv_show_remote_data_source.dart';
import '../../features/tv_shows/data/repositories/tv_show_repository_impl.dart';
import '../../features/tv_shows/domain/repositories/tv_show_repository.dart';
import '../../features/tv_shows/domain/usecases/get_airing_today_tv_shows.dart';
import '../../features/tv_shows/domain/usecases/get_popular_tv_shows.dart';
import '../../features/tv_shows/domain/usecases/get_top_rated_tv_shows.dart';
import '../../features/tv_shows/domain/usecases/get_tv_show_details.dart';
import '../../features/tv_shows/domain/usecases/search_tv_shows.dart';
import '../../features/tv_shows/domain/usecases/get_season_episodes.dart';
import '../../features/tv_shows/presentation/blocs/tv_shows_bloc.dart';
import '../../features/tv_shows/presentation/cubits/tv_show_detail_cubit.dart';
import '../../features/tv_shows/presentation/cubits/tv_favorites_cubit.dart';

import '../../features/movies/domain/usecases/get_movie_recommendations.dart';
import '../../features/tv_shows/domain/usecases/get_tv_show_recommendations.dart';

// Presentation Blocs/Cubits
import '../theme/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Talker Logging
  final talker = TalkerFlutter.init();
  sl.registerSingleton<Talker>(talker);

  // External Libraries
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  sl.registerLazySingleton<Dio>(() => Dio());

  // Core Storage & Networking
  sl.registerLazySingleton<LocalStorage>(() => LocalStorage(sl()));
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl(), sl(), sl()));
  sl.registerLazySingleton<VidkingScraper>(() => VidkingScraper());

  // Data Sources
  sl.registerLazySingleton<MovieRemoteDataSource>(
    () => DynamicMovieRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<TVShowRemoteDataSource>(
    () => DynamicTVShowRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<MovieRepository>(
    () => MovieRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<TVShowRepository>(
    () => TVShowRepositoryImpl(sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetNowPlayingMovies(sl()));
  sl.registerLazySingleton(() => GetPopularMovies(sl()));
  sl.registerLazySingleton(() => GetTopRatedMovies(sl()));
  sl.registerLazySingleton(() => GetMovieDetails(sl()));
  sl.registerLazySingleton(() => SearchMovies(sl()));
  sl.registerLazySingleton(() => GetMovieRecommendations(sl()));

  sl.registerLazySingleton(() => GetAiringTodayTVShows(sl()));
  sl.registerLazySingleton(() => GetPopularTVShows(sl()));
  sl.registerLazySingleton(() => GetTopRatedTVShows(sl()));
  sl.registerLazySingleton(() => GetTVShowDetails(sl()));
  sl.registerLazySingleton(() => SearchTVShows(sl()));
  sl.registerLazySingleton(() => GetSeasonEpisodes(sl()));
  sl.registerLazySingleton(() => GetTVShowRecommendations(sl()));

  // Presentation Layer - Blocs & Cubits
  sl.registerLazySingleton(() => ThemeCubit(sl()));
  sl.registerLazySingleton(() => FavoritesCubit(sl()));
  sl.registerLazySingleton(() => TvFavoritesCubit(sl()));
  
  // Consolidated MoviesBloc
  sl.registerLazySingleton(() => MoviesBloc(
    getNowPlayingMovies: sl(),
    getPopularMovies: sl(),
    getTopRatedMovies: sl(),
    searchMovies: sl(),
  ));

  // TVShowsBloc
  sl.registerLazySingleton(() => TVShowsBloc(
    getAiringTodayTVShows: sl(),
    getPopularTVShows: sl(),
    getTopRatedTVShows: sl(),
    searchTVShows: sl(),
  ));
  
  sl.registerFactory(() => MovieDetailCubit(sl()));
  sl.registerFactory(() => TVShowDetailCubit(sl()));
}
