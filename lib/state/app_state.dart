import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/car_models.dart';
import '../data/models.dart';
import '../data/repositories.dart';
import '../services/storage_service.dart';
import '../utils/formatters.dart';
import '../data/analytics_repository.dart';

enum SortOption { newest, priceLowToHigh, priceHighToLow }

class AppState extends ChangeNotifier {
  AppState({
    ListingRepository? listingRepository,
    UserRepository? userRepository,
    FirebaseAuth? firebaseAuth,
    StorageService? storageService,
    FirebaseAnalytics? analytics,
    AnalyticsRepository? analyticsRepository,
  })  : repository = listingRepository ?? ListingRepository(),
        _userRepository = userRepository ?? UserRepository(),
        _auth = firebaseAuth ?? FirebaseAuth.instance,
        _storageService = storageService ?? StorageService(),
        _analytics = analytics ?? FirebaseAnalytics.instance,
        _analyticsRepository = analyticsRepository ?? AnalyticsRepository() {
    repository.onChanged = _handleListingsChanged;
    repository.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack,
          reason: 'Listing stream error');
    };

    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      _bootstrapAuthenticatedUser(currentUser);
    }

    _authSubscription = _auth.authStateChanges().listen((user) {
      _handleAuthStateChanged(user);
    });
  }

  final ListingRepository repository;
  final UserRepository _userRepository;
  final FirebaseAuth _auth;
  final StorageService _storageService;
  final FirebaseAnalytics _analytics;
  final AnalyticsRepository _analyticsRepository;

  AppUser? _currentUser;
  bool _isAuthenticated = false;
  bool _isGuestSession = false;

  final Set<String> _favoriteIds = <String>{};
  ThemeMode _themeMode = ThemeMode.light;
  bool showOnboarding = true;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<AppUser?>? _userSubscription;

  ThemeMode get themeMode => _themeMode;
  bool get isAuthenticated => _isAuthenticated;
  AppUser? get currentUser => _currentUser;

  List<Listing> get listings => repository.approvedListings;
  List<Listing> get premiumListings => repository.featuredListings;
  List<Listing> get recentListings => repository.recentListings;

  UnmodifiableSetView<String> get favoriteIds =>
      UnmodifiableSetView(_favoriteIds);

  List<Listing> get favoriteListings => List.unmodifiable(
        repository.listings
            .where((listing) => _favoriteIds.contains(listing.id))
            .toList(),
      );

  List<Listing> listingsByCategory(ListingCategory category) =>
      repository.listingsByCategory(category);

  List<Listing> listingsByVehicleSubcategory(
    VehicleSubcategory subcategory,
  ) =>
      repository.listingsByVehicleSubcategory(subcategory);

  int vehicleSubcategoryCount(VehicleSubcategory subcategory) => repository
      .listingsByVehicleSubcategory(subcategory)
      .length;

  List<Listing> searchListings(String query) => repository.search(query);

  List<Listing> searchInCategory(
    ListingCategory category,
    String query,
  ) =>
      repository.searchInCategory(category, query);

  List<Listing> premiumByCategory(ListingCategory category) =>
      repository.premiumShowcaseByCategory(category);

  List<Listing> myListings() {
    final ownerId = _currentUser?.id;
    if (ownerId == null || ownerId.isEmpty) {
      return const [];
    }
    return repository.listings
        .where((listing) => listing.publisherId == ownerId)
        .toList();
  }

  bool isFavorite(String listingId) => _favoriteIds.contains(listingId);

  Future<void> toggleFavorite(String listingId) async {
    final bool willFavorite = !_favoriteIds.contains(listingId);
    if (willFavorite) {
      _favoriteIds.add(listingId);
    } else {
      _favoriteIds.remove(listingId);
    }
    notifyListeners();

    final listing = _findListing(listingId);

    if (_currentUser != null && !_isGuestSession) {
      try {
        await _userRepository.updateFavorites(
          userId: _currentUser!.id,
          listingId: listingId,
          add: willFavorite,
        );
        if (listing != null) {
          await _analyticsRepository.recordFavorite(
            listingId,
            listing.publisherId,
            willFavorite,
          );
        }
      } catch (error, stack) {
        FirebaseCrashlytics.instance.recordError(
          error,
          stack,
          reason: 'Favori güncellenemedi',
        );
        if (willFavorite) {
          _favoriteIds.remove(listingId);
        } else {
          _favoriteIds.add(listingId);
        }
        notifyListeners();
      }
    }
  }

  Listing? _findListing(String listingId) {
    try {
      return repository.listings
          .firstWhere((listing) => listing.id == listingId);
    } catch (_) {
      return null;
    }
  }

  Future<String> uploadListingImage({
    required XFile file,
    required String listingId,
  }) async {
    final ownerId = _currentUser?.id ?? _auth.currentUser?.uid ?? '';
    return _storageService.uploadListingImage(
      file: file,
      listingId: listingId,
      ownerId: ownerId,
    );
  }

  Future<String> uploadProfileAvatar(XFile file) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw AuthException('Lütfen önce giriş yapın.');
    }
    return _storageService.uploadProfileAvatar(file: file, userId: userId);
  }

  Future<void> removeProfileAvatar() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw AuthException('Lütfen önce giriş yapın.');
    }
    await _storageService.deleteProfileAvatar(userId: userId);
  }

  Future<void> updateUserProfile({
    required String name,
    required String phone,
    String? company,
    String? bio,
    XFile? avatarFile,
    bool removeAvatar = false,
  }) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      throw AuthException('Oturum açmanız gerekiyor.');
    }

    final sanitizedPhone = normalizeTurkishPhone(phone);
    if (sanitizedPhone.isEmpty) {
      throw AuthException('Telefon numarası geçerli değil.');
    }

    String avatarUrl = _currentUser?.avatarUrl ?? '';

    if (avatarFile != null) {
      avatarUrl = await uploadProfileAvatar(avatarFile);
      removeAvatar = false;
    } else if (removeAvatar) {
      await removeProfileAvatar();
      avatarUrl = '';
    }

    final data = {
      'name': name.trim(),
      'phone': sanitizedPhone,
      'company': (company ?? '').trim(),
      'bio': (bio ?? '').trim(),
      'avatarUrl': avatarUrl,
    };

    await _userRepository.updateProfile(firebaseUser.uid, data);
    await firebaseUser.updateDisplayName(name.trim());

    final updatedUser = (_currentUser ?? _mapFirebaseUser(firebaseUser)).copyWith(
      name: name.trim(),
      phone: sanitizedPhone,
      company: (company ?? '').trim(),
      bio: (bio ?? '').trim(),
      avatarUrl: avatarUrl,
    );

    _currentUser = updatedUser;
    notifyListeners();
  }

  Future<void> promoteListing({
    required String listingId,
    required int durationDays,
    required String packageId,
  }) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      throw AuthException('Oturum açmanız gerekiyor.');
    }

    final listing = repository.listings.firstWhere(
      (item) => item.id == listingId,
      orElse: () => throw AuthException('İlan bulunamadı.'),
    );

    if (listing.publisherId != firebaseUser.uid) {
      throw AuthException('Bu ilan size ait değil.');
    }

    final now = DateTime.now();
    final baseDate = (listing.premiumExpiresAt != null &&
            listing.premiumExpiresAt!.isAfter(now))
        ? listing.premiumExpiresAt!
        : now;
    final expiresAt = baseDate.add(Duration(days: durationDays));

    await repository.updateListingFields(listingId, {
      'isPremium': true,
      'premiumPackage': packageId,
      'premiumPurchasedAt': Timestamp.fromDate(now),
      'premiumExpiresAt': Timestamp.fromDate(expiresAt),
    });

    await _analytics.logEvent(
      name: 'listing_promoted',
      parameters: {
        'listing_id': listingId,
        'package': packageId,
        'duration_days': durationDays,
      },
    );
  }

  Future<String?> fetchUserPhone(String userId) async {
    final user = await _userRepository.fetchUser(userId);
    return user?.phone;
  }

  Future<void> recordListingView(Listing listing) async {
    if (listing.publisherId.isEmpty || listing.publisherId == _auth.currentUser?.uid) {
      return;
    }
    try {
      await _analyticsRepository.recordView(listing.id, listing.publisherId);
    } catch (_) {
      // analytics errors are non-critical
    }
  }

  Future<void> recordListingContact(Listing listing) async {
    if (listing.publisherId.isEmpty || listing.publisherId == _auth.currentUser?.uid) {
      return;
    }
    try {
      await _analyticsRepository.recordContact(listing.id, listing.publisherId);
    } catch (_) {
      // ignore
    }
  }

  Future<void> addListing(Listing listing) async {
    if (listing.category == ListingCategory.arac) {
      if ((listing.brand ?? '').isEmpty) {
        throw AuthException('Araç ilanları için marka seçmelisiniz.');
      }
      if ((listing.model ?? '').isEmpty) {
        throw AuthException('Araç ilanları için model seçmelisiniz.');
      }
      if (listing.vehicleSubcategory == null) {
        throw AuthException('Araç ilanları için kategori seçmelisiniz.');
      }
      if (listing.fuelType == null) {
        throw AuthException('Araç ilanları için yakıt tipini seçmelisiniz.');
      }
      if (listing.transmission == null) {
        throw AuthException('Araç ilanları için vites tipini seçmelisiniz.');
      }
      if (listing.condition == null) {
        throw AuthException('Araç ilanları için araç durumunu seçmelisiniz.');
      }
      final engineOptions =
          carEngineTypes[listing.brand]?[listing.model] ?? const <String>[];
      if (engineOptions.isNotEmpty && (listing.engineType ?? '').isEmpty) {
        throw AuthException('Araç ilanları için motor tipi seçmelisiniz.');
      }
    }
    final resolvedPublisherId =
        _auth.currentUser?.uid ?? listing.publisherId.trim();
    final resolvedPublisherName = listing.publisher.trim().isNotEmpty
        ? listing.publisher
        : (_auth.currentUser?.displayName ?? listing.publisher);

    final payload = listing.toMap()
      ..['publisherId'] =
          resolvedPublisherId.isNotEmpty ? resolvedPublisherId : 'guest'
      ..['publisher'] = resolvedPublisherName.trim().isNotEmpty
          ? resolvedPublisherName.trim()
          : 'KKTC Caraba Kullanıcısı';

    var contactPhoneRaw = payload['contactPhone'] as String? ?? '';
    var normalizedContactPhone = normalizeTurkishPhone(contactPhoneRaw);
    if (normalizedContactPhone.isEmpty) {
      normalizedContactPhone = normalizeTurkishPhone(_currentUser?.phone ?? '');
    }
    if (normalizedContactPhone.isEmpty) {
      throw AuthException('Telefon numarası eksik. Lütfen profilinizi güncelleyin.');
    }
    payload['contactPhone'] = normalizedContactPhone;

    await repository.saveListing(listing.id, payload);
    await _analytics.logEvent(
      name: 'listing_created',
      parameters: {
        'listing_id': listing.id,
        'category': listing.category.name,
        'type': listing.type.name,
        'is_premium': listing.isPremium ? 1 : 0,
        if (listing.vehicleSubcategory != null)
          'vehicle_subcategory': listing.vehicleSubcategory!.name,
      },
    );
  }

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  void dismissOnboarding() {
    if (!showOnboarding) return;
    showOnboarding = false;
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    try {
      final normalizedEmail = email.trim().toLowerCase();
      final sanitizedPhone = normalizeTurkishPhone(phone);
      if (sanitizedPhone.isEmpty) {
        throw AuthException('Telefon numarası geçerli değil.');
      }

      final methods = await _auth.fetchSignInMethodsForEmail(normalizedEmail);
      if (methods.isNotEmpty) {
        throw AuthException('Bu e-posta ile kullanıcı zaten mevcut.');
      }

      if (_auth.currentUser != null) {
        await _auth.signOut();
      }

      final credential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(name);
        await user.reload();
        final mapped =
            _mapFirebaseUser(user).copyWith(name: name, phone: sanitizedPhone);
        await _userRepository.ensureUserDocument(mapped);
        await _bootstrapAuthenticatedUser(user);
      }

      _isGuestSession = false;
      showOnboarding = true;
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapAuthError(error, forSignUp: true));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _isGuestSession = false;
      showOnboarding = true;
    } on FirebaseAuthException catch (error) {
      throw AuthException(_mapAuthError(error, forSignUp: false));
    }
  }

  Future<void> signOut() async {
    _isGuestSession = false;
    _favoriteIds.clear();
    showOnboarding = true;
    _userSubscription?.cancel();
    await _auth.signOut();
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> continueAsGuest() async {
    _userSubscription?.cancel();
    _isGuestSession = true;
    _isAuthenticated = true;
    _currentUser = null;
    _favoriteIds.clear();
    showOnboarding = true;
    notifyListeners();

    if (_auth.currentUser != null) {
      await _auth.signOut();
    }
  }

  @override
  void dispose() {
    repository.dispose();
    _authSubscription?.cancel();
    _userSubscription?.cancel();
    super.dispose();
  }

  Future<void> _handleAuthStateChanged(User? user) async {
    if (user != null) {
      await _bootstrapAuthenticatedUser(user);
      return;
    }

    _userSubscription?.cancel();
    _currentUser = null;
    _favoriteIds.clear();
    if (!_isGuestSession) {
      _isAuthenticated = false;
      notifyListeners();
    }
  }

  Future<void> _bootstrapAuthenticatedUser(User user) async {
    final mappedUser = _mapFirebaseUser(user);
    _currentUser = mappedUser;
    _isAuthenticated = true;
    _isGuestSession = false;

    await _userRepository.ensureUserDocument(mappedUser);

    _userSubscription?.cancel();
    _userSubscription = _userRepository.watchUser(user.uid).listen(
      (documentUser) {
        if (documentUser != null) {
          _currentUser = documentUser;
          _favoriteIds
            ..clear()
            ..addAll(documentUser.favorites);
        } else {
          _favoriteIds.clear();
        }
        notifyListeners();
      },
      onError: (error, stackTrace) {
        FirebaseCrashlytics.instance.recordError(
          error,
          stackTrace,
          reason: 'User stream error',
        );
      },
    );

    notifyListeners();
  }

  AppUser _mapFirebaseUser(User user) {
    final displayName = (user.displayName ?? '').trim();
    return AppUser(
      id: user.uid,
      name: displayName.isNotEmpty
          ? displayName
          : (user.email ?? 'KKTC Caraba Kullanıcısı'),
      email: user.email ?? '',
      phone: '',
      company: '',
      bio: '',
      avatarUrl: user.photoURL ?? '',
    );
  }

  void _handleListingsChanged() {
    notifyListeners();
  }

  String _mapAuthError(FirebaseAuthException error, {required bool forSignUp}) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'Bu e-posta ile kullanıcı zaten mevcut.';
      case 'invalid-email':
        return 'Geçerli bir e-posta adresi girin.';
      case 'weak-password':
        return 'Şifre en az 6 karakter olmalı.';
      case 'operation-not-allowed':
        return 'Bu hesap türü için kayıt geçici olarak kapalı.';
      case 'user-disabled':
        return 'Bu kullanıcı hesabı devre dışı bırakılmış.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'E-posta veya şifre hatalı.';
      case 'too-many-requests':
        return 'Çok fazla deneme yaptınız. Lütfen daha sonra tekrar deneyin.';
      default:
        return forSignUp
            ? 'Kayıt sırasında beklenmedik bir hata oluştu. Lütfen tekrar deneyin.'
            : 'Giriş sırasında beklenmedik bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }
}
