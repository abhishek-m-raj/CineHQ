import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:locale_names/locale_names.dart';
import 'package:video/other/responsive.dart';
import 'package:video/utils/language.dart';
import 'package:video/video.dart';
import 'package:video/widgets/btns/settings/pages/settings_page.dart';

class SettingsSubtitlePage extends StatefulWidget {
  final Controller controller;
  final VidStyle style;
  final VoidCallback onBack;

  const SettingsSubtitlePage({super.key, required this.controller, required this.style, required this.onBack});

  @override
  State<SettingsSubtitlePage> createState() => _SettingsSubtitlePageState();
}

class _SettingsSubtitlePageState extends State<SettingsSubtitlePage> {
  bool _isSearching = false;
  List<Map<String, dynamic>> _allResults = [];
  bool _isLoading = false;
  String? _error;
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  String get _defaultQuery {
    final title = widget.controller.datasource?.title ?? '';
    final sub = widget.controller.datasource?.subtitle ?? '';
    if (title.isEmpty) return '';
    if (sub.isNotEmpty) return '$title $sub';
    return title;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _enterSearch() {
    _searchController.text = _defaultQuery;
    setState(() => _isSearching = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _searchFocusNode.requestFocus();
    });
    if (_searchController.text.isNotEmpty) _search();
  }

  void _exitSearch() {
    setState(() {
      _isSearching = false;
      _allResults = [];
      _error = null;
      _searchController.clear();
    });
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty || widget.controller.onSearchSubtitles == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await widget.controller.onSearchSubtitles!(query);
      if (mounted) {
        setState(() {
          _allResults = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _downloadAndApply(Map<String, dynamic> sub) async {
    final id = sub['id']?.toString() ?? '';
    if (id.isEmpty || widget.controller.onDownloadSubtitle == null) return;

    try {
      final content = await widget.controller.onDownloadSubtitle!(id);
      if (content != null && mounted) {
        final track = SubtitleTrack.data(
          content,
          title: sub['display'] ?? sub['release'] ?? 'Subtitle',
          language: sub['language'] ?? '',
        );
        await widget.controller.setSubtitleTrack(track);
        if (mounted) _exitSearch();
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (_isSearching) return _buildSearchView();
    return _buildTrackList();
  }

  Widget _buildTrackList() {
    final hasSearch = widget.controller.onSearchSubtitles != null;
    return StreamBuilder(
      stream: widget.controller.player.stream.tracks,
      builder: (context, snapshot) {
        final List<SubtitleTrack> tracks = snapshot.data?.subtitle ?? widget.controller.player.state.tracks.subtitle;
        final itemCount = tracks.length + (hasSearch ? 1 : 0);
        return SettingsBtnPage(
          onTap: () => widget.onBack(),
          itemCount: itemCount,
          builder: (index) {
            if (hasSearch && index == tracks.length) {
              return HqListTile(
                titleWidget: Row(
                  children: [
                    Icon(Icons.search, color: widget.style.settingTileColor, size: fontSize() * 1.2),
                    SizedBox(width: HqSpacing.s3),
                    Text(
                      'Search Subtitles...',
                      style: TextStyle(fontSize: fontSize(), color: widget.style.settingTileColor),
                    ),
                  ],
                ),
                onPress: _enterSearch,
              );
            }
            final SubtitleTrack item = tracks[index];
            final bool isSelected = (item == widget.controller.player.state.track.subtitle);
            String title;
            if (item.language != null && item.language!.validateLangCode) {
              final langKey = item.language!.iso6391LangKey;
              String? displayLang;
              if (langKey != null) {
                try {
                  displayLang = Locale.fromSubtags(languageCode: langKey).defaultDisplayLanguage;
                } catch (_) {}
              }
              title = displayLang ?? item.title ?? item.id;
            } else {
              title = item.title ?? item.id;
            }
            return HqListTile(
              titleWidget: Text(
                title,
                style: TextStyle(
                  fontSize: fontSize(),
                  color: isSelected ? widget.style.settingTileColor : Colors.white,
                ),
              ),
              onPress: () => widget.controller.setSubtitleTrack(item),
            );
          },
        );
      },
    );
  }

  Widget _buildSearchView() {
    return Column(
      children: [
        HqListTile(leading: const Icon(Icons.arrow_back), title: '', onPress: _exitSearch),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: HqSpacing.s2),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search subtitles...',
              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
              prefixIcon: const Icon(Icons.search, color: Colors.white54, size: 20),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: HqSpacing.s3, vertical: HqSpacing.s2),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.08),
              border: OutlineInputBorder(
                borderRadius: HqBorderRadius.br2.asRadius,
                borderSide: BorderSide.none,
              ),
            ),
            inputFormatters: [LengthLimitingTextInputFormatter(100)],
            onSubmitted: (_) => _search(),
          ),
        ),
        SizedBox(height: HqSpacing.s2),
        Expanded(child: _buildSearchContent()),
      ],
    );
  }

  Widget _buildSearchContent() {
    if (_isLoading) {
      return const Center(child: HqLoadingIndicator(loading: true));
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 28),
            SizedBox(height: HqSpacing.s2),
            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 12)),
            SizedBox(height: HqSpacing.s3),
            HqListTile(
              titleWidget: const Text('Retry', style: TextStyle(color: Colors.white70)),
              onPress: _search,
            ),
          ],
        ),
      );
    }

    if (_allResults.isEmpty && !_isLoading) {
      return const Center(
        child: Text('No results', style: TextStyle(color: Colors.white38, fontSize: 13)),
      );
    }

    return ListView.builder(
      itemCount: _allResults.length,
      itemBuilder: (context, index) {
        final sub = _allResults[index];
        final lang = (sub['language'] ?? '').toString().toUpperCase();
        final format = (sub['format'] ?? '').toString().toUpperCase();
        final downloads = sub['downloadCount'] ?? 0;
        final trusted = sub['isTrusted'] == true;
        final flagUrl = sub['flagUrl'] as String?;

        return HqListTile(
          leading: flagUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Image.network(
                    flagUrl,
                    width: 24,
                    height: 16,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      width: 24,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Center(
                        child: Text(lang, style: const TextStyle(color: Colors.white38, fontSize: 7)),
                      ),
                    ),
                  ),
                )
              : null,
          titleWidget: Text(
            (sub['release'] ?? sub['display'] ?? '').toString(),
            style: const TextStyle(color: Colors.white, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitleWidget: Text(
            '${sub['display'] ?? ''}  •  $format  •  $downloads downloads',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
          ),
          trailing: trusted
              ? const Icon(Icons.verified, color: Colors.greenAccent, size: 14)
              : null,
          onPress: () => _downloadAndApply(sub),
        );
      },
    );
  }
}
