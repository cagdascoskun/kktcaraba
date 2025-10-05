import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models.dart';
import '../../state/app_state.dart';
import '../../utils/formatters.dart';
import '../listing_detail_screen.dart';
import '../promote_listing_screen.dart';

class VitrinScreen extends StatelessWidget {
  const VitrinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final now = DateTime.now();
    final List<Listing> featured = appState.premiumListings
        .where((listing) =>
            listing.premiumExpiresAt != null &&
            listing.premiumExpiresAt!.isAfter(now))
        .toList()
      ..sort((a, b) {
        final aDate = a.premiumExpiresAt ?? a.date;
        final bDate = b.premiumExpiresAt ?? b.date;
        return bDate.compareTo(aDate);
      });

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
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final listing = featured[index];
                  return _VitrinGridCard(listing: listing);
                },
                childCount: featured.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.68,
              ),
            ),
          ),
      ],
    );
  }
}

class _VitrinGridCard extends StatelessWidget {
  const _VitrinGridCard({required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ListingDetailScreen(listing: listing),
        ),
      ),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 4 / 3,
              child: listing.images.isNotEmpty
                  ? Image.network(
                      listing.images.first,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: theme.colorScheme.primary.withValues(alpha: .08),
                      child: Icon(Icons.image_outlined,
                          size: 42, color: theme.colorScheme.primary),
                  ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      formatPrice(listing.price, listing.currency),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium!
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                          theme.textTheme.bodySmall!.copyWith(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
