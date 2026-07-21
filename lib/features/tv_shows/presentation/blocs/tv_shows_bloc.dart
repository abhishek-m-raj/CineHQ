import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/tv_show.dart';
import '../../domain/usecases/get_airing_today_tv_shows.dart';
import '../../domain/usecases/get_popular_tv_shows.dart';
import '../../domain/usecases/get_top_rated_tv_shows.dart';
import '../../domain/usecases/search_tv_shows.dart';
import '../cubits/tv_shows_list_state.dart';

// Search States
abstract class TVShowSearchState {
  const TVShowSearchState();
}

class TVShowSearchInitial extends TVShowSearchState {
  const TVShowSearchInitial();
}

class TVShowSearchLoading extends TVShowSearchState {
  const TVShowSearchLoading();
}

class TVShowSearchLoaded extends TVShowSearchState {
  final List<TVShow> tvShows;
  const TVShowSearchLoaded(this.tvShows);
}

class TVShowSearchError extends TVShowSearchState {
  final String message;
  const TVShowSearchError(this.message);
}

// Events
abstract class TVShowsEvent {
  const TVShowsEvent();
}

class LoadAiringTodayTVShowsEvent extends TVShowsEvent {
  const LoadAiringTodayTVShowsEvent();
}

class LoadPopularTVShowsEvent extends TVShowsEvent {
  const LoadPopularTVShowsEvent();
}

class LoadTopRatedTVShowsEvent extends TVShowsEvent {
  const LoadTopRatedTVShowsEvent();
}

class SearchTVShowsEvent extends TVShowsEvent {
  final String query;
  const SearchTVShowsEvent(this.query);
}

class ClearTVShowSearchEvent extends TVShowsEvent {
  const ClearTVShowSearchEvent();
}

// States
class TVShowsState {
  final TVShowsListState airingTodayState;
  final TVShowsListState popularState;
  final TVShowsListState topRatedState;
  final TVShowSearchState searchState;

  const TVShowsState({
    this.airingTodayState = const TVShowsListInitial(),
    this.popularState = const TVShowsListInitial(),
    this.topRatedState = const TVShowsListInitial(),
    this.searchState = const TVShowSearchInitial(),
  });

  TVShowsState copyWith({
    TVShowsListState? airingTodayState,
    TVShowsListState? popularState,
    TVShowsListState? topRatedState,
    TVShowSearchState? searchState,
  }) {
    return TVShowsState(
      airingTodayState: airingTodayState ?? this.airingTodayState,
      popularState: popularState ?? this.popularState,
      topRatedState: topRatedState ?? this.topRatedState,
      searchState: searchState ?? this.searchState,
    );
  }
}

class TVShowsBloc extends Bloc<TVShowsEvent, TVShowsState> {
  final GetAiringTodayTVShows getAiringTodayTVShows;
  final GetPopularTVShows getPopularTVShows;
  final GetTopRatedTVShows getTopRatedTVShows;
  final SearchTVShows searchTVShows;

  TVShowsBloc({
    required this.getAiringTodayTVShows,
    required this.getPopularTVShows,
    required this.getTopRatedTVShows,
    required this.searchTVShows,
  }) : super(const TVShowsState()) {
    on<LoadAiringTodayTVShowsEvent>(_onLoadAiringToday);
    on<LoadPopularTVShowsEvent>(_onLoadPopular);
    on<LoadTopRatedTVShowsEvent>(_onLoadTopRated);
    on<SearchTVShowsEvent>(_onSearch);
    on<ClearTVShowSearchEvent>(_onClearSearch);
  }

  Future<void> _onLoadAiringToday(LoadAiringTodayTVShowsEvent event, Emitter<TVShowsState> emit) async {
    emit(state.copyWith(airingTodayState: const TVShowsListLoading()));
    try {
      final tvShows = await getAiringTodayTVShows();
      emit(state.copyWith(airingTodayState: TVShowsListLoaded(tvShows)));
    } catch (e) {
      emit(state.copyWith(airingTodayState: TVShowsListError(e.toString())));
    }
  }

  Future<void> _onLoadPopular(LoadPopularTVShowsEvent event, Emitter<TVShowsState> emit) async {
    emit(state.copyWith(popularState: const TVShowsListLoading()));
    try {
      final tvShows = await getPopularTVShows();
      emit(state.copyWith(popularState: TVShowsListLoaded(tvShows)));
    } catch (e) {
      emit(state.copyWith(popularState: TVShowsListError(e.toString())));
    }
  }

  Future<void> _onLoadTopRated(LoadTopRatedTVShowsEvent event, Emitter<TVShowsState> emit) async {
    emit(state.copyWith(topRatedState: const TVShowsListLoading()));
    try {
      final tvShows = await getTopRatedTVShows();
      emit(state.copyWith(topRatedState: TVShowsListLoaded(tvShows)));
    } catch (e) {
      emit(state.copyWith(topRatedState: TVShowsListError(e.toString())));
    }
  }

  Future<void> _onSearch(SearchTVShowsEvent event, Emitter<TVShowsState> emit) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(state.copyWith(searchState: const TVShowSearchInitial()));
      return;
    }
    emit(state.copyWith(searchState: const TVShowSearchLoading()));
    try {
      final tvShows = await searchTVShows(query);
      emit(state.copyWith(searchState: TVShowSearchLoaded(tvShows)));
    } catch (e) {
      emit(state.copyWith(searchState: TVShowSearchError(e.toString())));
    }
  }

  void _onClearSearch(ClearTVShowSearchEvent event, Emitter<TVShowsState> emit) {
    emit(state.copyWith(searchState: const TVShowSearchInitial()));
  }
}
