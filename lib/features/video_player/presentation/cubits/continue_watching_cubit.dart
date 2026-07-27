import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/storage/local_storage.dart';
import '../../domain/entities/continue_watching_item.dart';

class ContinueWatchingState {
  final List<ContinueWatchingItem> items;
  final bool isLoading;

  const ContinueWatchingState({
    this.items = const [],
    this.isLoading = false,
  });

  ContinueWatchingState copyWith({
    List<ContinueWatchingItem>? items,
    bool? isLoading,
  }) {
    return ContinueWatchingState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ContinueWatchingCubit extends Cubit<ContinueWatchingState> {
  final LocalStorage _localStorage;

  ContinueWatchingCubit(this._localStorage) : super(const ContinueWatchingState());

  Future<void> loadItems() async {
    emit(state.copyWith(isLoading: true));
    try {
      final rawList = _localStorage.getContinueWatchingRawList();
      final List<ContinueWatchingItem> loadedItems = [];

      for (final jsonStr in rawList) {
        try {
          final Map<String, dynamic> jsonMap = jsonDecode(jsonStr);
          loadedItems.add(ContinueWatchingItem.fromJson(jsonMap));
        } catch (_) {
          // Ignore corrupted items
        }
      }

      // Sort by last updated descending
      loadedItems.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));

      emit(state.copyWith(items: loadedItems, isLoading: false));
    } catch (_) {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> saveProgress({
    required int tmdbId,
    required String mediaType,
    required String title,
    required String releaseDate,
    String? posterPath,
    String? backdropPath,
    int? seasonNumber,
    int? episodeNumber,
    String? episodeTitle,
    required int positionInSeconds,
    required int durationInSeconds,
  }) async {
    if (durationInSeconds <= 0 || positionInSeconds < 3) {
      return;
    }

    final newItem = ContinueWatchingItem(
      tmdbId: tmdbId,
      mediaType: mediaType,
      title: title,
      releaseDate: releaseDate,
      posterPath: posterPath,
      backdropPath: backdropPath,
      seasonNumber: seasonNumber,
      episodeNumber: episodeNumber,
      episodeTitle: episodeTitle,
      positionInSeconds: positionInSeconds,
      durationInSeconds: durationInSeconds,
      lastUpdated: DateTime.now(),
    );

    List<ContinueWatchingItem> updatedList = List.from(state.items);

    if (newItem.isCompleted) {
      // Remove completed item from continue watching list
      updatedList.removeWhere((item) => item.showKey == newItem.showKey);
    } else {
      // Update existing item for this show/movie or insert at start
      final existingIndex = updatedList.indexWhere((item) => item.showKey == newItem.showKey);
      if (existingIndex >= 0) {
        // Keep existing poster/backdrop if new one is null
        final existing = updatedList[existingIndex];
        final mergedItem = newItem.copyWith(
          posterPath: newItem.posterPath ?? existing.posterPath,
          backdropPath: newItem.backdropPath ?? existing.backdropPath,
        );
        updatedList.removeAt(existingIndex);
        updatedList.insert(0, mergedItem);
      } else {
        updatedList.insert(0, newItem);
      }
    }

    // Sort by last updated descending
    updatedList.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));

    // Limit to 50 entries
    if (updatedList.length > 50) {
      updatedList = updatedList.sublist(0, 50);
    }

    emit(state.copyWith(items: updatedList));
    await _persistItems(updatedList);
  }

  Future<void> removeItem(String key) async {
    final updatedList = state.items.where((item) => item.key != key && item.showKey != key).toList();
    emit(state.copyWith(items: updatedList));
    await _persistItems(updatedList);
  }

  Future<void> clearAll() async {
    emit(state.copyWith(items: []));
    await _localStorage.clearContinueWatchingHistory();
  }

  ContinueWatchingItem? getItemForShow(int tmdbId, String mediaType) {
    final showKey = '${mediaType}_$tmdbId';
    try {
      return state.items.firstWhere((item) => item.showKey == showKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> _persistItems(List<ContinueWatchingItem> items) async {
    final rawList = items.map((item) => jsonEncode(item.toJson())).toList();
    await _localStorage.saveContinueWatchingRawList(rawList);
  }
}
