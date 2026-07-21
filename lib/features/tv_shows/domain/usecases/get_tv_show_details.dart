import '../entities/tv_show_detail.dart';
import '../repositories/tv_show_repository.dart';

class GetTVShowDetails {
  final TVShowRepository repository;

  GetTVShowDetails(this.repository);

  Future<TVShowDetail> call(int id) async {
    return await repository.getTVShowDetails(id);
  }
}
