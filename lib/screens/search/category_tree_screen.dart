import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/category_tree.dart';
import '../../data/models.dart';
import '../../state/app_state.dart';
import '../../utils/formatters.dart';
import '../category_showcase_screen.dart';

class CategoryTreeScreen extends StatelessWidget {
  const CategoryTreeScreen({super.key, required this.category, this.parent});

  final ListingCategory category;
  final CategoryNode? parent;

  @override
  Widget build(BuildContext context) {
    final title = parent?.label ?? categoryLabel(category);
    final listings = context.watch<AppState>().listings;
    final nodes = parent?.children ?? listingCategoryTree[category] ?? const <CategoryNode>[];
    final theme = Theme.of(context);

    final entries = <_TreeEntry>[];

    if (parent == null) {
      final count = _count(listings, category);
      entries.add(
        _TreeEntry(
          label: 'Tüm ${categoryLabel(category)} ilanları',
          count: count,
          onTap: () => _openShowcase(context, category),
          icon: Icons.apps_rounded,
          isPrimary: true,
        ),
      );
    } else {
      final count = _count(listings, category, subcategory: parent!.label);
      entries.add(
        _TreeEntry(
          label: 'Tüm ${parent!.label}',
          count: count,
          onTap: () => _openShowcase(
            context,
            category,
            subcategory: parent!.label,
          ),
          icon: Icons.apps_rounded,
          isPrimary: true,
        ),
      );
    }

    for (final node in nodes) {
      final hasChildren = node.children.isNotEmpty;
      final count = parent == null
          ? _count(listings, category, subcategory: node.label)
          : _count(
              listings,
              category,
              subcategory: parent!.label,
              detail: node.label,
            );

      entries.add(
        _TreeEntry(
          label: node.label,
          count: count,
          onTap: () {
            if (hasChildren) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => CategoryTreeScreen(
                    category: category,
                    parent: node,
                  ),
                ),
              );
            } else {
              _openShowcase(
                context,
                category,
                subcategory: parent?.label ?? node.label,
                detail: parent == null ? null : node.label,
              );
            }
          },
          icon: hasChildren ? Icons.folder_open_rounded : Icons.label_rounded,
          showChevron: hasChildren,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: entries.length,
        separatorBuilder: (_, __) => Divider(
          height: 0,
          indent: 20,
          endIndent: 20,
          color: theme.dividerColor.withValues(alpha: .3),
        ),
        itemBuilder: (_, index) {
          final entry = entries[index];
          final iconColor = entry.isPrimary
              ? theme.colorScheme.primary
              : theme.colorScheme.primary.withValues(alpha: .8);
          return ListTile(
            leading: CircleAvatar(
              radius: 20,
              backgroundColor: iconColor.withValues(alpha: .12),
              child: Icon(entry.icon, color: iconColor),
            ),
            title: Text(entry.label),
            subtitle: Text('${entry.count} ilan'),
            trailing:
                entry.showChevron ? const Icon(Icons.chevron_right_rounded) : null,
            onTap: entry.onTap,
          );
        },
      ),
    );
  }

  static int _count(
    List<Listing> listings,
    ListingCategory category, {
    String? subcategory,
    String? detail,
  }) {
    return listings.where((listing) {
      if (listing.category != category) return false;
      if (subcategory != null) {
        if ((listing.subcategory ?? '').toLowerCase() != subcategory.toLowerCase()) {
          return false;
        }
      }
      if (detail != null) {
        if ((listing.subcategoryDetail ?? '').toLowerCase() != detail.toLowerCase()) {
          return false;
        }
      }
      return true;
    }).length;
  }

  void _openShowcase(
    BuildContext context,
    ListingCategory category, {
    String? subcategory,
    String? detail,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CategoryShowcaseScreen(
          category: category,
          showPremium: false,
          subcategoryLabel: subcategory,
          subcategoryDetailLabel: detail,
        ),
      ),
    );
  }
}

class _TreeEntry {
  const _TreeEntry({
    required this.label,
    required this.count,
    required this.onTap,
    this.icon,
    this.showChevron = false,
    this.isPrimary = false,
  });

  final String label;
  final int count;
  final VoidCallback onTap;
  final IconData? icon;
  final bool showChevron;
  final bool isPrimary;
}
