import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum ListingType { satilik, kiralik, hizmet, ikinciEl }

enum ListingCategory {
  konut,
  arac,
  emlak,
  elektronik,
  hizmet,
  isFirsati,
  hayvan,
  diger,
}

enum VehicleSubcategory {
  otomobil,
  suvPickup,
  elektrikli,
  motosiklet,
  minivanPanelvan,
  ticari,
  kiralik,
  deniz,
  hasarli,
  karavan,
  klasik,
  hava,
  atv,
}

enum FuelType {
  benzin,
  dizel,
  hibrit,
  elektrik,
  lpg,
  cng,
  diger,
}

enum TransmissionType { manuel, otomatik, yariOtomatik }

enum VehicleCondition { sifir, ikinciEl, hasarli }

enum Drivetrain { ikiCeker, dortCeker, awd, diger }

class ListingTag {
  const ListingTag(this.label, this.iconData);

  final String label;
  final IconData iconData;

  Map<String, dynamic> toMap() => {
        'label': label,
        'icon': iconData.codePoint,
      };

  factory ListingTag.fromMap(Map<String, dynamic> map) => ListingTag(
        map['label'] as String? ?? '',
        IconData(
          map['icon'] as int? ?? Icons.label_rounded.codePoint,
          fontFamily: 'MaterialIcons',
        ),
      );
}

class Listing {
  Listing({
    required this.id,
    required this.title,
    required this.price,
    required this.currency,
    required this.images,
    required this.description,
    required this.category,
    required this.type,
    required this.location,
    required this.date,
    required this.publisher,
    required this.publisherId,
    required this.publisherAvatar,
    required this.isPremium,
    this.vehicleSubcategory,
    this.brand,
    this.model,
    this.engineType,
    this.fuelType,
    this.transmission,
    this.condition,
    this.drivetrain,
    this.bodyType,
    this.power,
    this.rooms,
    this.size,
    this.year,
    this.mileage,
    this.tags = const [],
  });

  final String id;
  final String title;
  final double price;
  final String currency;
  final List<String> images;
  final String description;
  final ListingCategory category;
  final ListingType type;
  final String location;
  final DateTime date;
  final String publisher;
  final String publisherId;
  final String publisherAvatar;
  final bool isPremium;
  final VehicleSubcategory? vehicleSubcategory;
  final String? brand;
  final String? model;
  final String? engineType;
  final FuelType? fuelType;
  final TransmissionType? transmission;
  final VehicleCondition? condition;
  final Drivetrain? drivetrain;
  final String? bodyType;
  final int? power;
  final int? rooms;
  final double? size;
  final int? year;
  final int? mileage;
  final List<ListingTag> tags;

  Map<String, dynamic> toMap() => {
        'title': title,
        'price': price,
        'currency': currency,
        'images': images,
        'description': description,
        'category': category.name,
        'type': type.name,
        'location': location,
        'publishedAt': Timestamp.fromDate(date),
        'publisher': publisher,
        'publisherId': publisherId,
        'publisherAvatar': publisherAvatar,
        'isPremium': isPremium,
        'vehicleSubcategory': vehicleSubcategory?.name,
        'brand': brand,
        'model': model,
        'engineType': engineType,
        'fuelType': fuelType?.name,
        'transmission': transmission?.name,
        'condition': condition?.name,
        'drivetrain': drivetrain?.name,
        'bodyType': bodyType,
        'power': power,
        'rooms': rooms,
        'size': size,
        'year': year,
        'mileage': mileage,
        'tags': tags.map((tag) => tag.toMap()).toList(),
      };

  factory Listing.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return Listing(
      id: doc.id,
      title: data['title'] as String? ?? 'İlan',
      price: (data['price'] as num?)?.toDouble() ?? 0,
      currency: data['currency'] as String? ?? 'TL',
      images: (data['images'] as List<dynamic>? ?? []).cast<String>(),
      description: data['description'] as String? ?? '',
      category: ListingCategory.values.firstWhere(
        (value) => value.name == data['category'],
        orElse: () => ListingCategory.diger,
      ),
      type: ListingType.values.firstWhere(
        (value) => value.name == data['type'],
        orElse: () => ListingType.satilik,
      ),
      location: data['location'] as String? ?? 'KKTC',
      date: (data['publishedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      publisher: data['publisher'] as String? ?? 'Bilinmeyen',
      publisherId: data['publisherId'] as String? ?? '',
      publisherAvatar: data['publisherAvatar'] as String? ?? '',
      isPremium: data['isPremium'] as bool? ?? false,
      vehicleSubcategory: () {
        final type = data['vehicleSubcategory'] as String?;
        if (type == null || type.isEmpty) {
          return null;
        }
        try {
          return VehicleSubcategory.values
              .firstWhere((value) => value.name == type);
        } catch (_) {
          return null;
        }
      }(),
      brand: data['brand'] as String?,
      model: data['model'] as String?,
      engineType: data['engineType'] as String?,
      fuelType: () {
        final value = data['fuelType'] as String?;
        if (value == null || value.isEmpty) return null;
        return FuelType.values.firstWhere(
          (element) => element.name == value,
          orElse: () => FuelType.diger,
        );
      }(),
      transmission: () {
        final value = data['transmission'] as String?;
        if (value == null || value.isEmpty) return null;
        return TransmissionType.values.firstWhere(
          (element) => element.name == value,
          orElse: () => TransmissionType.otomatik,
        );
      }(),
      condition: () {
        final value = data['condition'] as String?;
        if (value == null || value.isEmpty) return null;
        return VehicleCondition.values.firstWhere(
          (element) => element.name == value,
          orElse: () => VehicleCondition.ikinciEl,
        );
      }(),
      drivetrain: () {
        final value = data['drivetrain'] as String?;
        if (value == null || value.isEmpty) return null;
        return Drivetrain.values.firstWhere(
          (element) => element.name == value,
          orElse: () => Drivetrain.diger,
        );
      }(),
      bodyType: data['bodyType'] as String?,
      power: (data['power'] as num?)?.toInt(),
      rooms: (data['rooms'] as num?)?.toInt(),
      size: (data['size'] as num?)?.toDouble(),
      year: (data['year'] as num?)?.toInt(),
      mileage: (data['mileage'] as num?)?.toInt(),
      tags: (data['tags'] as List<dynamic>? ?? [])
          .map((item) => ListingTag.fromMap((item as Map).cast<String, dynamic>()))
          .toList(),
    );
  }
}

class Agent {
  const Agent({
    required this.name,
    required this.phone,
    required this.email,
    required this.company,
    required this.avatarUrl,
    this.isVerified = false,
  });

  final String name;
  final String phone;
  final String email;
  final String company;
  final String avatarUrl;
  final bool isVerified;
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.company = '',
    this.bio = '',
    this.avatarUrl = '',
    this.favorites = const <String>[],
  });

  final String id;
  final String name;
  final String email;
  final String company;
  final String bio;
  final String avatarUrl;
  final List<String> favorites;

  AppUser copyWith({
    String? name,
    String? email,
    String? company,
    String? bio,
    String? avatarUrl,
    List<String>? favorites,
  }) {
    return AppUser(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      company: company ?? this.company,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      favorites: favorites ?? this.favorites,
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'company': company,
        'bio': bio,
        'avatarUrl': avatarUrl,
        'favorites': favorites,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  factory AppUser.fromDocument(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return AppUser(
      id: doc.id,
      name: data['name'] as String? ?? 'Kullanıcı',
      email: data['email'] as String? ?? '',
      company: data['company'] as String? ?? '',
      bio: data['bio'] as String? ?? '',
      avatarUrl: data['avatarUrl'] as String? ?? '',
      favorites: (data['favorites'] as List<dynamic>? ?? []).cast<String>(),
    );
  }
}

class AuthException implements Exception {
  AuthException(this.message);
  final String message;

  @override
  String toString() => message;
}
