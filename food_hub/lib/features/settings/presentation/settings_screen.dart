import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../shared/presentation/app_header.dart';
import '../../shared/presentation/glass.dart';
import 'settings_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(settingsControllerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppHeader(title: l10n.t('settings'), icon: Icons.settings_rounded),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
        children: [
          GlassPanel(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: settings.languageCode,
                  decoration: InputDecoration(labelText: l10n.t('language')),
                  items: [
                    DropdownMenuItem(
                      value: 'uk',
                      child: Text(l10n.t('languageUkrainian')),
                    ),
                    DropdownMenuItem(
                      value: 'en',
                      child: Text(l10n.t('languageEnglish')),
                    ),
                    DropdownMenuItem(
                      value: 'pl',
                      child: Text(l10n.t('languagePolish')),
                    ),
                  ],
                  onChanged: (value) => ref
                      .read(settingsControllerProvider.notifier)
                      .setLanguage(value ?? 'uk'),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<ThemeMode>(
                  initialValue: settings.themeMode,
                  decoration: InputDecoration(labelText: l10n.t('theme')),
                  items: [
                    DropdownMenuItem(
                      value: ThemeMode.system,
                      child: Text(l10n.t('system')),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.light,
                      child: Text(l10n.t('light')),
                    ),
                    DropdownMenuItem(
                      value: ThemeMode.dark,
                      child: Text(l10n.t('dark')),
                    ),
                  ],
                  onChanged: (value) => ref
                      .read(settingsControllerProvider.notifier)
                      .setThemeMode(value ?? ThemeMode.system),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
