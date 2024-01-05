import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WishlistProvider extends ChangeNotifier {
  List<WishlistItem> _wishlistItems = [];

  List<WishlistItem> get wishlistItems => _wishlistItems;

  void addToWishlist(WishlistItem item) {
    bool alreadyInWishlist =
        _wishlistItems.any((wishlistItem) => wishlistItem.name == item.name);

    if (!alreadyInWishlist) {
      _wishlistItems.add(item);
      saveWishlistToFirestore();
    }

    notifyListeners();
  }

  void removeItemFromWishlist(WishlistItem item) {
    _wishlistItems.removeWhere((wishlistItem) => wishlistItem.name == item.name);
    removeItemFromFirestore(item);
    notifyListeners();
  }


  void saveWishlistToFirestore() async {
    try {
      String userId = getCurrentUserId();

      if (userId.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('wishlist')
            .doc('user_wishlist')
            .set({
          'wishlistItems': _wishlistItems
              .map((item) => {
                    'name': item.name,
                    'unitPrice': item.unitPrice,
                    'imageUrl': item.imageUrl,
                  })
              .toList(),
        });
      }
    } catch (e) {
      print('Error saving wishlist to Firestore: $e');
    }
  }

  void removeItemFromFirestore(WishlistItem item) async {
    try {
      String userId = getCurrentUserId();

      if (userId.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('wishlist')
            .doc('user_wishlist')
            .update({
          'wishlistItems': _wishlistItems
              .map((item) => {
                    'name': item.name,
                    'unitPrice': item.unitPrice,
                    'imageUrl': item.imageUrl,
                  })
              .toList(),
        });
      }
    } catch (e) {
      print('Error removing item from Firestore: $e');
    }
  }

  Future<void> fetchWishlistFromFirestore() async {
    try {
      String userId = getCurrentUserId();

      if (userId.isNotEmpty) {
        DocumentSnapshot wishlistSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('wishlist')
            .doc('user_wishlist')
            .get();

        if (wishlistSnapshot.exists) {
          Map<String, dynamic>? wishlistData = wishlistSnapshot.data() as Map<String, dynamic>?;

          if (wishlistData != null && wishlistData.containsKey('wishlistItems')) {
            dynamic wishlistItemsData = wishlistData['wishlistItems'];

            if (wishlistItemsData is List<dynamic>) {
              _wishlistItems = wishlistItemsData
                  .map((itemData) => WishlistItem(
                        name: itemData['name'],
                        unitPrice: itemData['unitPrice'],
                        imageUrl: itemData['imageUrl'],
                      ))
                  .toList();
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching wishlist from Firestore: $e');
    }
    notifyListeners();
  }

  String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }
}

class WishlistItem {
  final String name;
  final double unitPrice;
  final String imageUrl;

  WishlistItem({
    required this.name,
    required this.unitPrice,
    required this.imageUrl,
  });
}
