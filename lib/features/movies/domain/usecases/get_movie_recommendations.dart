import '../entities/movie.dart';
import '../repositories/movie_repository.dart';

class GetMovieRecommendations {
  final MovieRepository repository;

  GetMovieRecommendations(this.repository);

  Future<List<Movie>> call(int movieId) {
    return repository.getMovieRecommendations(movieId);
  }
}
