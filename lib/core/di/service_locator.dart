import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../storage/local_storage.dart';
import '../network/api_client.dart';
import '../../features/movies/data/datasources/movie_remote_data_source.dart';
import '../../features/movies/data/repositories/movie_repository_impl.dart';
import '../../features/movies/domain/repositories/movie_repository.dart';
import '../../features/movies/domain/usecases/get_movie_details.dart';
import '../../features/movies/domain/usecases/get_now_playing_movies.dart';
import '../../features/movies/domain/usecases/get_popular_movies.dart';
import '../../features/movies/domain/usecases/get_top_rated_movies.dart';
import '../../features/movies/domain/usecases/search_movies.dart';

// Presentation Blocs/Cubits
import '../theme/theme_cubit.dart';
import '../../features/movies/presentation/blocs/movies_bloc.dart';
import '../../features/movies/presentation/cubits/movie_detail_cubit.dart';
import '../../features/movies/presentation/cubits/favorites_cubit.dart';

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

  // Data Sources
  sl.registerLazySingleton<MovieRemoteDataSource>(
    () => DynamicMovieRemoteDataSourceImpl(sl()),
  );

  // Repositories
  sl.registerLazySingleton<MovieRepository>(
    () => MovieRepositoryImpl(sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetNowPlayingMovies(sl()));
  sl.registerLazySingleton(() => GetPopularMovies(sl()));
  sl.registerLazySingleton(() => GetTopRatedMovies(sl()));
  sl.registerLazySingleton(() => GetMovieDetails(sl()));
  sl.registerLazySingleton(() => SearchMovies(sl()));

  // Presentation Layer - Blocs & Cubits
  sl.registerLazySingleton(() => ThemeCubit(sl()));
  sl.registerLazySingleton(() => FavoritesCubit(sl()));
  
  // Consolidated big MoviesBloc instead of small individual list/search Cubits
  sl.registerLazySingleton(() => MoviesBloc(
    getNowPlayingMovies: sl(),
    getPopularMovies: sl(),
    getTopRatedMovies: sl(),
    searchMovies: sl(),
  ));
  
  sl.registerFactory(() => MovieDetailCubit(sl()));
}
