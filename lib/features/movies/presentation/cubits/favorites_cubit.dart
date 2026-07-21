import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/local_storage.dart';

class FavoritesCubit extends Cubit<List<int>> {
  final LocalStorage _localStorage;

  FavoritesCubit(this._localStorage) : super([]) {
    loadFavorites();
  }

  void loadFavorites() {
    try {
      final ids = _localStorage.getFavorites();
      emit(ids.map((id) => int.tryParse(id)).whereType<int>().toList());
    } catch (_) {
      emit([]);
    }
  }

  Future<void> toggleFavorite(int id) async {
    final idStr = id.toString();
    final updated = List<int>.from(state);
    if (updated.contains(id)) {
      await _localStorage.removeFavorite(idStr);
      updated.remove(id);
    } else {
      await _localStorage.addFavorite(idStr);
      updated.add(id);
    }
    emit(updated);
  }

  bool isFavorite(int id) {
    return state.contains(id);
  }
}
