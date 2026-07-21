import '../entities/tv_show.dart';
import '../entities/tv_show_detail.dart';

abstract class TVShowRepository {
  Future<List<TVShow>> getAiringTodayTVShows();
  Future<List<TVShow>> getPopularTVShows();
  Future<List<TVShow>> getTopRatedTVShows();
  Future<TVShowDetail> getTVShowDetails(int id);
  Future<List<TVShow>> searchTVShows(String query);
}
