import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models.dart';
import '../../data/listing_filters.dart';
import '../../state/app_state.dart';
import '../../utils/formatters.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/filter_widgets.dart';
import '../../widgets/listing_widgets.dart';
import '../../widgets/filter_drawer.dart';
import '../listing_detail_screen.dart';
import 'category_tree_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  String? _selectedCity;
  ListingCategory? _selectedCategory;
  double? _minPrice;
  double? _maxPrice;
  int? _minYear;
  int? _maxYear;
  int? _minMileage;
  int? _maxMileage;
  FuelType? _selectedFuelType;
  TransmissionType? _selectedTransmission;
  VehicleCondition? _selectedCondition;
  Drivetrain? _selectedDrivetrain;
  SortOption _sortOption = SortOption.newest;
  String? _selectedBrand;
  String? _selectedModel;
  String? _selectedEngineType;
  VehicleSubcategory? _selectedVehicleSubcategory;

  bool get _hasActiveFilters => _buildActiveFilterChips().isNotEmpty;

  static const List<_SearchCategoryItem> _categories = [
    _SearchCategoryItem(
      category: ListingCategory.konut,
      title: 'Konut',
      subtitle: 'Satılık & kiralık daire, villa, arsa',
      icon: Icons.home_rounded,
      color: Color(0xFF4CAF50),
    ),
    _SearchCategoryItem(
      category: ListingCategory.arac,
      title: 'Vasıta',
      subtitle: 'Otomobil, SUV, ticari araç ve motosiklet',
      icon: Icons.directions_car_rounded,
      color: Color(0xFF2196F3),
    ),
    _SearchCategoryItem(
      category: ListingCategory.emlak,
      title: 'Emlak & Yatırım',
      subtitle: 'Arsa, arazi ve ticari gayrimenkuller',
      icon: Icons.domain_rounded,
      color: Color(0xFF9C27B0),
    ),
    _SearchCategoryItem(
      category: ListingCategory.elektronik,
      title: 'Elektronik',
      subtitle: 'Bilgisayar, telefon, oyun ve aksesuarlar',
      icon: Icons.devices_other_rounded,
      color: Color(0xFFFF9800),
    ),
    _SearchCategoryItem(
      category: ListingCategory.hizmet,
      title: 'Hizmetler',
      subtitle: 'Usta, bakım, danışmanlık ve özel ders',
      icon: Icons.handyman_rounded,
      color: Color(0xFF00B894),
    ),
    _SearchCategoryItem(
      category: ListingCategory.isFirsati,
      title: 'İş & Kariyer',
      subtitle: 'İş ilanları, franchise ve yatırım fırsatları',
      icon: Icons.business_center_rounded,
      color: Color(0xFFFF5252),
    ),
    _SearchCategoryItem(
      category: ListingCategory.hayvan,
      title: 'Hayvanlar Alemi',
      subtitle: 'Evcil hayvanlar ve aksesuarları',
      icon: Icons.pets_rounded,
      color: Color(0xFF00BCD4),
    ),
    _SearchCategoryItem(
      category: ListingCategory.diger,
      title: 'Diğer',
      subtitle: 'Koleksiyon, hobi ve ikinci el ürünler',
      icon: Icons.category_rounded,
      color: Color(0xFF607D8B),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Listing> _applySort(List<Listing> items) {
    final sorted = List<Listing>.from(items);
    switch (_sortOption) {
      case SortOption.priceLowToHigh:
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHighToLow:
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.newest:
        sorted.sort((a, b) => b.date.compareTo(a.date));
        break;
    }
    return sorted;
  }

  Future<void> _openFiltersSheet() async {
    final result = await showListingFilterDrawer(
      context: context,
      initialFilters: ListingFilters(
        city: _selectedCity,
        category: _selectedCategory,
        vehicleSubcategory: _selectedVehicleSubcategory,
        brand: _selectedBrand,
        model: _selectedModel,
        engineType: _selectedEngineType,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        minYear: _minYear,
        maxYear: _maxYear,
        minMileage: _minMileage,
        maxMileage: _maxMileage,
        fuelType: _selectedFuelType,
        transmission: _selectedTransmission,
        condition: _selectedCondition,
        drivetrain: _selectedDrivetrain,
      ),
      config: const ListingFilterConfig(
        allowCategorySelection: true,
        allowVehicleSubcategorySelection: true,
      ),
    );

    if (result == null) return;

    setState(() {
      _selectedCity = result.city;
      _selectedCategory = result.category;
      _selectedVehicleSubcategory = result.vehicleSubcategory;
      _selectedBrand = result.brand;
      _selectedModel = result.model;
      _selectedEngineType = result.engineType;
      _minPrice = result.minPrice;
      _maxPrice = result.maxPrice;
      _minYear = result.minYear;
      _maxYear = result.maxYear;
      _minMileage = result.minMileage;
      _maxMileage = result.maxMileage;
      _selectedFuelType = result.fuelType;
      _selectedTransmission = result.transmission;
      _selectedCondition = result.condition;
      _selectedDrivetrain = result.drivetrain;

      if (_selectedVehicleSubcategory != null) {
        _selectedCategory = ListingCategory.arac;
      }
      if (_selectedCategory != ListingCategory.arac) {
        _selectedVehicleSubcategory = null;
        _selectedBrand = null;
        _selectedModel = null;
        _selectedEngineType = null;
        _selectedFuelType = null;
        _selectedTransmission = null;
        _selectedCondition = null;
        _selectedDrivetrain = null;
        _minYear = null;
        _maxYear = null;
        _minMileage = null;
        _maxMileage = null;
      }
    });
  }

  List<_FilterChipData> _buildActiveFilterChips() {
    final chips = <_FilterChipData>[];

    if (_selectedCategory != null) {
      chips.add(
        _FilterChipData(
          label: categoryLabel(_selectedCategory!),
          onRemoved: () => setState(() {
            _selectedCategory = null;
            _selectedVehicleSubcategory = null;
            _selectedBrand = null;
            _selectedModel = null;
            _selectedEngineType = null;
          }),
        ),
      );
    }

    if (_selectedVehicleSubcategory != null) {
      chips.add(
        _FilterChipData(
          label: vehicleSubcategoryLabel(_selectedVehicleSubcategory!),
          onRemoved: () => setState(() {
            _selectedVehicleSubcategory = null;
            _selectedBrand = null;
            _selectedModel = null;
            _selectedEngineType = null;
            _selectedFuelType = null;
            _selectedTransmission = null;
            _selectedCondition = null;
            _selectedDrivetrain = null;
          }),
        ),
      );
    }

    if ((_selectedBrand ?? '').isNotEmpty) {
      chips.add(
        _FilterChipData(
          label: _selectedBrand!,
          onRemoved: () => setState(() {
            _selectedBrand = null;
            _selectedModel = null;
            _selectedEngineType = null;
          }),
        ),
      );
    }

    if ((_selectedModel ?? '').isNotEmpty) {
      chips.add(
        _FilterChipData(
          label: _selectedModel!,
          onRemoved: () => setState(() {
            _selectedModel = null;
            _selectedEngineType = null;
          }),
        ),
      );
    }

    if ((_selectedEngineType ?? '').isNotEmpty) {
      chips.add(
        _FilterChipData(
          label: _selectedEngineType!,
          onRemoved: () => setState(() => _selectedEngineType = null),
        ),
      );
    }

    if (_selectedFuelType != null) {
      chips.add(
        _FilterChipData(
          label: fuelTypeLabel(_selectedFuelType!),
          onRemoved: () => setState(() => _selectedFuelType = null),
        ),
      );
    }

    if (_selectedTransmission != null) {
      chips.add(
        _FilterChipData(
          label: transmissionLabel(_selectedTransmission!),
          onRemoved: () => setState(() => _selectedTransmission = null),
        ),
      );
    }

    if (_selectedCondition != null) {
      chips.add(
        _FilterChipData(
          label: vehicleConditionLabel(_selectedCondition!),
          onRemoved: () => setState(() => _selectedCondition = null),
        ),
      );
    }

    if (_selectedDrivetrain != null) {
      chips.add(
        _FilterChipData(
          label: drivetrainLabel(_selectedDrivetrain!),
          onRemoved: () => setState(() => _selectedDrivetrain = null),
        ),
      );
    }

    if ((_selectedCity ?? '').isNotEmpty) {
      chips.add(
        _FilterChipData(
          label: _selectedCity!,
          onRemoved: () => setState(() => _selectedCity = null),
        ),
      );
    }

    if (_minPrice != null || _maxPrice != null) {
      chips.add(
        _FilterChipData(
          label: 'Fiyat: '
              '${_minPrice != null ? _minPrice!.toInt().toString() : '---'}'
              ' - '
              '${_maxPrice != null ? _maxPrice!.toInt().toString() : '---'} ₺',
          onRemoved: () => setState(() {
            _minPrice = null;
            _maxPrice = null;
          }),
        ),
      );
    }

    if (_minYear != null || _maxYear != null) {
      chips.add(
        _FilterChipData(
          label: 'Yıl: '
              '${_minYear ?? '---'} - ${_maxYear ?? '---'}',
          onRemoved: () => setState(() {
            _minYear = null;
            _maxYear = null;
          }),
        ),
      );
    }

    if (_minMileage != null || _maxMileage != null) {
      chips.add(
        _FilterChipData(
          label: 'KM: '
              '${_minMileage ?? '---'} - ${_maxMileage ?? '---'}',
          onRemoved: () => setState(() {
            _minMileage = null;
            _maxMileage = null;
          }),
        ),
      );
    }

    return chips;
  }

  List<Listing> _filteredResults(List<Listing> listings) {
    final query = _controller.text.trim().toLowerCase();
    final Iterable<Listing> filtered = listings.where((listing) {
      if (_selectedCity != null &&
          _selectedCity!.isNotEmpty &&
          !listing.location.toLowerCase().contains(
                _selectedCity!.toLowerCase(),
              )) {
        return false;
      }
      if (_selectedCategory != null && listing.category != _selectedCategory) {
        return false;
      }
      if (_selectedVehicleSubcategory != null) {
        if (listing.vehicleSubcategory != _selectedVehicleSubcategory) {
          return false;
        }
      }
      if (_selectedFuelType != null) {
        if (listing.fuelType != _selectedFuelType) {
          return false;
        }
      }
      if (_selectedTransmission != null) {
        if (listing.transmission != _selectedTransmission) {
          return false;
        }
      }
      if (_selectedCondition != null) {
        if (listing.condition != _selectedCondition) {
          return false;
        }
      }
      if (_selectedDrivetrain != null) {
        if (listing.drivetrain != _selectedDrivetrain) {
          return false;
        }
      }
      if (_selectedBrand != null && _selectedBrand!.isNotEmpty) {
        if ((listing.brand ?? '').toLowerCase() !=
            _selectedBrand!.toLowerCase()) {
          return false;
        }
      }
      if (_selectedModel != null && _selectedModel!.isNotEmpty) {
        if ((listing.model ?? '').toLowerCase() !=
            _selectedModel!.toLowerCase()) {
          return false;
        }
      }
      if (_selectedEngineType != null && _selectedEngineType!.isNotEmpty) {
        if ((listing.engineType ?? '').toLowerCase() !=
            _selectedEngineType!.toLowerCase()) {
          return false;
        }
      }
      final double price = listing.price;
      if (_minPrice != null && price < _minPrice!) {
        return false;
      }
      if (_maxPrice != null && price > _maxPrice!) {
        return false;
      }
      if (_minYear != null && listing.year != null && listing.year! < _minYear!) {
        return false;
      }
      if (_maxYear != null && listing.year != null && listing.year! > _maxYear!) {
        return false;
      }
      if (_minMileage != null && listing.mileage != null &&
          listing.mileage! < _minMileage!) {
        return false;
      }
      if (_maxMileage != null && listing.mileage != null &&
          listing.mileage! > _maxMileage!) {
        return false;
      }
      if (query.isEmpty) {
        return true;
      }
      final haystack =
          '${listing.title} ${listing.description} ${listing.location}'.
              toLowerCase();
      return haystack.contains(query);
    });

    return _applySort(filtered.toList());
  }

  @override
  Widget build(BuildContext context) {
    final listings = context.watch<AppState>().listings;
    final results = _filteredResults(listings);
    final query = _controller.text.trim();
    final hasQuery = query.isNotEmpty;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ara'),
        actions: [
          IconButton(
            tooltip: 'Filtreler',
            onPressed: _openFiltersSheet,
            icon: const Icon(Icons.filter_list_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'search-bar',
              child: Material(
                color: Colors.transparent,
                child: TextField(
                  controller: _controller,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Ne arıyorsunuz?',
                    prefixIcon: Icon(Icons.search_rounded),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_hasActiveFilters)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ActiveFiltersWrap(filters: _buildActiveFilterChips()),
              ),
            if (!hasQuery) ...[
              Text('Kategoriler', style: textTheme.titleLarge),
              const SizedBox(height: 16),
              Expanded(
                child: _CategoryList(
                  categories: _categories,
                  onTap: (category) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CategoryTreeScreen(category: category),
                      ),
                    );
                  },
                ),
              ),
            ] else ...[
              Expanded(
                child: _SearchResultsView(
                  results: results,
                  sortOption: _sortOption,
                  onSortChanged: (option) {
                    setState(() => _sortOption = option);
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({required this.categories, required this.onTap});

  final List<_SearchCategoryItem> categories;
  final void Function(ListingCategory category) onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.separated(
      itemCount: categories.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = categories[index];
        return Card(
          elevation: 0,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => onTap(item.category),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: .15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(item.icon, color: item.color),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.subtitle,
                          style: theme.textTheme.bodyMedium!
                              .copyWith(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      color: theme.colorScheme.outline),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SearchResultsView extends StatelessWidget {
  const _SearchResultsView({
    required this.results,
    required this.sortOption,
    required this.onSortChanged,
  });

  final List<Listing> results;
  final SortOption sortOption;
  final ValueChanged<SortOption> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (results.isEmpty) {
      return const EmptyState(
        title: 'Sonuç bulunamadı',
        subtitle:
            'Aramanızı daraltmak için farklı anahtar kelimeler veya filtreler deneyebilirsiniz.',
        icon: Icons.search_off_rounded,
      );
    }

    return ListView(
      children: [
        Text('${results.length} ilan bulundu',
            style: textTheme.bodyLarge),
        const SizedBox(height: 16),
        SortOptionsBar(selected: sortOption, onChanged: onSortChanged),
        const SizedBox(height: 16),
        ...results.map(
          (listing) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ListingTile(
              listing: listing,
              onTap: (selected) => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ListingDetailScreen(listing: selected),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FilterChipData {
  const _FilterChipData({required this.label, this.onRemoved});

  final String label;
  final VoidCallback? onRemoved;
}

class _ActiveFiltersWrap extends StatelessWidget {
  const _ActiveFiltersWrap({required this.filters});

  final List<_FilterChipData> filters;

  @override
  Widget build(BuildContext context) {
    if (filters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: filters
          .map(
            (chip) => InputChip(
              label: Text(chip.label),
              onDeleted: chip.onRemoved,
              deleteIcon: chip.onRemoved != null
                  ? const Icon(Icons.close_rounded, size: 18)
                  : null,
              isEnabled: chip.onRemoved != null,
            ),
          )
          .toList(),
    );
  }
}

class _SearchCategoryItem {
  const _SearchCategoryItem({
    required this.category,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final ListingCategory category;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
}
