import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFEBFFFD), Colors.white],
          ),
        ),
        child: ListView(
        children: [
          const SizedBox(height: 8),

          // Display section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Affichage',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),

          SwitchListTile(
            title: const Text('Afficher la référence'),
            subtitle: const Text('Afficher les références hadith/Coran'),
            value: settings.showReference,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setShowReference(value);
            },
            secondary: const Icon(Icons.book_outlined),
          ),

          SwitchListTile(
            title: const Text('Afficher la traduction'),
            subtitle: const Text('Afficher la traduction française'),
            value: settings.showTranslation,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setShowTranslation(value);
            },
            secondary: const Icon(Icons.translate),
          ),

          const Divider(indent: 16, endIndent: 16),

          // Behavior section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Comportement',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),

          SwitchListTile(
            title: const Text('Garder l\'écran allumé'),
            subtitle: const Text('Empêcher l\'écran de s\'éteindre'),
            value: settings.keepScreenAwake,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setKeepScreenAwake(value);
            },
            secondary: const Icon(Icons.light_mode_outlined),
          ),

          const Divider(indent: 16, endIndent: 16),

          // About section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'À propos',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),

          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              final version = snapshot.hasData
                  ? '${snapshot.data!.version} (${snapshot.data!.buildNumber})'
                  : '...';
              return ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Version de l\'application'),
                subtitle: Text(version),
              );
            },
          ),

          const SizedBox(height: 32),
        ],
        ),
      ),
    );
  }
}
