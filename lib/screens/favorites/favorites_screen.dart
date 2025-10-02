import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/listing_widgets.dart';
import '../listing_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final favorites = appState.favoriteListings;

    return Scaffold(
      appBar: AppBar(title: const Text('Favorilerim')),
      body: favorites.isEmpty
          ? const EmptyState(
              title: 'Henüz favoriniz yok',
              subtitle:
                  'Beğendiğiniz ilanları kalp ikonuna dokunarak favorilerinize ekleyebilirsiniz.',
              icon: Icons.favorite_border_rounded,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: favorites.length,
              itemBuilder: (_, index) {
                final listing = favorites[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ListingTile(
                    listing: listing,
                    onTap: (selected) => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ListingDetailScreen(listing: selected),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
