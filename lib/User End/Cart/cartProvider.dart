import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _cartItems = [];

  List<CartItem> get cartItems => _cartItems;

  void addToCart(CartItem item) {
    bool alreadyInCart =
        _cartItems.any((cartItem) => cartItem.name == item.name);

    if (alreadyInCart) {
      _cartItems.forEach((cartItem) {
        if (cartItem.name == item.name) {
          cartItem.quantity += 1;
        }
      });
    } else {
      _cartItems.add(item);
    }

    notifyListeners();
    saveCartToFirestore();
  }

  void incrementQuantity(CartItem item) {
    final cartItem =
        _cartItems.firstWhere((cartItem) => cartItem.name == item.name);
    cartItem.quantity += 1;
    notifyListeners();
    saveCartToFirestore();
  }

  void decrementQuantity(CartItem item) {
    final cartItem =
        _cartItems.firstWhere((cartItem) => cartItem.name == item.name);
    cartItem.quantity =
        (cartItem.quantity - 1).clamp(0, double.infinity).toInt();
    notifyListeners();
    saveCartToFirestore();
  }

  void removeItemFromCart(CartItem item) {
    _cartItems.removeWhere((cartItem) => cartItem.name == item.name);
    notifyListeners();
    saveCartToFirestore();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
    saveCartToFirestore();
  }

  double calculateTotalPrice() {
    double total = 0.0;
    _cartItems.forEach((item) {
      total += item.quantity * item.unitPrice;
    });
    return total;
  }

  void saveCartToFirestore() async {
    try {
      String userId = getCurrentUserId();

      if (userId.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('cart')
            .doc('user_cart')
            .set({
          'cartItems': _cartItems
              .map((item) => {
                    'name': item.name,
                    'quantity': item.quantity,
                    'unitPrice': item.unitPrice,
                    'imageUrl': item.imageUrl,
                  })
              .toList(),
        });
      }
    } catch (e) {
      print('Error saving cart to Firestore: $e');
    }
  }

  Future<void> fetchCartFromFirestore() async {
    try {
      String userId = getCurrentUserId();

      if (userId.isNotEmpty) {
        DocumentSnapshot cartSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('cart')
            .doc('user_cart')
            .get();

        if (cartSnapshot.exists) {
          Map<String, dynamic>? cartData =
              cartSnapshot.data() as Map<String, dynamic>?;

          if (cartData != null) {
            dynamic cartItemsData = cartData['cartItems'];

            if (cartItemsData is List<dynamic>) {
              _cartItems = cartItemsData
                  .map((itemData) => CartItem(
                        name: itemData['name'],
                        quantity: itemData['quantity'],
                        unitPrice: itemData['unitPrice'],
                        imageUrl: itemData['imageUrl'],
                      ))
                  .toList();
            }
          }
        }
      }
    } catch (e) {
      print('Error fetching cart from Firestore: $e');
    }
    notifyListeners();
  }

  String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  String _shippingAddress = '';

  String get shippingAddress => _shippingAddress;

  set shippingAddress(String address) {
    _shippingAddress = address;
    notifyListeners();
  }

  Future<String> createOrder() async {
  try {
    String userId = getCurrentUserId();
    if (userId.isNotEmpty) {
      // Calculate or set orderStatus based on your logic
      String orderStatus = 'Pending'; // Change this based on your requirements

      // Create the order document
      DocumentReference orderRef = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('orders')
          .add({
        'timestamp': FieldValue.serverTimestamp(),
        'shippingAddress': shippingAddress,
        'orderStatus': orderStatus,
      });

      // Create order_item documents
      for (var item in cartItems) {
        await orderRef.collection('order_items').add({
          'name': item.name,
          'quantity': item.quantity,
          'unitPrice': item.unitPrice,
          'imageUrl': item.imageUrl,
        });
      }

      // Return the order ID
      return orderRef.id;
    }

    // Return empty string if user ID is not available
    throw Exception('User ID is empty');
  } catch (e) {
    print('Error creating order: $e');
    throw Exception('Failed to create order: $e');
  }
}

}

class CartItem {
  final String name;
  int quantity;
  final double unitPrice;
  final String imageUrl;

  CartItem({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.imageUrl,
  });
}
