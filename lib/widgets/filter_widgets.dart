import 'package:flutter/material.dart';

import '../state/app_state.dart';

class PriceFilterChip extends StatelessWidget {
  const PriceFilterChip({
    super.key,
    required this.range,
    required this.onRangeChanged,
  });

  final RangeValues range;
  final ValueChanged<RangeValues> onRangeChanged;

  @override
  Widget build(BuildContext context) {
    final double availableWidth = MediaQuery.of(context).size.width - 40;
    final double clampedWidth = availableWidth > 0
        ? availableWidth.clamp(0.0, 360.0)
        : 320.0;

    return Container(
      width: clampedWidth,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Fiyat Aralığı',
                  style: Theme.of(context).textTheme.titleMedium),
              Text(
                '${range.start.toInt()} - ${range.end.toInt()} TL',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                overlayShape: SliderComponentShape.noOverlay,
                rangeThumbShape:
                    const RoundRangeSliderThumbShape(enabledThumbRadius: 10),
                valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                showValueIndicator: ShowValueIndicator.never,
              ),
              child: RangeSlider(
                values: range,
                min: 0,
                max: 500000,
                divisions: 200,
                onChanged: onRangeChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DropdownFilterChip<T> extends StatelessWidget {
  const DropdownFilterChip({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemLabelBuilder,
  });

  final String label;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String Function(T value)? itemLabelBuilder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              hint: Text('Seçiniz',
                  style: Theme.of(context).textTheme.bodyMedium),
              items: items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        itemLabelBuilder != null
                            ? itemLabelBuilder!(item)
                            : item.toString(),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class SortOptionsBar extends StatelessWidget {
  const SortOptionsBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final SortOption selected;
  final ValueChanged<SortOption> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Map<SortOption, String> labels = {
      SortOption.newest: 'En Yeni',
      SortOption.priceLowToHigh: 'Fiyat (Artan)',
      SortOption.priceHighToLow: 'Fiyat (Azalan)',
    };

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children: labels.entries.map(
        (entry) {
          final bool isSelected = entry.key == selected;
          return ChoiceChip(
            label: Text(entry.value),
            selected: isSelected,
            onSelected: (_) => onChanged(entry.key),
            selectedColor: theme.colorScheme.primary.withValues(alpha: .12),
            labelStyle: theme.textTheme.bodyMedium!.copyWith(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.textTheme.bodyMedium!.color,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          );
        },
      ).toList(),
    );
  }
}
