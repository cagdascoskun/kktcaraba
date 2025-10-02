import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Ayarlar')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SwitchListTile.adaptive(
            title: const Text('Karanlık Tema'),
            subtitle: const Text('Geceleri göz dostu görünüm'),
            value: appState.themeMode == ThemeMode.dark,
            onChanged: (value) => appState.setThemeMode(
              value ? ThemeMode.dark : ThemeMode.light,
            ),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.language_rounded),
            title: const Text('Dil'),
            subtitle: const Text('Türkçe (KKTC)'),
            trailing: const Icon(Icons.keyboard_arrow_right_rounded),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.notifications_active_rounded),
            title: const Text('Bildirimler'),
            subtitle: const Text('Yeni ilanlar ve vitrin fırsatları için uyarı al'),
            trailing: const Icon(Icons.keyboard_arrow_right_rounded),
            onTap: () {},
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Gizlilik Politikası'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Kullanım Koşulları'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
