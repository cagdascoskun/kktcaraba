import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../data/vehicle_categories.dart';
import '../state/app_state.dart';
import '../utils/formatters.dart';

typedef ListingTapCallback = void Function(Listing listing);

class ListingCard extends StatelessWidget {
  const ListingCard({
    super.key,
    required this.listing,
    this.onTap,
  });

  final Listing listing;
  final ListingTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap != null ? () => onTap!(listing) : null,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      listing.images.first,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.black12,
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
                    ),
                  ),
                  if (listing.isPremium)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                            SizedBox(width: 4),
                            Text('Premium', style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: ListingFavoriteButton(listingId: listing.id),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 17),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatPrice(listing.price, listing.currency),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: .8),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          listing.location,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ListingTile extends StatelessWidget {
  const ListingTile({
    super.key,
    required this.listing,
    this.onTap,
  });

  final Listing listing;
  final ListingTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap != null ? () => onTap!(listing) : null,
      child: Card(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
              child: Image.network(
                listing.images.first,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            listing.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(width: 8),
                        ListingFavoriteButton(
                          listingId: listing.id,
                          compact: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatPrice(listing.price, listing.currency),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: .7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          listing.location,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Colors.black54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      timeAgo(listing.date),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.black45),
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

class ListingFavoriteButton extends StatelessWidget {
  const ListingFavoriteButton({
    super.key,
    required this.listingId,
    this.compact = false,
  });

  final String listingId;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(compact ? 12 : 14);
    return Consumer<AppState>(
      builder: (context, appState, _) {
        final bool isFavorite = appState.isFavorite(listingId);
        final Color iconColor = isFavorite
            ? Theme.of(context).colorScheme.secondary
            : Colors.white;
        final Color backgroundColor = isFavorite
            ? Colors.white
            : Colors.black.withValues(alpha: .3);

        return GestureDetector(
          onTap: () async => appState.toggleFavorite(listingId),
          child: Container(
            padding: EdgeInsets.all(compact ? 6 : 10),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: borderRadius,
              border: isFavorite
                  ? Border.all(
                      color: Theme.of(context).colorScheme.secondary,
                      width: 1,
                    )
                  : null,
            ),
            child: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: iconColor,
              size: compact ? 20 : 22,
            ),
          ),
        );
      },
    );
  }
}

class ListingPhotoCarousel extends StatefulWidget {
  const ListingPhotoCarousel({super.key, required this.images});

  final List<String> images;

  @override
  State<ListingPhotoCarousel> createState() => _ListingPhotoCarouselState();
}

class _ListingPhotoCarouselState extends State<ListingPhotoCarousel> {
  int _activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        children: [
          PageView.builder(
            onPageChanged: (index) => setState(() => _activeIndex = index),
            itemCount: widget.images.length,
            itemBuilder: (_, index) => Image.network(
              widget.images[index],
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.black12,
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.images.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _activeIndex == index ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _activeIndex == index
                        ? Colors.white
                        : Colors.white.withValues(alpha: .4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ListingFeatures extends StatelessWidget {
  const ListingFeatures({super.key, required this.listing});

  final Listing listing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final features = <Widget>[];

    if (listing.vehicleSubcategory != null) {
      final info =
          vehicleCategoryInfoFor(listing.vehicleSubcategory!)?.icon ??
              Icons.directions_car_rounded;
      features.add(
        FeatureChip(
          label: vehicleSubcategoryLabel(listing.vehicleSubcategory!),
          icon: info,
        ),
      );
    }

    if (listing.brand != null && listing.brand!.trim().isNotEmpty) {
      features.add(
        FeatureChip(label: listing.brand!, icon: Icons.directions_car_rounded),
      );
    }
    if (listing.model != null && listing.model!.trim().isNotEmpty) {
      features.add(
        FeatureChip(label: listing.model!, icon: Icons.directions_car_outlined),
      );
    }
    if (listing.engineType != null && listing.engineType!.trim().isNotEmpty) {
      features.add(
        FeatureChip(label: listing.engineType!, icon: Icons.settings_input_component_rounded),
      );
    }
    if (listing.fuelType != null) {
      features.add(
        FeatureChip(
          label: fuelTypeLabel(listing.fuelType!),
          icon: Icons.local_gas_station_rounded,
        ),
      );
    }
    if (listing.transmission != null) {
      features.add(
        FeatureChip(
          label: transmissionLabel(listing.transmission!),
          icon: Icons.settings_rounded,
        ),
      );
    }
    if (listing.condition != null) {
      features.add(
        FeatureChip(
          label: vehicleConditionLabel(listing.condition!),
          icon: Icons.verified_rounded,
        ),
      );
    }
    if (listing.drivetrain != null) {
      features.add(
        FeatureChip(
          label: drivetrainLabel(listing.drivetrain!),
          icon: Icons.troubleshoot_rounded,
        ),
      );
    }
    if (listing.bodyType != null && listing.bodyType!.trim().isNotEmpty) {
      features.add(
        FeatureChip(
          label: listing.bodyType!,
          icon: Icons.directions_car_filled_outlined,
        ),
      );
    }
    if (listing.power != null && listing.power! > 0) {
      features.add(
        FeatureChip(
          label: '${listing.power} hp',
          icon: Icons.flash_on_rounded,
        ),
      );
    }

    if (listing.rooms != null) {
      features.add(
        FeatureChip(label: '${listing.rooms} Oda', icon: Icons.bed_rounded),
      );
    }
    if (listing.size != null) {
      features.add(
        FeatureChip(label: '${listing.size} m²', icon: Icons.square_foot_rounded),
      );
    }
    if (listing.year != null) {
      features.add(
        FeatureChip(label: 'Model ${listing.year}', icon: Icons.calendar_today_rounded),
      );
    }
    if (listing.mileage != null) {
      features.add(
        FeatureChip(label: '${listing.mileage} km', icon: Icons.speed_rounded),
      );
    }

    if (features.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Öne Çıkan Özellikler', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: features,
        ),
      ],
    );
  }
}

class FeatureChip extends StatelessWidget {
  const FeatureChip({super.key, required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Theme.of(context).colorScheme.primary),
          ),
        ],
      ),
    );
  }
}

class ConsumerListings extends StatelessWidget {
  const ConsumerListings({super.key, required this.excludeId, required this.onItemTap});

  final String excludeId;
  final ListingTapCallback onItemTap;

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final listings = appState.listings
        .where((listing) => listing.id != excludeId)
        .take(3)
        .toList();

    return Column(
      children: listings
          .map(
            (listing) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ListingTile(
                listing: listing,
                onTap: onItemTap,
              ),
            ),
          )
          .toList(),
    );
  }
}
