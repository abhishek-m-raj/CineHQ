import '../entities/tv_show.dart';
import '../repositories/tv_show_repository.dart';

class GetTVShowRecommendations {
  final TVShowRepository repository;

  GetTVShowRecommendations(this.repository);

  Future<List<TVShow>> call(int tvShowId) {
    return repository.getTVShowRecommendations(tvShowId);
  }
}
