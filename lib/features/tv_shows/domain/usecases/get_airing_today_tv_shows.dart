import '../entities/tv_show.dart';
import '../repositories/tv_show_repository.dart';

class GetAiringTodayTVShows {
  final TVShowRepository repository;

  GetAiringTodayTVShows(this.repository);

  Future<List<TVShow>> call() async {
    return await repository.getAiringTodayTVShows();
  }
}
