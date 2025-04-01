import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

class FirebaseImageHelper {
  static Future<String> getImageUrl(String path) async {
    try {
      if (path.isEmpty) return '';
      if (path.startsWith('http')) return path;

      if (path.startsWith('gs://')) {
        final ref = FirebaseStorage.instance.refFromURL(path);
        return await ref.getDownloadURL();
      } else {
        final ref = FirebaseStorage.instance.ref(path);
        return await ref.getDownloadURL();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting image URL: $e');
      }
      return '';
    }
  }

  static Future<List<String>> getAllImageUrls(Map<String, dynamic> plant) async {
    final urls = <String>[];

    for (var i = 1; i <= 4; i++) {
      final urlKey = 'imageUrl$i';
      if (plant.containsKey(urlKey) && plant[urlKey] != null && plant[urlKey].isNotEmpty) {
        final url = await getImageUrl(plant[urlKey]);
        if (url.isNotEmpty) {
          urls.add(url);
        }
      }
    }

    return urls;
  }
}