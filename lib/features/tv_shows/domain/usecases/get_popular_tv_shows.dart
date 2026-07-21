import '../entities/tv_show.dart';
import '../repositories/tv_show_repository.dart';

class GetPopularTVShows {
  final TVShowRepository repository;

  GetPopularTVShows(this.repository);

  Future<List<TVShow>> call() async {
    return await repository.getPopularTVShows();
  }
}
