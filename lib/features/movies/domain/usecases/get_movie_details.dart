import '../entities/movie_detail.dart';
import '../repositories/movie_repository.dart';

class GetMovieDetails {
  final MovieRepository repository;

  GetMovieDetails(this.repository);

  Future<MovieDetail> call(int id) async {
    return await repository.getMovieDetails(id);
  }
}
