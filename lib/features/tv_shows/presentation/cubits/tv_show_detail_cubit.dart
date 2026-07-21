import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/tv_show_detail.dart';
import '../../domain/usecases/get_tv_show_details.dart';

abstract class TVShowDetailState {
  const TVShowDetailState();
}

class TVShowDetailInitial extends TVShowDetailState {
  const TVShowDetailInitial();
}

class TVShowDetailLoading extends TVShowDetailState {
  const TVShowDetailLoading();
}

class TVShowDetailLoaded extends TVShowDetailState {
  final TVShowDetail tvShow;
  const TVShowDetailLoaded(this.tvShow);
}

class TVShowDetailError extends TVShowDetailState {
  final String message;
  const TVShowDetailError(this.message);
}

class TVShowDetailCubit extends Cubit<TVShowDetailState> {
  final GetTVShowDetails _getTVShowDetails;

  TVShowDetailCubit(this._getTVShowDetails) : super(const TVShowDetailInitial());

  Future<void> loadTVShowDetails(int id) async {
    emit(const TVShowDetailLoading());
    try {
      final tvShow = await _getTVShowDetails(id);
      emit(TVShowDetailLoaded(tvShow));
    } catch (e) {
      emit(TVShowDetailError(e.toString()));
    }
  }
}
