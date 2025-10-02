import 'package:flutter/material.dart';

import '../data/car_brands.dart';
import '../data/car_models.dart';
import '../data/cities.dart';
import '../data/listing_filters.dart';
import '../data/models.dart';
import '../data/vehicle_categories.dart';
import '../utils/formatters.dart';

Future<ListingFilters?> showListingFilterDrawer({
  required BuildContext context,
  required ListingFilters initialFilters,
  required ListingFilterConfig config,
}) {
  final mediaQuery = MediaQuery.of(context);
  final double width = mediaQuery.size.width;
  final double drawerWidth = width > 720 ? 420 : width * 0.9;

  return showGeneralDialog<ListingFilters>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Filtreler',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 280),
    pageBuilder: (_, __, ___) {
      return Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: drawerWidth,
          child: _ListingFilterDrawer(
            initialFilters: initialFilters,
            config: config,
          ),
        ),
      );
    },
    transitionBuilder: (_, animation, __, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(curved),
        child: child,
      );
    },
  );
}

class _ListingFilterDrawer extends StatefulWidget {
  const _ListingFilterDrawer({
    required this.initialFilters,
    required this.config,
  });

  final ListingFilters initialFilters;
  final ListingFilterConfig config;

  @override
  State<_ListingFilterDrawer> createState() => _ListingFilterDrawerState();
}

class _ListingFilterDrawerState extends State<_ListingFilterDrawer> {

  late String? _city;
  late ListingCategory? _category;
  late VehicleSubcategory? _vehicleSubcategory;
  late String? _brand;
  late String? _model;
  late String? _engineType;
  double? _minPrice;
  double? _maxPrice;
  int? _minYear;
  int? _maxYear;
  int? _minMileage;
  int? _maxMileage;
  FuelType? _fuelType;
  TransmissionType? _transmission;
  VehicleCondition? _condition;
  Drivetrain? _drivetrain;

  late TextEditingController _minPriceController;
  late TextEditingController _maxPriceController;
  late TextEditingController _minYearController;
  late TextEditingController _maxYearController;
  late TextEditingController _minMileageController;
  late TextEditingController _maxMileageController;

  @override
  void initState() {
    super.initState();
    _city = widget.initialFilters.city;
    _category = widget.initialFilters.category ?? widget.config.lockedCategory;
    _vehicleSubcategory =
        widget.initialFilters.vehicleSubcategory ?? widget.config.lockedVehicleSubcategory;
    _brand = widget.initialFilters.brand;
    _model = widget.initialFilters.model;
    _engineType = widget.initialFilters.engineType;
    _minPrice = widget.initialFilters.minPrice;
    _maxPrice = widget.initialFilters.maxPrice;
    _minYear = widget.initialFilters.minYear;
    _maxYear = widget.initialFilters.maxYear;
    _minMileage = widget.initialFilters.minMileage;
    _maxMileage = widget.initialFilters.maxMileage;
    _fuelType = widget.initialFilters.fuelType;
    _transmission = widget.initialFilters.transmission;
    _condition = widget.initialFilters.condition;
    _drivetrain = widget.initialFilters.drivetrain;
    _minPriceController = TextEditingController(
      text: _minPrice != null ? _minPrice!.toInt().toString() : '',
    );
    _maxPriceController = TextEditingController(
      text: _maxPrice != null ? _maxPrice!.toInt().toString() : '',
    );
    _minYearController = TextEditingController(
      text: _minYear?.toString() ?? '',
    );
    _maxYearController = TextEditingController(
      text: _maxYear?.toString() ?? '',
    );
    _minMileageController = TextEditingController(
      text: _minMileage != null ? _minMileage!.toInt().toString() : '',
    );
    _maxMileageController = TextEditingController(
      text: _maxMileage != null ? _maxMileage!.toInt().toString() : '',
    );
  }

  void _resetAll() {
    setState(() {
      _city = null;
      _minPrice = null;
      _maxPrice = null;
      _minYear = null;
      _maxYear = null;
      _minMileage = null;
      _maxMileage = null;
      _fuelType = null;
      _transmission = null;
      _condition = null;
      _drivetrain = null;
      _category = widget.config.lockedCategory;
      _vehicleSubcategory = widget.config.lockedVehicleSubcategory;
      _brand = null;
      _model = null;
      _engineType = null;
      _minPriceController.text = '';
      _maxPriceController.text = '';
      _minYearController.text = '';
      _maxYearController.text = '';
      _minMileageController.text = '';
      _maxMileageController.text = '';
    });
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _minYearController.dispose();
    _maxYearController.dispose();
    _minMileageController.dispose();
    _maxMileageController.dispose();
    super.dispose();
  }

  void _submit() {
    double? parseDouble(String value) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : double.tryParse(trimmed);
    }

    int? parseInt(String value) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : int.tryParse(trimmed);
    }

    final filters = ListingFilters(
      city: _city,
      category: _category,
      vehicleSubcategory: _vehicleSubcategory,
      brand: _brand,
      model: _model,
      engineType: _engineType,
      minPrice: parseDouble(_minPriceController.text),
      maxPrice: parseDouble(_maxPriceController.text),
      minYear: parseInt(_minYearController.text),
      maxYear: parseInt(_maxYearController.text),
      minMileage: parseInt(_minMileageController.text),
      maxMileage: parseInt(_maxMileageController.text),
      fuelType: _fuelType,
      transmission: _transmission,
      condition: _condition,
      drivetrain: _drivetrain,
    );

    Navigator.of(context).pop(filters);
  }

  bool get _isVehicleCategory =>
      (_category ?? widget.config.lockedCategory) == ListingCategory.arac;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Material(
        elevation: 12,
        color: theme.scaffoldBackgroundColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(left: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Filtreler', style: theme.textTheme.titleLarge),
                        const SizedBox(height: 4),
                        Text(
                          'Aramanı daraltmak için seçenekleri düzenle.',
                          style: theme.textTheme.bodyMedium!
                              .copyWith(color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  TextButton(onPressed: _resetAll, child: const Text('Temizle')),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _submit,
                    child: const Text('Tamam'),
                  ),
                ],
              ),
            ),
            const Divider(height: 0),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                children: [
                  _buildCategorySection(theme),
                  const SizedBox(height: 16),
                  _buildCityDropdown(theme),
                  const SizedBox(height: 16),
                  _buildPriceSlider(theme),
                  if (_isVehicleCategory) ...[
                    const SizedBox(height: 16),
                    _buildVehicleSubcategoryField(theme),
                    const SizedBox(height: 16),
                    _buildBrandField(theme),
                    if ((_brand ?? '').isNotEmpty) ...[
                      const SizedBox(height: 16),
                      _buildModelField(theme),
                    ],
                    if ((_model ?? '').isNotEmpty)
                      _buildEngineField(theme),
                    const SizedBox(height: 16),
                    _buildFuelField(theme),
                    const SizedBox(height: 16),
                    _buildTransmissionField(theme),
                    const SizedBox(height: 16),
                    _buildConditionField(theme),
                    const SizedBox(height: 16),
                    _buildDrivetrainField(theme),
                    const SizedBox(height: 16),
                    _buildYearInputs(theme),
                    const SizedBox(height: 16),
                    _buildMileageInputs(theme),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategorySection(ThemeData theme) {
    final lockedCategory = widget.config.lockedCategory;
    if (!widget.config.allowCategorySelection || lockedCategory != null) {
      final displayCategory = lockedCategory ?? _category;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kategori', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: .06),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Icon(categoryIcon(displayCategory ?? ListingCategory.diger)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    displayCategory != null
                        ? categoryLabel(displayCategory)
                        : 'Kategori seçilmedi',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return DropdownButtonFormField<ListingCategory?>(
      key: ValueKey('category-${_category?.name ?? 'all'}'),
      initialValue: _category,
      decoration: const InputDecoration(labelText: 'Kategori'),
      items: [
        const DropdownMenuItem<ListingCategory?>(
          value: null,
          child: Text('Tümü'),
        ),
        ...ListingCategory.values.map(
          (category) => DropdownMenuItem<ListingCategory?>(
            value: category,
            child: Text(categoryLabel(category)),
          ),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _category = value;
          if (value != ListingCategory.arac) {
            _vehicleSubcategory = widget.config.lockedVehicleSubcategory;
            _brand = null;
            _model = null;
            _engineType = null;
          }
        });
      },
    );
  }

  Widget _buildCityDropdown(ThemeData theme) {
    return DropdownButtonFormField<String?>(
      key: ValueKey('city-${_city ?? 'all'}'),
      initialValue: _city,
      decoration: const InputDecoration(labelText: 'Şehir'),
      items: const [
        DropdownMenuItem<String?>(value: null, child: Text('Tümü')),
      ]
          .followedBy(
            kktcCities.map(
              (city) => DropdownMenuItem<String?>(
                value: city,
                child: Text(city),
              ),
            ),
          )
          .toList(),
      onChanged: (value) => setState(() => _city = value),
    );
  }

  Widget _buildPriceSlider(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Fiyat Aralığı', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _minPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Min'),
                onChanged: (value) {
                  _minPrice = value.trim().isEmpty
                      ? null
                      : double.tryParse(value.trim());
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextFormField(
                controller: _maxPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Max'),
                onChanged: (value) {
                  _maxPrice = value.trim().isEmpty
                      ? null
                      : double.tryParse(value.trim());
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVehicleSubcategoryField(ThemeData theme) {
    if (!widget.config.allowVehicleSubcategorySelection &&
        widget.config.lockedVehicleSubcategory != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vasıta Türü', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: .06),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Icon(
                  vehicleCategoryInfoFor(widget.config.lockedVehicleSubcategory!)?.icon ??
                      Icons.directions_car_rounded,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    vehicleSubcategoryLabel(widget.config.lockedVehicleSubcategory!),
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return DropdownButtonFormField<VehicleSubcategory?>(
      key: ValueKey('vehicle-${_vehicleSubcategory?.name ?? 'all'}'),
      initialValue: _vehicleSubcategory,
      decoration: const InputDecoration(labelText: 'Vasıta Türü'),
      items: const [
        DropdownMenuItem<VehicleSubcategory?>(value: null, child: Text('Tümü')),
      ]
          .followedBy(
            vehicleCategoryInfos.map(
              (info) => DropdownMenuItem<VehicleSubcategory?>(
                value: info.type,
                child: Row(
                  children: [
                    Icon(info.icon, size: 18),
                    const SizedBox(width: 8),
                    Text(vehicleSubcategoryLabel(info.type)),
                    if (info.badge != null) ...[
                      const SizedBox(width: 6),
                      Text(info.badge!),
                    ],
                  ],
                ),
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _vehicleSubcategory = value;
          if (value != null) {
            _category = ListingCategory.arac;
          }
          _brand = null;
          _model = null;
          _engineType = null;
        });
      },
    );
  }

  Widget _buildBrandField(ThemeData theme) {
    return DropdownButtonFormField<String?>(
      key: ValueKey('brand-${_brand ?? 'all'}'),
      initialValue: (_brand ?? '').isEmpty ? null : _brand,
      decoration: const InputDecoration(labelText: 'Marka'),
      items: const [
        DropdownMenuItem<String?>(value: null, child: Text('Tümü')),
      ]
          .followedBy(
            carBrands.map(
              (brand) => DropdownMenuItem<String?>(
                value: brand,
                child: Text(brand),
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _brand = value;
          _model = null;
          _engineType = null;
          if (value != null) {
            _category = ListingCategory.arac;
          }
        });
      },
    );
  }

  Widget _buildModelField(ThemeData theme) {
    final models = (carModels[_brand] ?? const <String>[]);
    return DropdownButtonFormField<String?>(
      key: ValueKey('model-${_brand ?? 'none'}-${_model ?? 'all'}'),
      initialValue: (_model ?? '').isEmpty ? null : _model,
      decoration: const InputDecoration(labelText: 'Model'),
      items: const [
        DropdownMenuItem<String?>(value: null, child: Text('Tümü')),
      ]
          .followedBy(
            models.map(
              (model) => DropdownMenuItem<String?>(
                value: model,
                child: Text(model),
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _model = value;
          _engineType = null;
        });
      },
    );
  }

  Widget _buildEngineField(ThemeData theme) {
    final engines =
        (carEngineTypes[_brand]?[(_model ?? '')] ?? const <String>[]);
    if (engines.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: DropdownButtonFormField<String?>(
        key: ValueKey('engine-${_model ?? 'none'}-${_engineType ?? 'all'}'),
        initialValue: (_engineType ?? '').isEmpty ? null : _engineType,
        decoration: const InputDecoration(labelText: 'Motor Tipi'),
        items: const [
          DropdownMenuItem<String?>(value: null, child: Text('Tümü')),
        ]
            .followedBy(
              engines.map(
                (engine) => DropdownMenuItem<String?>(
                  value: engine,
                  child: Text(engine),
                ),
              ),
            )
            .toList(),
        onChanged: (value) => setState(() => _engineType = value),
      ),
    );
  }

  Widget _buildFuelField(ThemeData theme) => DropdownButtonFormField<FuelType?>(
        key: ValueKey('fuel-${_fuelType?.name ?? 'all'}'),
        initialValue: _fuelType,
        decoration: const InputDecoration(labelText: 'Yakıt Tipi'),
        items: const [
          DropdownMenuItem<FuelType?>(value: null, child: Text('Tümü')),
        ]
            .followedBy(
              FuelType.values.map(
                (type) => DropdownMenuItem<FuelType?>(
                  value: type,
                  child: Text(fuelTypeLabel(type)),
                ),
              ),
            )
            .toList(),
        onChanged: (value) => setState(() => _fuelType = value),
      );

  Widget _buildTransmissionField(ThemeData theme) => DropdownButtonFormField<
          TransmissionType?>(
        key: ValueKey('transmission-${_transmission?.name ?? 'all'}'),
        initialValue: _transmission,
        decoration: const InputDecoration(labelText: 'Vites'),
        items: const [
          DropdownMenuItem<TransmissionType?>(value: null, child: Text('Tümü')),
        ]
            .followedBy(
              TransmissionType.values.map(
                (type) => DropdownMenuItem<TransmissionType?>(
                  value: type,
                  child: Text(transmissionLabel(type)),
                ),
              ),
            )
            .toList(),
        onChanged: (value) => setState(() => _transmission = value),
      );

  Widget _buildConditionField(ThemeData theme) => DropdownButtonFormField<
          VehicleCondition?>(
        key: ValueKey('condition-${_condition?.name ?? 'all'}'),
        initialValue: _condition,
        decoration: const InputDecoration(labelText: 'Araç Durumu'),
        items: const [
          DropdownMenuItem<VehicleCondition?>(value: null, child: Text('Tümü')),
        ]
            .followedBy(
              VehicleCondition.values.map(
                (value) => DropdownMenuItem<VehicleCondition?>(
                  value: value,
                  child: Text(vehicleConditionLabel(value)),
                ),
              ),
            )
            .toList(),
        onChanged: (value) => setState(() => _condition = value),
      );

  Widget _buildDrivetrainField(ThemeData theme) => DropdownButtonFormField<Drivetrain?>(
        key: ValueKey('drivetrain-${_drivetrain?.name ?? 'all'}'),
        initialValue: _drivetrain,
        decoration: const InputDecoration(labelText: 'Çekiş'),
        items: const [
          DropdownMenuItem<Drivetrain?>(value: null, child: Text('Tümü')),
        ]
            .followedBy(
              Drivetrain.values.map(
                (value) => DropdownMenuItem<Drivetrain?>(
                  value: value,
                  child: Text(drivetrainLabel(value)),
                ),
              ),
            )
            .toList(),
        onChanged: (value) => setState(() => _drivetrain = value),
      );

  Widget _buildYearInputs(ThemeData theme) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Model Yılı', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _minYearController,
                  decoration: const InputDecoration(labelText: 'Min'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _minYear =
                      value.trim().isEmpty ? null : int.tryParse(value.trim()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _maxYearController,
                  decoration: const InputDecoration(labelText: 'Max'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _maxYear =
                      value.trim().isEmpty ? null : int.tryParse(value.trim()),
                ),
              ),
            ],
          ),
        ],
      );

  Widget _buildMileageInputs(ThemeData theme) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Kilometre', style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _minMileageController,
                  decoration: const InputDecoration(labelText: 'Min'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _minMileage =
                      value.trim().isEmpty ? null : int.tryParse(value.trim()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _maxMileageController,
                  decoration: const InputDecoration(labelText: 'Max'),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => _maxMileage =
                      value.trim().isEmpty ? null : int.tryParse(value.trim()),
                ),
              ),
            ],
          ),
        ],
      );
}
