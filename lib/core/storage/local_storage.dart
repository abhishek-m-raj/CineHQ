import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  static const _apiKeyKey = 'tmdb_api_key';
  static const _favoritesKey = 'favorite_movie_ids';
  static const _tvFavoritesKey = 'favorite_tv_show_ids';
  static const _sessionIdKey = 'tmdb_session_id';
  static const _usernameKey = 'tmdb_username';
  static const _accountIdKey = 'tmdb_account_id';

  // Public fallback TMDB API Key so the app runs live out of the box without requiring manual input.
  final String defaultApiKey = 'hssn';

  String? getApiKey() {
    return _prefs.getString(_apiKeyKey);
  }

  Future<void> saveApiKey(String key) async {
    await _prefs.setString(_apiKeyKey, key);
  }

  Future<void> clearApiKey() async {
    await _prefs.remove(_apiKeyKey);
  }

  String? getSessionId() {
    return _prefs.getString(_sessionIdKey);
  }

  Future<void> saveSessionId(String sessionId) async {
    await _prefs.setString(_sessionIdKey, sessionId);
  }

  String? getUsername() {
    return _prefs.getString(_usernameKey);
  }

  Future<void> saveUsername(String username) async {
    await _prefs.setString(_usernameKey, username);
  }

  int? getAccountId() {
    return _prefs.getInt(_accountIdKey);
  }

  Future<void> saveAccountId(int accountId) async {
    await _prefs.setInt(_accountIdKey, accountId);
  }

  Future<void> clearSession() async {
    await _prefs.remove(_sessionIdKey);
    await _prefs.remove(_usernameKey);
    await _prefs.remove(_accountIdKey);
  }

  List<String> getFavorites() {
    return _prefs.getStringList(_favoritesKey) ?? [];
  }

  Future<void> saveFavorites(List<String> ids) async {
    await _prefs.setStringList(_favoritesKey, ids);
  }

  Future<void> addFavorite(String id) async {
    final favorites = getFavorites();
    if (!favorites.contains(id)) {
      favorites.add(id);
      await saveFavorites(favorites);
    }
  }

  Future<void> removeFavorite(String id) async {
    final favorites = getFavorites();
    if (favorites.contains(id)) {
      favorites.remove(id);
      await saveFavorites(favorites);
    }
  }

  bool isFavorite(String id) {
    return getFavorites().contains(id);
  }

  // --- TV Show Favorites ---

  List<String> getTvFavorites() {
    return _prefs.getStringList(_tvFavoritesKey) ?? [];
  }

  Future<void> saveTvFavorites(List<String> ids) async {
    await _prefs.setStringList(_tvFavoritesKey, ids);
  }

  Future<void> addTvFavorite(String id) async {
    final favorites = getTvFavorites();
    if (!favorites.contains(id)) {
      favorites.add(id);
      await saveTvFavorites(favorites);
    }
  }

  Future<void> removeTvFavorite(String id) async {
    final favorites = getTvFavorites();
    if (favorites.contains(id)) {
      favorites.remove(id);
      await saveTvFavorites(favorites);
    }
  }

  bool isTvFavorite(String id) {
    return getTvFavorites().contains(id);
  }
}
