import 'models.dart';

class ListingFilters {
  const ListingFilters({
    this.city,
    this.category,
    this.vehicleSubcategory,
    this.brand,
    this.model,
    this.engineType,
    this.minPrice,
    this.maxPrice,
    this.minYear,
    this.maxYear,
    this.minMileage,
    this.maxMileage,
    this.fuelType,
    this.transmission,
    this.condition,
    this.drivetrain,
  });

  final String? city;
  final ListingCategory? category;
  final VehicleSubcategory? vehicleSubcategory;
  final String? brand;
  final String? model;
  final String? engineType;
  final double? minPrice;
  final double? maxPrice;
  final int? minYear;
  final int? maxYear;
  final int? minMileage;
  final int? maxMileage;
  final FuelType? fuelType;
  final TransmissionType? transmission;
  final VehicleCondition? condition;
  final Drivetrain? drivetrain;

  ListingFilters copyWith({
    String? city,
    ListingCategory? category,
    VehicleSubcategory? vehicleSubcategory,
    String? brand,
    String? model,
    String? engineType,
    double? minPrice,
    double? maxPrice,
    int? minYear,
    int? maxYear,
    int? minMileage,
    int? maxMileage,
    FuelType? fuelType,
    TransmissionType? transmission,
    VehicleCondition? condition,
    Drivetrain? drivetrain,
  }) {
    return ListingFilters(
      city: city ?? this.city,
      category: category ?? this.category,
      vehicleSubcategory: vehicleSubcategory ?? this.vehicleSubcategory,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      engineType: engineType ?? this.engineType,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      minYear: minYear ?? this.minYear,
      maxYear: maxYear ?? this.maxYear,
      minMileage: minMileage ?? this.minMileage,
      maxMileage: maxMileage ?? this.maxMileage,
      fuelType: fuelType ?? this.fuelType,
      transmission: transmission ?? this.transmission,
      condition: condition ?? this.condition,
      drivetrain: drivetrain ?? this.drivetrain,
    );
  }
}

class ListingFilterConfig {
  const ListingFilterConfig({
    this.lockedCategory,
    this.allowCategorySelection = true,
    this.lockedVehicleSubcategory,
    this.allowVehicleSubcategorySelection = true,
  });

  final ListingCategory? lockedCategory;
  final bool allowCategorySelection;
  final VehicleSubcategory? lockedVehicleSubcategory;
  final bool allowVehicleSubcategorySelection;
}
