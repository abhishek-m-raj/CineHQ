import '../entities/tv_show.dart';
import '../repositories/tv_show_repository.dart';

class SearchTVShows {
  final TVShowRepository repository;

  SearchTVShows(this.repository);

  Future<List<TVShow>> call(String query) async {
    return await repository.searchTVShows(query);
  }
}
