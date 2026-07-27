import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../video_player/presentation/cubits/continue_watching_cubit.dart';



class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeCubit = sl<ThemeCubit>();
    
    final activeKey = dotenv.env['TMDB_API_KEY'] ?? '';
    final isDemoMode = activeKey.isEmpty;

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
            // Theme Mode Section
            _buildSectionHeader(theme, 'AESTHETICS'),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'THEME',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      BlocBuilder<ThemeCubit, ThemeMode>(
                        bloc: themeCubit,
                        builder: (context, mode) {
                          return Text(
                            mode == ThemeMode.dark ? 'Monochrome Dark' : 'Monochrome Light',
                            style: theme.textTheme.bodyMedium,
                          );
                        },
                      ),
                    ],
                  ),
                  BlocBuilder<ThemeCubit, ThemeMode>(
                    bloc: themeCubit,
                    builder: (context, mode) {
                      return OutlinedButton.icon(
                        onPressed: () {
                          themeCubit.toggleTheme();
                        },
                        icon: Icon(
                          mode == ThemeMode.dark ? Icons.light_mode_sharp : Icons.dark_mode_sharp,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        label: Text(
                          mode == ThemeMode.dark ? 'LIGHT' : 'DARK',
                          style: theme.textTheme.labelLarge?.copyWith(fontSize: 11),
                        ),
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                          side: BorderSide(color: theme.colorScheme.primary),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // API Configuration Section
            _buildSectionHeader(theme, 'TMDB DATABASE CONNECTION'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'CONNECTION STATUS',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDemoMode ? Colors.transparent : theme.colorScheme.primary,
                          border: Border.all(color: theme.colorScheme.primary),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          isDemoMode ? 'OFFLINE DEMO' : 'LIVE (.ENV)',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isDemoMode ? theme.colorScheme.primary : theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isDemoMode
                        ? 'Access live catalog data, movie synopses, and searches by configuring a TMDB API Key in your root .env file.'
                        : 'CineHQ is currently using a live TMDB API key supplied via the root .env file.',
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                  ),
                  if (!isDemoMode) ...[
                    const SizedBox(height: 20),
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'ACTIVE TMDB API KEY',
                        labelStyle: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: theme.colorScheme.primary,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: theme.colorScheme.outline),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      child: Text(
                        // Mask the key for security, leaving first 4 and last 4 characters visible
                        activeKey.length > 8
                            ? '${activeKey.substring(0, 4)}••••••••••••••••••••${activeKey.substring(activeKey.length - 4)}'
                            : activeKey,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Instruction Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: theme.colorScheme.outline, style: BorderStyle.solid),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ENVIRONMENT CONFIGURATION',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'To update the API key, configure it in your root .env file and restart the application:',
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 12, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      border: Border.all(color: theme.colorScheme.outline),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'TMDB_API_KEY=your_api_key_here',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This ensures your API credentials remain private and are not hardcoded or committed to version control.',
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11, color: theme.colorScheme.secondary),
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
