import 'package:flutter/material.dart';

import 'models.dart';

class VehicleCategoryInfo {
  const VehicleCategoryInfo({
    required this.type,
    required this.icon,
    this.badge,
  });

  final VehicleSubcategory type;
  final IconData icon;
  final String? badge;
}

const List<VehicleCategoryInfo> vehicleCategoryInfos = [
  VehicleCategoryInfo(
    type: VehicleSubcategory.otomobil,
    icon: Icons.directions_car_filled_rounded,
  ),
  VehicleCategoryInfo(
    type: VehicleSubcategory.suvPickup,
    icon: Icons.directions_car_filled_outlined,
  ),
  VehicleCategoryInfo(
    type: VehicleSubcategory.elektrikli,
    icon: Icons.electric_car_rounded,
    badge: '🌿',
  ),
  VehicleCategoryInfo(
    type: VehicleSubcategory.motosiklet,
    icon: Icons.two_wheeler_rounded,
  ),
  VehicleCategoryInfo(
    type: VehicleSubcategory.minivanPanelvan,
    icon: Icons.directions_bus_filled_rounded,
  ),
  VehicleCategoryInfo(
    type: VehicleSubcategory.ticari,
    icon: Icons.local_shipping_rounded,
  ),
  VehicleCategoryInfo(
    type: VehicleSubcategory.kiralik,
    icon: Icons.key_rounded,
  ),
  VehicleCategoryInfo(
    type: VehicleSubcategory.deniz,
    icon: Icons.sailing_rounded,
  ),
  VehicleCategoryInfo(
    type: VehicleSubcategory.hasarli,
    icon: Icons.build_circle_rounded,
  ),
  VehicleCategoryInfo(
    type: VehicleSubcategory.karavan,
    icon: Icons.rv_hookup_rounded,
  ),
  VehicleCategoryInfo(
    type: VehicleSubcategory.klasik,
    icon: Icons.auto_awesome_rounded,
  ),
  VehicleCategoryInfo(
    type: VehicleSubcategory.hava,
    icon: Icons.flight_rounded,
  ),
  VehicleCategoryInfo(
    type: VehicleSubcategory.atv,
    icon: Icons.offline_bolt_rounded,
  ),
];

VehicleCategoryInfo? vehicleCategoryInfoFor(VehicleSubcategory type) {
  for (final info in vehicleCategoryInfos) {
    if (info.type == type) {
      return info;
    }
  }
  return null;
}
