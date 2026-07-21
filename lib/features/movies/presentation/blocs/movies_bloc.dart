import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/movie.dart';
import '../../domain/usecases/get_now_playing_movies.dart';
import '../../domain/usecases/get_popular_movies.dart';
import '../../domain/usecases/get_top_rated_movies.dart';
import '../../domain/usecases/search_movies.dart';
import '../cubits/movies_list_state.dart';

// Search States
abstract class MovieSearchState {
  const MovieSearchState();
}

class MovieSearchInitial extends MovieSearchState {
  const MovieSearchInitial();
}

class MovieSearchLoading extends MovieSearchState {
  const MovieSearchLoading();
}

class MovieSearchLoaded extends MovieSearchState {
  final List<Movie> movies;
  const MovieSearchLoaded(this.movies);
}

class MovieSearchError extends MovieSearchState {
  final String message;
  const MovieSearchError(this.message);
}

// Events
abstract class MoviesEvent {
  const MoviesEvent();
}

class LoadNowPlayingMoviesEvent extends MoviesEvent {
  const LoadNowPlayingMoviesEvent();
}

class LoadPopularMoviesEvent extends MoviesEvent {
  const LoadPopularMoviesEvent();
}

class LoadTopRatedMoviesEvent extends MoviesEvent {
  const LoadTopRatedMoviesEvent();
}

class SearchMoviesEvent extends MoviesEvent {
  final String query;
  const SearchMoviesEvent(this.query);
}

class ClearSearchEvent extends MoviesEvent {
  const ClearSearchEvent();
}

// States
class MoviesState {
  final MoviesListState nowPlayingState;
  final MoviesListState popularState;
  final MoviesListState topRatedState;
  final MovieSearchState searchState;

  const MoviesState({
    this.nowPlayingState = const MoviesListInitial(),
    this.popularState = const MoviesListInitial(),
    this.topRatedState = const MoviesListInitial(),
    this.searchState = const MovieSearchInitial(),
  });

  MoviesState copyWith({
    MoviesListState? nowPlayingState,
    MoviesListState? popularState,
    MoviesListState? topRatedState,
    MovieSearchState? searchState,
  }) {
    return MoviesState(
      nowPlayingState: nowPlayingState ?? this.nowPlayingState,
      popularState: popularState ?? this.popularState,
      topRatedState: topRatedState ?? this.topRatedState,
      searchState: searchState ?? this.searchState,
    );
  }
}

class MoviesBloc extends Bloc<MoviesEvent, MoviesState> {
  final GetNowPlayingMovies getNowPlayingMovies;
  final GetPopularMovies getPopularMovies;
  final GetTopRatedMovies getTopRatedMovies;
  final SearchMovies searchMovies;

  MoviesBloc({
    required this.getNowPlayingMovies,
    required this.getPopularMovies,
    required this.getTopRatedMovies,
    required this.searchMovies,
  }) : super(const MoviesState()) {
    on<LoadNowPlayingMoviesEvent>(_onLoadNowPlaying);
    on<LoadPopularMoviesEvent>(_onLoadPopular);
    on<LoadTopRatedMoviesEvent>(_onLoadTopRated);
    on<SearchMoviesEvent>(_onSearch);
    on<ClearSearchEvent>(_onClearSearch);
  }

  Future<void> _onLoadNowPlaying(LoadNowPlayingMoviesEvent event, Emitter<MoviesState> emit) async {
    emit(state.copyWith(nowPlayingState: const MoviesListLoading()));
    try {
      final movies = await getNowPlayingMovies();
      emit(state.copyWith(nowPlayingState: MoviesListLoaded(movies)));
    } catch (e) {
      emit(state.copyWith(nowPlayingState: MoviesListError(e.toString())));
    }
  }

  Future<void> _onLoadPopular(LoadPopularMoviesEvent event, Emitter<MoviesState> emit) async {
    emit(state.copyWith(popularState: const MoviesListLoading()));
    try {
      final movies = await getPopularMovies();
      emit(state.copyWith(popularState: MoviesListLoaded(movies)));
    } catch (e) {
      emit(state.copyWith(popularState: MoviesListError(e.toString())));
    }
  }

  Future<void> _onLoadTopRated(LoadTopRatedMoviesEvent event, Emitter<MoviesState> emit) async {
    emit(state.copyWith(topRatedState: const MoviesListLoading()));
    try {
      final movies = await getTopRatedMovies();
      emit(state.copyWith(topRatedState: MoviesListLoaded(movies)));
    } catch (e) {
      emit(state.copyWith(topRatedState: MoviesListError(e.toString())));
    }
  }

  Future<void> _onSearch(SearchMoviesEvent event, Emitter<MoviesState> emit) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(state.copyWith(searchState: const MovieSearchInitial()));
      return;
    }
    emit(state.copyWith(searchState: const MovieSearchLoading()));
    try {
      final movies = await searchMovies(query);
      emit(state.copyWith(searchState: MovieSearchLoaded(movies)));
    } catch (e) {
      emit(state.copyWith(searchState: MovieSearchError(e.toString())));
    }
  }

  void _onClearSearch(ClearSearchEvent event, Emitter<MoviesState> emit) {
    emit(state.copyWith(searchState: const MovieSearchInitial()));
  }
}
