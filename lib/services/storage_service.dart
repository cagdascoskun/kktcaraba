import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

class StorageService {
  StorageService({FirebaseStorage? firebaseStorage})
      : _storage = firebaseStorage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  Future<String> uploadListingImage({
    required XFile file,
    required String listingId,
    required String ownerId,
  }) async {
    final sanitizedName = file.name.replaceAll(RegExp(r'[^A-Za-z0-9_.-]'), '_');
    final ref = _storage
        .ref()
        .child('listing_images')
        .child(ownerId.isEmpty ? 'guest' : ownerId)
        .child(listingId)
        .child(sanitizedName);

    final resolvedMime = file.mimeType ?? lookupMimeType(file.path) ?? 'image/jpeg';

    UploadTask uploadTask;
    if (kIsWeb) {
      final bytes = await file.readAsBytes();
      uploadTask = ref.putData(
        bytes,
        SettableMetadata(contentType: resolvedMime),
      );
    } else {
      uploadTask = ref.putFile(
        File(file.path),
        SettableMetadata(contentType: resolvedMime),
      );
    }

    final snapshot = await uploadTask.whenComplete(() {});
    return snapshot.ref.getDownloadURL();
  }
}
