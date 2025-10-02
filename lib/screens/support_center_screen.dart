import 'package:flutter/material.dart';

import '../utils/formatters.dart';

class SupportCenterScreen extends StatelessWidget {
  const SupportCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Destek Merkezi')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Soruların mı var? Destek ekibimiz hafta içi 09:00-18:00 arasında yardımcı olur.',
          ),
          const SizedBox(height: 20),
          SupportActionTile(
            icon: Icons.phone_in_talk_rounded,
            title: 'Telefon ile Ara',
            subtitle: '+90 392 000 00 00',
            onTap: () => launchExternalUrl(
              context,
              Uri(scheme: 'tel', path: '903920000000'),
            ),
          ),
          SupportActionTile(
            icon: Icons.chat_rounded,
            title: 'WhatsApp Destek',
            subtitle: '+90 533 852 12 86',
            onTap: () => openWhatsApp(
              context,
              '+90 533 852 12 86',
              'Merhaba, KKTC Caraba destek talebim var.',
            ),
          ),
          SupportActionTile(
            icon: Icons.mail_outline_rounded,
            title: 'E-posta Gönder',
            subtitle: 'destek@kktccaraba.com',
            onTap: () => launchExternalUrl(
              context,
              Uri(
                scheme: 'mailto',
                path: 'destek@kktccaraba.com',
                query: 'subject=KKTC Caraba Destek Talebi',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SupportActionTile extends StatelessWidget {
  const SupportActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: theme.colorScheme.primary),
        ),
        title: Text(title, style: theme.textTheme.titleMedium),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
