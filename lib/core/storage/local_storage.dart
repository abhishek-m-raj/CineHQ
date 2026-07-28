import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  static const _apiKeyKey = 'tmdb_api_key';
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

  static const _continueWatchingKey = 'continue_watching_list';
  static const _autoNextKey = 'auto_next_episode';
  static const _onlyEnglishSubtitlesKey = 'only_english_subtitles';
  static const _defaultResolutionKey = 'default_resolution';

  List<String> getContinueWatchingRawList() {
    return _prefs.getStringList(_continueWatchingKey) ?? [];
  }

  Future<void> saveContinueWatchingRawList(List<String> rawList) async {
    await _prefs.setStringList(_continueWatchingKey, rawList);
  }

  Future<void> clearContinueWatchingHistory() async {
    await _prefs.remove(_continueWatchingKey);
  }

  bool isAutoNextEnabled() {
    return _prefs.getBool(_autoNextKey) ?? true;
  }

  Future<void> setAutoNextEnabled(bool enabled) async {
    await _prefs.setBool(_autoNextKey, enabled);
  }

  bool isOnlyEnglishSubtitlesEnabled() {
    return _prefs.getBool(_onlyEnglishSubtitlesKey) ?? true;
  }

  Future<void> setOnlyEnglishSubtitlesEnabled(bool enabled) async {
    await _prefs.setBool(_onlyEnglishSubtitlesKey, enabled);
  }

  String getDefaultResolution() {
    return _prefs.getString(_defaultResolutionKey) ?? '1080p';
  }

  Future<void> setDefaultResolution(String resolution) async {
    await _prefs.setString(_defaultResolutionKey, resolution);
  }

  static const _lastInstalledVersionKey = 'last_installed_version';

  String? getLastInstalledVersion() {
    return _prefs.getString(_lastInstalledVersionKey);
  }

  Future<void> saveLastInstalledVersion(String version) async {
    await _prefs.setString(_lastInstalledVersionKey, version);
  }

  Future<void> clearAllData() async {
    await _prefs.clear();
  }
}


