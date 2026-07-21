import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/movie_detail.dart';
import '../../domain/usecases/get_movie_details.dart';

abstract class MovieDetailState {
  const MovieDetailState();
}

class MovieDetailInitial extends MovieDetailState {
  const MovieDetailInitial();
}

class MovieDetailLoading extends MovieDetailState {
  const MovieDetailLoading();
}

class MovieDetailLoaded extends MovieDetailState {
  final MovieDetail movie;
  const MovieDetailLoaded(this.movie);
}

class MovieDetailError extends MovieDetailState {
  final String message;
  const MovieDetailError(this.message);
}

class MovieDetailCubit extends Cubit<MovieDetailState> {
  final GetMovieDetails _getMovieDetails;

  MovieDetailCubit(this._getMovieDetails) : super(const MovieDetailInitial());

  Future<void> loadMovieDetails(int id) async {
    emit(const MovieDetailLoading());
    try {
      final movie = await _getMovieDetails(id);
      emit(MovieDetailLoaded(movie));
    } catch (e) {
      emit(MovieDetailError(e.toString()));
    }
  }
}
