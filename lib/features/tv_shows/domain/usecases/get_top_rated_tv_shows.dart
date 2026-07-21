import '../entities/tv_show.dart';
import '../repositories/tv_show_repository.dart';

class GetTopRatedTVShows {
  final TVShowRepository repository;

  GetTopRatedTVShows(this.repository);

  Future<List<TVShow>> call() async {
    return await repository.getTopRatedTVShows();
  }
}
