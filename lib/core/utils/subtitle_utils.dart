bool isNonEnglishLanguage(String text) {
  if (text.trim().isEmpty) return false;
  final lower = text.trim().toLowerCase();
  const nonEnglishCodes = [
    'spanish', 'español', 'es', 'spa',
    'french', 'français', 'fr', 'fre', 'fra',
    'german', 'deutsch', 'de', 'ger', 'deu',
    'italian', 'italiano', 'it', 'ita',
    'portuguese', 'português', 'pt', 'por',
    'russian', 'ru', 'rus',
    'japanese', 'ja', 'jpn',
    'korean', 'ko', 'kor',
    'chinese', 'zh', 'chi', 'zho',
    'arabic', 'ar', 'ara',
    'hindi', 'hi', 'hin',
    'turkish', 'tr', 'tur',
    'vietnamese', 'vi', 'vie',
    'indonesian', 'id', 'ind',
    'polish', 'pl', 'pol',
    'dutch', 'nl', 'dut', 'nld',
    'greek', 'el', 'gre', 'ell',
    'hungarian', 'hu', 'hun',
    'czech', 'cs', 'cze', 'ces',
    'swedish', 'sv', 'swe',
    'danish', 'da', 'dan',
    'finnish', 'fi', 'fin',
    'norwegian', 'no', 'nor',
    'thai', 'th', 'tha',
    'hebrew', 'he', 'heb',
    'romanian', 'ro', 'rum', 'ron',
    'ukrainian', 'uk', 'ukr'
  ];

  final words = lower.split(RegExp(r'[^a-z0-9]+'));
  for (final word in words) {
    if (nonEnglishCodes.contains(word)) {
      return true;
    }
  }
  return false;
}

bool isEnglishSubtitle(String? text, {String? url}) {
  if ((text == null || text.trim().isEmpty) && (url == null || url.trim().isEmpty)) {
    return false;
  }

  final labelLower = (text ?? '').trim().toLowerCase();
  final urlLower = (url ?? '').trim().toLowerCase();

  // Direct English check in label
  if (labelLower == 'en' ||
      labelLower == 'eng' ||
      labelLower == 'en-us' ||
      labelLower == 'en-gb' ||
      labelLower.startsWith('en-') ||
      labelLower.startsWith('en_')) {
    return true;
  }

  if (labelLower.contains('english')) {
    return true;
  }

  final words = labelLower.split(RegExp(r'[^a-z0-9]+'));
  if (words.contains('english') || words.contains('eng') || words.contains('en')) {
    return true;
  }

  // URL pattern check for English
  if (urlLower.isNotEmpty) {
    if (urlLower.contains('english') ||
        urlLower.contains('/en/') ||
        urlLower.contains('_en.') ||
        urlLower.contains('-en.') ||
        urlLower.contains('.en.') ||
        urlLower.contains('/eng/') ||
        urlLower.contains('_eng.') ||
        urlLower.contains('-eng.') ||
        urlLower.contains('.eng.')) {
      return true;
    }
  }

  // Generic labels (e.g. "subtitles", "default", "cc", "captions", "track 1")
  // that are NOT explicitly non-English are treated as English
  const genericLabels = [
    'subtitles', 'subtitle', 'default', 'cc', 'captions', 'caption',
    'unknown', 'track 1', 'track1', 'video subtitle', 'full'
  ];
  if (genericLabels.contains(labelLower) || labelLower.isEmpty) {
    if (!isNonEnglishLanguage(labelLower) && !isNonEnglishLanguage(urlLower)) {
      return true;
    }
  }

  return false;
}
