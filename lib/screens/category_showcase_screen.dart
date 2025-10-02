import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../state/app_state.dart';
import '../widgets/listing_widgets.dart';
import '../widgets/common_widgets.dart';
import '../utils/formatters.dart';
import 'listing_detail_screen.dart';
import '../widgets/filter_drawer.dart';
import '../data/listing_filters.dart';
import '../widgets/filter_widgets.dart';

class CategoryShowcaseScreen extends StatefulWidget {
  const CategoryShowcaseScreen({
    super.key,
    required this.category,
    this.showPremium = true,
    this.vehicleSubcategory,
  });

  final ListingCategory category;
  final bool showPremium;
  final VehicleSubcategory? vehicleSubcategory;

  @override
  State<CategoryShowcaseScreen> createState() => _CategoryShowcaseScreenState();
}

class _CategoryShowcaseScreenState extends State<CategoryShowcaseScreen> {
  final TextEditingController _searchController = TextEditingController();
  SortOption _sortOption = SortOption.newest;
  String? _selectedBrand;
  String? _selectedModel;
  String? _selectedEngineType;
  String? _selectedCity;
  VehicleSubcategory? _selectedVehicleSubcategory;
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _selectedVehicleSubcategory = widget.vehicleSubcategory;
  }

  bool get _hasActiveFilters => _buildActiveFilterChips().isNotEmpty;

  Future<void> _openFiltersDrawer() async {
    final result = await showListingFilterDrawer(
      context: context,
      initialFilters: ListingFilters(
        city: _selectedCity,
        category: widget.category,
        vehicleSubcategory: _selectedVehicleSubcategory ?? widget.vehicleSubcategory,
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
      config: ListingFilterConfig(
        lockedCategory: widget.category,
        allowCategorySelection: false,
        lockedVehicleSubcategory: widget.vehicleSubcategory,
        allowVehicleSubcategorySelection: widget.vehicleSubcategory == null,
      ),
    );

    if (result == null) return;

    setState(() {
      _selectedCity = result.city;
      _selectedVehicleSubcategory = result.vehicleSubcategory ?? widget.vehicleSubcategory;
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
    });
  }

  List<_CategoryFilterChipData> _buildActiveFilterChips() {
    final chips = <_CategoryFilterChipData>[];

    if (_selectedVehicleSubcategory != null) {
      chips.add(
        _CategoryFilterChipData(
          label: vehicleSubcategoryLabel(_selectedVehicleSubcategory!),
          onRemoved: widget.vehicleSubcategory != null
              ? null
              : () => setState(() {
                    _selectedVehicleSubcategory = null;
                    _selectedBrand = null;
                    _selectedModel = null;
                    _selectedEngineType = null;
                  }),
        ),
      );
    }

    if ((_selectedBrand ?? '').isNotEmpty) {
      chips.add(
        _CategoryFilterChipData(
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
        _CategoryFilterChipData(
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
        _CategoryFilterChipData(
          label: _selectedEngineType!,
          onRemoved: () => setState(() => _selectedEngineType = null),
        ),
      );
    }

    if ((_selectedCity ?? '').isNotEmpty) {
      chips.add(
        _CategoryFilterChipData(
          label: _selectedCity!,
          onRemoved: () => setState(() => _selectedCity = null),
        ),
      );
    }

    if (_minPrice != null || _maxPrice != null) {
      chips.add(
        _CategoryFilterChipData(
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

    if (_selectedFuelType != null) {
      chips.add(
        _CategoryFilterChipData(
          label: fuelTypeLabel(_selectedFuelType!),
          onRemoved: () => setState(() => _selectedFuelType = null),
        ),
      );
    }

    if (_selectedTransmission != null) {
      chips.add(
        _CategoryFilterChipData(
          label: transmissionLabel(_selectedTransmission!),
          onRemoved: () => setState(() => _selectedTransmission = null),
        ),
      );
    }

    if (_selectedCondition != null) {
      chips.add(
        _CategoryFilterChipData(
          label: vehicleConditionLabel(_selectedCondition!),
          onRemoved: () => setState(() => _selectedCondition = null),
        ),
      );
    }

    if (_selectedDrivetrain != null) {
      chips.add(
        _CategoryFilterChipData(
          label: drivetrainLabel(_selectedDrivetrain!),
          onRemoved: () => setState(() => _selectedDrivetrain = null),
        ),
      );
    }

    if (_minYear != null || _maxYear != null) {
      chips.add(
        _CategoryFilterChipData(
          label:
              'Yıl: ${_minYear ?? '---'} - ${_maxYear ?? '---'}',
          onRemoved: () => setState(() {
            _minYear = null;
            _maxYear = null;
          }),
        ),
      );
    }

    if (_minMileage != null || _maxMileage != null) {
      chips.add(
        _CategoryFilterChipData(
          label:
              'KM: ${_minMileage ?? '---'} - ${_maxMileage ?? '---'}',
          onRemoved: () => setState(() {
            _minMileage = null;
            _maxMileage = null;
          }),
        ),
      );
    }

    return chips;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final basePremium = widget.showPremium
        ? appState.premiumByCategory(widget.category)
        : const <Listing>[];

    final VehicleSubcategory? activeVehicleFilter =
        widget.category == ListingCategory.arac
            ? _selectedVehicleSubcategory
            : null;

    final premiumListings = activeVehicleFilter != null
        ? basePremium
            .where((listing) => listing.vehicleSubcategory == activeVehicleFilter)
            .toList()
        : basePremium;

    final query = _searchController.text.trim().toLowerCase();
    List<Listing> baseResults =
        appState.listingsByCategory(widget.category).toList();

    if (query.isNotEmpty) {
      baseResults = baseResults
          .where(
            (listing) =>
                ('${listing.title} ${listing.description} ${listing.location}')
                    .toLowerCase()
                    .contains(query),
          )
          .toList();
    }

    if (activeVehicleFilter != null) {
      baseResults = baseResults
          .where((listing) => listing.vehicleSubcategory == activeVehicleFilter)
          .toList();
    }

    final results = _applySort(baseResults);

    final filteredResults = results.where((listing) {
      if (_selectedCity != null && _selectedCity!.isNotEmpty) {
        if (!listing.location
            .toLowerCase()
            .contains(_selectedCity!.toLowerCase())) {
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

      final price = listing.price;
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
      return true;
    }).toList();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.vehicleSubcategory != null
              ? vehicleSubcategoryLabel(widget.vehicleSubcategory!)
              : categoryLabel(widget.category),
        ),
        actions: [
          IconButton(
            tooltip: 'Filtreler',
            onPressed: _openFiltersDrawer,
            icon: const Icon(Icons.filter_list_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Model, başlık veya özellik ara',
              prefixIcon: Icon(Icons.search_rounded),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          if (_hasActiveFilters)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CategoryActiveFiltersWrap(
                filters: _buildActiveFilterChips(),
              ),
            ),
          SortOptionsBar(
            selected: _sortOption,
            onChanged: (option) => setState(() => _sortOption = option),
          ),
          if (widget.showPremium) ...[
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Vitrin', style: theme.textTheme.titleLarge),
                if (premiumListings.isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withValues(alpha: .14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.workspace_premium_rounded,
                            size: 18, color: Color(0xFF21B573)),
                        SizedBox(width: 6),
                        Text('Ücretli Vitrin'),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (premiumListings.isEmpty)
              const EmptyState(
                title: 'Vitrin boş',
                subtitle:
                    'Bu kategori için henüz öne çıkan ilan bulunmuyor. İlk sen ol!',
                icon: Icons.crop_portrait_rounded,
              )
            else
              SizedBox(
                height: 360,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: premiumListings.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 16),
                  itemBuilder: (_, index) {
                    final listing = premiumListings[index];
                    return SizedBox(
                      width: 280,
                      child: ListingCard(
                        listing: listing,
                        onTap: (value) => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ListingDetailScreen(listing: value),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 32),
          ],
          const SizedBox(height: 32),
          Text('İlanlar', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          if (filteredResults.isEmpty)
            const EmptyState(
              title: 'Sonuç bulunamadı',
              subtitle:
                  'Farklı kelimeler deneyebilir veya filtrelemeyi daraltabilirsin.',
              icon: Icons.search_off_rounded,
            )
          else ...[
            SortOptionsBar(
              selected: _sortOption,
              onChanged: (option) {
                setState(() => _sortOption = option);
              },
            ),
            const SizedBox(height: 16),
            ...filteredResults.map(
              (listing) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ListingTile(
                  listing: listing,
                  onTap: (value) => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ListingDetailScreen(listing: value),
                    ),
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}

class _CategoryFilterChipData {
  const _CategoryFilterChipData({required this.label, this.onRemoved});

  final String label;
  final VoidCallback? onRemoved;
}

class _CategoryActiveFiltersWrap extends StatelessWidget {
  const _CategoryActiveFiltersWrap({required this.filters});

  final List<_CategoryFilterChipData> filters;

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
