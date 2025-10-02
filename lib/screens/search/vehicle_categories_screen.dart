import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models.dart';
import '../../data/vehicle_categories.dart';
import '../../state/app_state.dart';
import '../../utils/formatters.dart';
import '../category_showcase_screen.dart';

class VehicleCategoriesScreen extends StatelessWidget {
  const VehicleCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final int totalCount =
        appState.listingsByCategory(ListingCategory.arac).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Vasıta')),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: vehicleCategoryInfos.length + 1,
        separatorBuilder: (_, __) => Divider(
          height: 0,
          color: theme.dividerColor.withValues(alpha: .4),
          indent: 72,
        ),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _VehicleCategoryTile(
              label: 'Tüm "Vasıta" ilanları',
              count: totalCount,
              icon: Icons.apps_rounded,
              isPrimary: true,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CategoryShowcaseScreen(
                    category: ListingCategory.arac,
                    showPremium: false,
                  ),
                ),
              ),
            );
          }

          final info = vehicleCategoryInfos[index - 1];
          final count = appState.vehicleSubcategoryCount(info.type);
          return _VehicleCategoryTile(
            label: vehicleSubcategoryLabel(info.type),
            count: count,
            icon: info.icon,
            badge: info.badge,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => CategoryShowcaseScreen(
                  category: ListingCategory.arac,
                  vehicleSubcategory: info.type,
                  showPremium: false,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _VehicleCategoryTile extends StatelessWidget {
  const _VehicleCategoryTile({
    required this.label,
    required this.count,
    required this.icon,
    this.badge,
    required this.onTap,
    this.isPrimary = false,
  });

  final String label;
  final int count;
  final IconData icon;
  final String? badge;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color foreground =
        isPrimary ? theme.colorScheme.primary : theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon,
                  color: isPrimary
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withValues(alpha: .7)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      label,
                      style: theme.textTheme.titleMedium!.copyWith(
                        color: isPrimary ? theme.colorScheme.primary : null,
                      ),
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: 6),
                    Text(badge!, style: const TextStyle(fontSize: 16)),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              '(${count.toString()})',
              style: theme.textTheme.bodyMedium!.copyWith(
                color: foreground.withValues(alpha: .7),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: foreground.withValues(alpha: .7)),
          ],
        ),
      ),
    );
  }
}
