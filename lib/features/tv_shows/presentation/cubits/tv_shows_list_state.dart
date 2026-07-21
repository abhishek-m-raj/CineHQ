import '../../domain/entities/tv_show.dart';

abstract class TVShowsListState {
  const TVShowsListState();
}

class TVShowsListInitial extends TVShowsListState {
  const TVShowsListInitial();
}

class TVShowsListLoading extends TVShowsListState {
  const TVShowsListLoading();
}

class TVShowsListLoaded extends TVShowsListState {
  final List<TVShow> tvShows;
  const TVShowsListLoaded(this.tvShows);
}

class TVShowsListError extends TVShowsListState {
  final String message;
  const TVShowsListError(this.message);
}
