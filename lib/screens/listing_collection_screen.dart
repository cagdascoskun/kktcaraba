import 'package:flutter/material.dart';

import '../data/models.dart';
import '../widgets/common_widgets.dart';
import '../widgets/listing_widgets.dart';
import 'listing_detail_screen.dart';

class ListingCollectionScreen extends StatelessWidget {
  const ListingCollectionScreen({
    super.key,
    required this.title,
    required this.listings,
  });

  final String title;
  final List<Listing> listings;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: listings.isEmpty
            ? const EmptyState(
                title: 'Henüz içerik yok',
                subtitle:
                    'Bu bölümde gösterilecek ilan bulunamadı. Yeni ilanlar eklendiğinde burada göreceksin.',
                icon: Icons.inbox_outlined,
              )
            : ListView.separated(
                itemCount: listings.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, index) {
                  final listing = listings[index];
                  return ListingTile(
                    listing: listing,
                    showStatusBadge: true,
                    onTap: (value) => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ListingDetailScreen(listing: value),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
