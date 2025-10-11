import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AnalyticsData {
  const AnalyticsData({
    required this.totalViews,
    required this.totalContacts,
    required this.totalFavorites,
    required this.activeListings,
    required this.premiumListings,
    required this.viewsByListing,
    required this.contactsByListing,
    required this.favoritesByListing,
    required this.viewsOverTime,
  });

  final int totalViews;
  final int totalContacts;
  final int totalFavorites;
  final int activeListings;
  final int premiumListings;
  final Map<String, int> viewsByListing;
  final Map<String, int> contactsByListing;
  final Map<String, int> favoritesByListing;
  final Map<String, int> viewsOverTime;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalyticsData &&
          runtimeType == other.runtimeType &&
          totalViews == other.totalViews &&
          totalContacts == other.totalContacts &&
          totalFavorites == other.totalFavorites &&
          activeListings == other.activeListings &&
          premiumListings == other.premiumListings &&
          mapEquals(viewsByListing, other.viewsByListing) &&
          mapEquals(contactsByListing, other.contactsByListing) &&
          mapEquals(favoritesByListing, other.favoritesByListing) &&
          mapEquals(viewsOverTime, other.viewsOverTime);

  @override
  int get hashCode =>
      totalViews.hashCode ^
      totalContacts.hashCode ^
      totalFavorites.hashCode ^
      activeListings.hashCode ^
      premiumListings.hashCode;
}

class AnalyticsRepository {
  AnalyticsRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<AnalyticsData> fetchUserAnalytics(String userId) async {
    try {
      // Analytics koleksiyonundan kullanıcı verilerini çek
      final analyticsDoc = await _firestore
          .collection('analytics')
          .doc(userId)
          .get();

      final data = analyticsDoc.data() ?? <String, dynamic>{};

      // Kullanıcının ilanlarını çek
      final listingsSnapshot = await _firestore
          .collection('listings')
          .where('publisherId', isEqualTo: userId)
          .get();

      final activeListings = listingsSnapshot.docs.where((doc) {
        final status = (doc.data()['status'] as String?) ?? 'approved';
        return status == 'approved';
      }).length;

      final premiumListings = listingsSnapshot.docs.where((doc) {
        final listingData = doc.data();
        final isPremium = listingData['isPremium'] as bool? ?? false;
        final expiresAt = listingData['premiumExpiresAt'] as Timestamp?;
        if (expiresAt != null) {
          return expiresAt.toDate().isAfter(DateTime.now());
        }
        return isPremium;
      }).length;

      // Görüntülenme verilerini parse et
      final viewsByListing = <String, int>{};
      final viewsData = data['viewsByListing'] as Map<String, dynamic>?;
      if (viewsData != null) {
        viewsData.forEach((key, value) {
          viewsByListing[key] = (value as num?)?.toInt() ?? 0;
        });
      }

      // İletişim verilerini parse et
      final contactsByListing = <String, int>{};
      final contactsData = data['contactsByListing'] as Map<String, dynamic>?;
      if (contactsData != null) {
        contactsData.forEach((key, value) {
          contactsByListing[key] = (value as num?)?.toInt() ?? 0;
        });
      }

      // Favori verilerini parse et
      final favoritesByListing = <String, int>{};
      final favoritesData = data['favoritesByListing'] as Map<String, dynamic>?;
      if (favoritesData != null) {
        favoritesData.forEach((key, value) {
          favoritesByListing[key] = (value as num?)?.toInt() ?? 0;
        });
      }

      // Zaman içinde görüntülenme verilerini parse et
      final viewsOverTime = <String, int>{};
      final viewsTimeData = data['viewsOverTime'] as Map<String, dynamic>?;
      if (viewsTimeData != null) {
        viewsTimeData.forEach((key, value) {
          viewsOverTime[key] = (value as num?)?.toInt() ?? 0;
        });
      }

      // Toplam değerleri hesapla
      final totalViews = viewsByListing.values.fold<int>(
        0,
        (sum, val) => sum + val,
      );
      final totalContacts = contactsByListing.values.fold<int>(
        0,
        (sum, val) => sum + val,
      );
      final totalFavorites = favoritesByListing.values.fold<int>(
        0,
        (sum, val) => sum + val,
      );

      return AnalyticsData(
        totalViews: totalViews,
        totalContacts: totalContacts,
        totalFavorites: totalFavorites,
        activeListings: activeListings,
        premiumListings: premiumListings,
        viewsByListing: viewsByListing,
        contactsByListing: contactsByListing,
        favoritesByListing: favoritesByListing,
        viewsOverTime: viewsOverTime,
      );
    } catch (error) {
      // Hata durumunda boş veri döndür
      return const AnalyticsData(
        totalViews: 0,
        totalContacts: 0,
        totalFavorites: 0,
        activeListings: 0,
        premiumListings: 0,
        viewsByListing: {},
        contactsByListing: {},
        favoritesByListing: {},
        viewsOverTime: {},
      );
    }
  }

  Future<void> recordView(String listingId, String publisherId) async {
    try {
      final analyticsRef = _firestore.collection('analytics').doc(publisherId);
      final today = _formatDate(DateTime.now());

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(analyticsRef);

        final data = snapshot.data() ?? <String, dynamic>{};
        final viewsByListing = Map<String, dynamic>.from(
          data['viewsByListing'] as Map<String, dynamic>? ?? {},
        );
        final viewsOverTime = Map<String, dynamic>.from(
          data['viewsOverTime'] as Map<String, dynamic>? ?? {},
        );

        viewsByListing[listingId] =
            ((viewsByListing[listingId] as num?) ?? 0) + 1;
        viewsOverTime[today] = ((viewsOverTime[today] as num?) ?? 0) + 1;

        transaction.set(analyticsRef, {
          'viewsByListing': viewsByListing,
          'viewsOverTime': viewsOverTime,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });
    } catch (error) {
      // Sessizce başarısız ol
    }
  }

  Future<void> recordContact(String listingId, String publisherId) async {
    try {
      final analyticsRef = _firestore.collection('analytics').doc(publisherId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(analyticsRef);

        final data = snapshot.data() ?? <String, dynamic>{};
        final contactsByListing = Map<String, dynamic>.from(
          data['contactsByListing'] as Map<String, dynamic>? ?? {},
        );

        contactsByListing[listingId] =
            ((contactsByListing[listingId] as num?) ?? 0) + 1;

        transaction.set(analyticsRef, {
          'contactsByListing': contactsByListing,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });
    } catch (error) {
      // Sessizce başarısız ol
    }
  }

  Future<void> recordFavorite(
    String listingId,
    String publisherId,
    bool added,
  ) async {
    try {
      final analyticsRef = _firestore.collection('analytics').doc(publisherId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(analyticsRef);

        final data = snapshot.data() ?? <String, dynamic>{};
        final favoritesByListing = Map<String, dynamic>.from(
          data['favoritesByListing'] as Map<String, dynamic>? ?? {},
        );

        final currentCount = (favoritesByListing[listingId] as num?) ?? 0;
        favoritesByListing[listingId] = added
            ? currentCount + 1
            : (currentCount > 0 ? currentCount - 1 : 0);

        transaction.set(analyticsRef, {
          'favoritesByListing': favoritesByListing,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      });
    } catch (error) {
      // Sessizce başarısız ol
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
