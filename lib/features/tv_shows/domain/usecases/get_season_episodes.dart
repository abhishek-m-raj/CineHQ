import '../entities/episode.dart';
import '../repositories/tv_show_repository.dart';

class GetSeasonEpisodes {
  final TVShowRepository repository;

  GetSeasonEpisodes(this.repository);

  Future<List<Episode>> call(int tvShowId, int seasonNumber) async {
    return await repository.getSeasonEpisodes(tvShowId, seasonNumber);
  }
}
