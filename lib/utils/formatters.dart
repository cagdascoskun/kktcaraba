import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/models.dart';

String formatPrice(double price, String currency) {
  final formatted = price.toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
  return '$formatted $currency';
}

String timeAgo(DateTime date) {
  final Duration difference = DateTime.now().difference(date);

  if (difference.inMinutes < 60) {
    return '${difference.inMinutes} dakika önce';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} saat önce';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} gün önce';
  } else {
    final weeks = difference.inDays ~/ 7;
    if (weeks < 4) {
      return '$weeks hafta önce';
    } else {
      final months = difference.inDays ~/ 30;
      return '$months ay önce';
    }
  }
}

String categoryLabel(ListingCategory category) {
  switch (category) {
    case ListingCategory.konut:
      return 'Konut';
    case ListingCategory.arac:
      return 'Araç';
    case ListingCategory.emlak:
      return 'Arsa & Arazi';
    case ListingCategory.elektronik:
      return 'Elektronik';
    case ListingCategory.hizmet:
      return 'Hizmet';
    case ListingCategory.isFirsati:
      return 'İş Fırsatı';
    case ListingCategory.hayvan:
      return 'Evcil Hayvan';
    case ListingCategory.diger:
      return 'Diğer';
  }
}

IconData categoryIcon(ListingCategory category) {
  switch (category) {
    case ListingCategory.konut:
      return Icons.house_rounded;
    case ListingCategory.arac:
      return Icons.directions_car_rounded;
    case ListingCategory.emlak:
      return Icons.map_rounded;
    case ListingCategory.elektronik:
      return Icons.devices_other_rounded;
    case ListingCategory.hizmet:
      return Icons.handshake_rounded;
    case ListingCategory.isFirsati:
      return Icons.work_outline_rounded;
    case ListingCategory.hayvan:
      return Icons.pets_rounded;
    case ListingCategory.diger:
      return Icons.category_rounded;
  }
}

String listingTypeLabel(ListingType type) {
  switch (type) {
    case ListingType.satilik:
      return 'Satılık';
    case ListingType.kiralik:
      return 'Kiralık';
    case ListingType.hizmet:
      return 'Hizmet';
    case ListingType.ikinciEl:
      return 'İkinci El';
  }
}

String vehicleSubcategoryLabel(VehicleSubcategory subcategory) {
  switch (subcategory) {
    case VehicleSubcategory.otomobil:
      return 'Otomobil';
    case VehicleSubcategory.suvPickup:
      return 'Arazi, SUV & Pickup';
    case VehicleSubcategory.elektrikli:
      return 'Elektrikli Araçlar';
    case VehicleSubcategory.motosiklet:
      return 'Motosiklet';
    case VehicleSubcategory.minivanPanelvan:
      return 'Minivan & Panelvan';
    case VehicleSubcategory.ticari:
      return 'Ticari Araçlar';
    case VehicleSubcategory.kiralik:
      return 'Kiralık Araçlar';
    case VehicleSubcategory.deniz:
      return 'Deniz Araçları';
    case VehicleSubcategory.hasarli:
      return 'Hasarlı Araçlar';
    case VehicleSubcategory.karavan:
      return 'Karavan';
    case VehicleSubcategory.klasik:
      return 'Klasik Araçlar';
    case VehicleSubcategory.hava:
      return 'Hava Araçları';
    case VehicleSubcategory.atv:
      return 'ATV';
  }
}

String fuelTypeLabel(FuelType type) {
  switch (type) {
    case FuelType.benzin:
      return 'Benzin';
    case FuelType.dizel:
      return 'Dizel';
    case FuelType.hibrit:
      return 'Hibrit';
    case FuelType.elektrik:
      return 'Elektrik';
    case FuelType.lpg:
      return 'LPG';
    case FuelType.cng:
      return 'CNG';
    case FuelType.diger:
      return 'Diğer';
  }
}

String transmissionLabel(TransmissionType type) {
  switch (type) {
    case TransmissionType.manuel:
      return 'Manuel';
    case TransmissionType.otomatik:
      return 'Otomatik';
    case TransmissionType.yariOtomatik:
      return 'Yarı Otomatik';
  }
}

String vehicleConditionLabel(VehicleCondition condition) {
  switch (condition) {
    case VehicleCondition.sifir:
      return 'Sıfır';
    case VehicleCondition.ikinciEl:
      return 'İkinci El';
    case VehicleCondition.hasarli:
      return 'Hasarlı';
  }
}

String drivetrainLabel(Drivetrain drivetrain) {
  switch (drivetrain) {
    case Drivetrain.ikiCeker:
      return '2 Çeker';
    case Drivetrain.dortCeker:
      return '4 Çeker';
    case Drivetrain.awd:
      return 'AWD';
    case Drivetrain.diger:
      return 'Diğer';
  }
}

String normalizePhoneNumber(String phone) {
  final digitsOnly = phone.replaceAll(RegExp(r'[^0-9+]'), '');
  if (digitsOnly.startsWith('00')) {
    return digitsOnly.substring(2);
  }
  return digitsOnly;
}

String normalizeTurkishPhone(String phone) {
  var digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return '';
  if (digits.startsWith('00')) {
    digits = digits.substring(2);
  }
  if (digits.startsWith('90') && digits.length > 12) {
    digits = digits.substring(digits.length - 12);
  }
  if (digits.startsWith('90')) {
    digits = digits.substring(2);
  }
  if (digits.startsWith('0')) {
    digits = digits.substring(1);
  }
  if (digits.length > 10) {
    digits = digits.substring(digits.length - 10);
  }
  if (digits.length != 10) {
    return '';
  }
  return '90$digits';
}

String formatTurkishPhone(String phone) {
  final normalized = normalizeTurkishPhone(phone);
  if (normalized.isEmpty) return '';
  final local = normalized.substring(2);
  if (local.length == 10) {
    final part1 = local.substring(0, 3);
    final part2 = local.substring(3, 6);
    final part3 = local.substring(6, 8);
    final part4 = local.substring(8, 10);
    return '+90 $part1 $part2 $part3 $part4';
  }
  return '+90 ${formatPhoneDisplay(local)}';
}

String formatPhoneDisplay(String phone) {
  final normalized = normalizePhoneNumber(phone);
  if (normalized.isEmpty) return '';

  String prefix = '';
  String digits = normalized;
  if (digits.startsWith('+')) {
    prefix = '+';
    digits = digits.substring(1);
  }

  final groups = <String>[];
  for (var i = 0; i < digits.length; i += 3) {
    final end = (i + 3 <= digits.length) ? i + 3 : digits.length;
    groups.add(digits.substring(i, end));
  }

  if (prefix.isNotEmpty) {
    return '$prefix ${groups.join(' ')}';
  }
  return groups.join(' ');
}

Future<void> launchExternalUrl(BuildContext context, Uri uri) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  try {
    final launched =
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      messenger?.showSnackBar(
        const SnackBar(content: Text('Bağlantı açılamadı. Lütfen tekrar deneyin.')),
      );
    }
  } catch (error) {
    messenger?.showSnackBar(
      SnackBar(content: Text('Bağlantı açılamadı: $error')),
    );
  }
}

Future<void> openWhatsApp(
  BuildContext context,
  String phone,
  String message,
) async {
  final normalized = normalizeTurkishPhone(phone);
  if (normalized.isEmpty) {
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
      const SnackBar(content: Text('Telefon numarası bulunamadı.')),
    );
    return;
  }
  final uri = Uri.parse(
    'https://wa.me/$normalized?text=${Uri.encodeComponent(message)}',
  );
  await launchExternalUrl(context, uri);
}
