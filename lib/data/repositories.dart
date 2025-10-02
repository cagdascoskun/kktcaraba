import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'models.dart';

class ListingRepository {
  ListingRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance {
    _subscription = _collection
        .orderBy('publishedAt', descending: true)
        .snapshots()
        .listen(_onSnapshot, onError: _handleSnapshotError);
  }

  final FirebaseFirestore _firestore;
  final List<Listing> _listings = <Listing>[];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  void Function(Object error, StackTrace stackTrace)? onError;
  VoidCallback? onChanged;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('listings');

  List<Listing> get listings => List.unmodifiable(_listings);

  List<Listing> get featuredListings =>
      _listings.where((listing) => listing.isPremium).toList();

  List<Listing> get recentListings => List<Listing>.from(_listings);

  List<Listing> listingsByCategory(ListingCategory category) => _listings
      .where((listing) => listing.category == category)
      .toList();

  List<Listing> listingsByVehicleSubcategory(
    VehicleSubcategory subcategory,
  ) =>
      _listings
          .where(
            (listing) =>
                listing.category == ListingCategory.arac &&
                listing.vehicleSubcategory == subcategory,
          )
          .toList();

  List<Listing> premiumShowcaseByCategory(ListingCategory category) => _listings
      .where((listing) => listing.category == category && listing.isPremium)
      .toList();

  List<Listing> search(String query) {
    final cleanQuery = query.toLowerCase().trim();
    if (cleanQuery.isEmpty) {
      return List<Listing>.from(_listings);
    }
    return _listings.where((listing) {
      final haystack = '${listing.title} ${listing.description} ${listing.location}'.
          toLowerCase();
      return haystack.contains(cleanQuery);
    }).toList();
  }

  List<Listing> searchInCategory(ListingCategory category, String query) {
    final cleanQuery = query.toLowerCase().trim();
    if (cleanQuery.isEmpty) {
      return listingsByCategory(category);
    }
    return listingsByCategory(category)
        .where((listing) {
          final haystack = '${listing.title} ${listing.description}'.toLowerCase();
          return haystack.contains(cleanQuery);
        })
        .toList();
  }

  Future<void> addListing(Listing listing) async {
    await saveListing(listing.id, listing.toMap());
  }

  Future<void> saveListing(String listingId, Map<String, dynamic> data) async {
    await _collection.doc(listingId).set(data);
  }

  Future<void> updateListing(Listing listing) async {
    await _collection.doc(listing.id).update(listing.toMap());
  }

  Future<void> deleteListing(String listingId) async {
    await _collection.doc(listingId).delete();
  }

  String generateListingId() => _collection.doc().id;

  void _onSnapshot(QuerySnapshot<Map<String, dynamic>> snapshot) {
    final updated = snapshot.docs
        .map(Listing.fromDocument)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    _listings
      ..clear()
      ..addAll(updated);

    onChanged?.call();
  }

  void _handleSnapshotError(Object error, StackTrace stackTrace) {
    onError?.call(error, stackTrace);
  }

  void dispose() {
    _subscription?.cancel();
  }
}

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('users');

  Future<void> ensureUserDocument(AppUser user) async {
    final docRef = _collection.doc(user.id);
    final Map<String, dynamic> payload = {
      'name': user.name,
      'email': user.email,
      'company': user.company,
      'bio': user.bio,
      'avatarUrl': user.avatarUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };

    if (user.favorites.isNotEmpty) {
      payload['favorites'] = FieldValue.arrayUnion(user.favorites);
    }

    await docRef.set(payload, SetOptions(merge: true));
  }

  Stream<AppUser?> watchUser(String userId) => _collection.doc(userId).snapshots().map(
        (snapshot) =>
            snapshot.exists ? AppUser.fromDocument(snapshot) : null,
      );

  Future<void> updateFavorites({
    required String userId,
    required String listingId,
    required bool add,
  }) async {
    final updateValue = add
        ? FieldValue.arrayUnion(<String>[listingId])
        : FieldValue.arrayRemove(<String>[listingId]);
    await _collection.doc(userId).update({'favorites': updateValue});
  }

  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    await _collection.doc(userId).update(data);
  }
}

class AgentRepository {
  AgentRepository();

  final List<Agent> _agents = const [];

  List<Agent> get agents => List.unmodifiable(_agents);
}
