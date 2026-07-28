import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../video_player/presentation/cubits/continue_watching_cubit.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late bool _autoNextEnabled;
  late bool _onlyEnglishSubtitlesEnabled;
  final LocalStorage _localStorage = sl<LocalStorage>();

  @override
  void initState() {
    super.initState();
    _autoNextEnabled = _localStorage.isAutoNextEnabled();
    _onlyEnglishSubtitlesEnabled = _localStorage.isOnlyEnglishSubtitlesEnabled();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SETTINGS',
          style: theme.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.w900,
            fontSize: 22,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Playback Preferences Section (Auto Next & Subtitles)
            _buildSectionHeader(theme, 'PLAYBACK PREFERENCES'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AUTO NEXT EPISODE',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Automatically play the next episode when the current episode finishes.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Switch.adaptive(
                    value: _autoNextEnabled,
                    activeTrackColor: theme.colorScheme.primary,
                    onChanged: (value) async {
                      setState(() {
                        _autoNextEnabled = value;
                      });
                      await _localStorage.setAutoNextEnabled(value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ONLY LOAD ENGLISH SUBTITLES',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Only load and display English subtitles in the video player.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Switch.adaptive(
                    value: _onlyEnglishSubtitlesEnabled,
                    activeTrackColor: theme.colorScheme.primary,
                    onChanged: (value) async {
                      setState(() {
                        _onlyEnglishSubtitlesEnabled = value;
                      });
                      await _localStorage.setOnlyEnglishSubtitlesEnabled(value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Developer tools section
            _buildSectionHeader(theme, 'DEVELOPER TOOLS'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SYSTEM LOGS',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Inspect network requests and state transitions.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.secondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      context.push('/logs');
                    },
                    icon: Icon(
                      Icons.bug_report_outlined,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    label: Text(
                      'VIEW LOGS',
                      style: theme.textTheme.labelLarge?.copyWith(fontSize: 11),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                      side: BorderSide(color: theme.colorScheme.primary),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Continue Watching Section
            _buildSectionHeader(theme, 'WATCH HISTORY & STORAGE'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(4),
              ),
              child: BlocBuilder<ContinueWatchingCubit, ContinueWatchingState>(
                builder: (context, state) {
                  final itemCount = state.items.length;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CONTINUE WATCHING HISTORY',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              itemCount > 0
                                  ? '$itemCount saved item${itemCount == 1 ? '' : 's'} in watch progress'
                                  : 'No watch progress saved currently.',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: itemCount > 0
                            ? () => _showClearHistoryDialog(context, theme)
                            : null,
                        icon: const Icon(
                          Icons.delete_outline_sharp,
                          size: 16,
                          color: Colors.redAccent,
                        ),
                        label: Text(
                          'CLEAR HISTORY',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontSize: 11,
                            color: itemCount > 0 ? Colors.redAccent : theme.colorScheme.outline,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                          side: BorderSide(
                            color: itemCount > 0 ? Colors.redAccent : theme.colorScheme.outline,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        title: const Text('Clear Watch History?'),
        content: const Text(
          'This will remove all saved progress for movies and TV shows from Continue Watching.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              context.read<ContinueWatchingCubit>().clearAll();
              Navigator.of(dialogContext).pop();
            },
            child: const Text('CLEAR ALL'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String text) {
    return Text(
      text,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w800,
        fontSize: 12,
        letterSpacing: 1.5,
        color: theme.colorScheme.secondary,
      ),
    );
  }
}
