import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models.dart';
import '../../state/app_state.dart';
import '../../utils/formatters.dart';
import '../../widgets/listing_widgets.dart';
import '../listing_detail_screen.dart';
import '../promote_listing_screen.dart';

class VitrinScreen extends StatelessWidget {
  const VitrinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final List<Listing> featured =
        List<Listing>.from(appState.premiumListings)
          ..sort((a, b) => b.date.compareTo(a.date));

    final Map<ListingCategory, int> categoryCounts = <ListingCategory, int>{};
    for (final listing in featured) {
      categoryCounts.update(listing.category, (value) => value + 1,
          ifAbsent: () => 1);
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Vitrin', style: theme.textTheme.headlineLarge),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const PromoteListingScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.workspace_premium_rounded),
                    label: const Text('Vitrine çık'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                if (categoryCounts.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text('Vitrindeki kategoriler',
                      style: theme.textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categoryCounts.entries.map((entry) {
                      return Chip(
                        avatar: Icon(
                          categoryIcon(entry.key),
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        label: Text(
                          '${categoryLabel(entry.key)} (${entry.value})',
                        ),
                        backgroundColor:
                            theme.colorScheme.primary.withValues(alpha: .08),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (featured.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.workspace_premium_rounded,
                    size: 72,
                    color: theme.colorScheme.primary.withValues(alpha: .4),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Henüz vitrin ilanı yok',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'İlanını vitrine taşıyarak binlerce kullanıcıya ilk bakışta ulaşabilirsin. “Vitrine çık” butonuna dokunarak paketleri incele.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final listing = featured[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == featured.length - 1 ? 0 : 20,
                    ),
                    child: ListingCard(
                      listing: listing,
                      onTap: (selected) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ListingDetailScreen(
                              listing: selected,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
                childCount: featured.length,
              ),
            ),
          ),
      ],
    );
  }
}
