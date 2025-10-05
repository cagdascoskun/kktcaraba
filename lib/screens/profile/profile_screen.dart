import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models.dart';
import '../../state/app_state.dart';
import '../../utils/formatters.dart';
import '../../widgets/common_widgets.dart';
import '../create_listing_screen.dart';
import '../listing_collection_screen.dart';
import '../promote_listing_screen.dart';
import '../settings_screen.dart';
import '../support_center_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final bool isGuest = appState.currentUser == null;
    final AppUser user =
        appState.currentUser ??
        const AppUser(
          id: 'guest',
          name: 'Misafir Kullanıcı',
          email: 'guest@kktccaraba.com',
          phone: '',
          company: '',
          bio:
              'Hesabınızla giriş yaparak portföyünüzü yönetebilir, ilanlarınızın performansını takip edebilirsiniz.',
          avatarUrl: '',
        );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF004C6D), Color(0xFF00ADEF)],
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            height: 88,
                            width: 88,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(color: Colors.white, width: 3),
                              color: Colors.white.withValues(alpha: .12),
                              image: (!isGuest && user.avatarUrl.trim().isNotEmpty)
                                  ? DecorationImage(
                                      image: NetworkImage(user.avatarUrl),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: (isGuest || user.avatarUrl.trim().isEmpty)
                                ? const Icon(
                                    Icons.person_outline_rounded,
                                    color: Colors.white,
                                    size: 44,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                user.name,
                                style: theme.textTheme.headlineSmall!.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Bireysel',
                                style: theme.textTheme.bodyMedium!.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                              if (!isGuest && user.phone.trim().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    formatTurkishPhone(user.phone),
                                    style: theme.textTheme.bodyMedium!
                                        .copyWith(color: Colors.white70),
                                  ),
                                ),
                              if (user.company.trim().isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Text(
                                    user.company,
                                    style: theme.textTheme.bodyMedium!.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Text('Biyografi', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  user.bio.trim().isNotEmpty
                      ? user.bio
                      : 'Profilini tamamlayarak kendini ve uzmanlık alanını tanıtabilirsin.',
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                if (!isGuest) ...[
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const EditProfileScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.edit_rounded),
                    label: const Text('Profili Düzenle'),
                  ),
                ],
                const SizedBox(height: 24),
                Text('Hızlı İşlemler', style: theme.textTheme.titleMedium),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    QuickActionButton(
                      icon: Icons.add_business_rounded,
                      label: 'Yeni İlan Ver',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CreateListingScreen(),
                        ),
                      ),
                    ),
                    QuickActionButton(
                      icon: Icons.support_agent_rounded,
                      label: 'Destek Talebi',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SupportCenterScreen(),
                        ),
                      ),
                    ),
                    QuickActionButton(
                      icon: Icons.campaign_rounded,
                      label: 'İlanı Öne Çıkar',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const PromoteListingScreen(),
                        ),
                      ),
                    ),
                    QuickActionButton(
                      icon: Icons.inventory_2_rounded,
                      label: 'İlanlarım',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ListingCollectionScreen(
                            title: 'İlanlarım',
                            listings: appState.myListings(),
                          ),
                        ),
                      ),
                    ),
                    QuickActionButton(
                      icon: Icons.settings_rounded,
                      label: 'Ayarlar',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary.withValues(
                          alpha: .12,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.logout_rounded,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    title: Text(
                      'Çıkış Yap',
                      style: theme.textTheme.titleMedium!.copyWith(
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    subtitle: const Text('Güvenli çıkış yapmak için dokun.'),
                    onTap: () => appState.signOut(),
                  ),
                ),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}
