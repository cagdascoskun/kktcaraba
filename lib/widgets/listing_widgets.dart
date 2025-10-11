import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../data/vehicle_categories.dart';
import '../state/app_state.dart';
import '../utils/formatters.dart';

typedef ListingTapCallback = void Function(Listing listing);

const Duration _newBadgeThreshold = Duration(hours: 48);

List<String> _primaryListingAttributes(Listing listing) {
  final attributes = <String>[];

  if (listing.subcategoryDetail != null && listing.subcategoryDetail!.trim().isNotEmpty) {
    attributes.add(listing.subcategoryDetail!.trim());
  } else if (listing.subcategory != null && listing.subcategory!.trim().isNotEmpty) {
    attributes.add(listing.subcategory!.trim());
  }

  switch (listing.category) {
    case ListingCategory.konut:
    case ListingCategory.emlak:
      if (listing.rooms != null && listing.rooms! > 0) {
        attributes.add('${listing.rooms} oda');
      }
      if (listing.size != null && listing.size! > 0) {
        attributes.add('${_formatThousands(listing.size!)} m²');
      }
      break;
    case ListingCategory.arac:
      if (listing.year != null) {
        attributes.add('${listing.year}');
      }
      if (listing.mileage != null && listing.mileage! > 0) {
        attributes.add('${_formatThousands(listing.mileage!)} km');
      }
      if (listing.fuelType != null) {
        attributes.add(fuelTypeLabel(listing.fuelType!));
      }
      if (listing.transmission != null) {
        attributes.add(transmissionLabel(listing.transmission!));
      }
      break;
    default:
      if (listing.size != null && listing.size! > 0) {
        attributes.add('${_formatThousands(listing.size!)} m²');
      }
      break;
  }

  attributes.add(listingTypeLabel(listing.type));

  return attributes.where((element) => element.trim().isNotEmpty).toList();
}

String _formatThousands(num value) {
  final int normalized = value.isFinite ? value.round() : 0;
  final text = normalized.toString();
  return text.replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
}

class _InfoBadge extends StatelessWidget {
  const _InfoBadge({
    required this.label,
    this.icon,
    this.backgroundColor = const Color(0xF2FFFFFF),
    this.textColor = Colors.black87,
  });

  final String label;
  final IconData? icon;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context)
        .textTheme
        .labelSmall
        ?.copyWith(color: textColor, fontWeight: FontWeight.w600);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12.withValues(alpha: .2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(label, style: textStyle),
        ],
      ),
    );
  }
}

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
    final theme = Theme.of(context);
    final attributes = _primaryListingAttributes(listing);
    final bool isNew = DateTime.now().difference(listing.date) <= _newBadgeThreshold;

    final badges = <Widget>[
      if (isNew)
        _InfoBadge(
          label: 'Yeni',
          backgroundColor: theme.colorScheme.primary,
          textColor: Colors.white,
        ),
      _InfoBadge(
        label: timeAgo(listing.date),
        backgroundColor: Colors.black.withValues(alpha: .55),
        textColor: Colors.white,
      ),
      if (listing.isPremium)
        _InfoBadge(
          label: 'Premium',
          icon: Icons.star_rounded,
          backgroundColor: Colors.amber.shade200,
          textColor: Colors.amber.shade900,
        ),
    ];

    return GestureDetector(
      onTap: onTap != null ? () => onTap!(listing) : null,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
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
                Positioned(
                  top: 16,
                  left: 16,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: badges,
                  ),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: ListingFavoriteButton(listingId: listing.id),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatPrice(listing.price, listing.currency),
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (attributes.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      attributes.join('  |  '),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Text(
                    listing.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
                  ),
                  if (listing.title.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      listing.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
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
    this.showStatusBadge = false,
  });

  final Listing listing;
  final ListingTapCallback? onTap;
  final bool showStatusBadge;

  @override
  Widget build(BuildContext context) {
    final card = ListingCard(
      listing: listing,
      onTap: onTap,
    );

    if (!showStatusBadge) {
      return card;
    }

    final status = listing.status;
    if (status == ListingStatus.approved) {
      return card;
    }

    final Color badgeColor;
    final String label;

    switch (status) {
      case ListingStatus.pending:
        badgeColor = Colors.orangeAccent;
        label = 'Onay Bekliyor';
        break;
      case ListingStatus.rejected:
        badgeColor = Colors.redAccent;
        label = 'Reddedildi';
        break;
      case ListingStatus.approved:
        badgeColor = Colors.green;
        label = 'Yayında';
        break;
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        card,
        Positioned(
          top: 18,
          left: 18,
          child: _StatusBadge(label: label, color: badgeColor),
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .9),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: .35),
            offset: const Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(color: Colors.white),
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
