import '../entities/tv_show.dart';
import '../entities/tv_show_detail.dart';
import '../entities/episode.dart';

abstract class TVShowRepository {
  Future<List<TVShow>> getAiringTodayTVShows();
  Future<List<TVShow>> getPopularTVShows();
  Future<List<TVShow>> getTopRatedTVShows();
  Future<TVShowDetail> getTVShowDetails(int id);
  Future<List<TVShow>> searchTVShows(String query);
  Future<List<Episode>> getSeasonEpisodes(int tvShowId, int seasonNumber);
  Future<List<TVShow>> getTVShowRecommendations(int id);
}
