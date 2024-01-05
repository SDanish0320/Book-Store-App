import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bookstore/User%20End/OrderAll/ordermodel.dart' as OrderModel;

class OrdersProvider extends ChangeNotifier {
  List<OrderModel.Order> _orders = [];

  List<OrderModel.Order> get orders => _orders;

  void addOrder(OrderModel.Order order) {
    _orders.add(order);
    notifyListeners();
  }

  Future<List<OrderModel.Order>> fetchOrders({String? status}) async {
    try {
      String userId = getCurrentUserId();
      if (userId.isNotEmpty) {
        QuerySnapshot orderSnapshot;

        if (status != null) {
          // Fetch orders with a specific status
          orderSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('orders')
              .where('orderStatus', isEqualTo: status)
              .get();
        } else {
          // Fetch all orders
          orderSnapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('orders')
              .get();
        }

        List<Future<OrderModel.Order>> orderFutures = orderSnapshot.docs.map((doc) async {
          Map<String, dynamic> orderData = doc.data() as Map<String, dynamic>;
          return OrderModel.Order(
            orderId: doc.id,
            shippingAddress: orderData['shippingAddress'],
            orderStatus: orderData['orderStatus'],
            items: await fetchOrderItems(doc.id), // Fetch items for each order
            orderDate: (orderData['timestamp'] as Timestamp).toDate(),
            userId: userId,
          );
        }).toList();

        _orders = await Future.wait(orderFutures);
        notifyListeners();
      }
    } catch (e) {
      print('Error fetching orders: $e');
    }

    return _orders;
  }

  Future<List<OrderModel.OrderItem>> fetchOrderItems(String orderId) async {
    try {
      QuerySnapshot orderItemsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(getCurrentUserId())
          .collection('orders')
          .doc(orderId)
          .collection('order_items')
          .get();

      List<OrderModel.OrderItem> orderItems = [];

      for (QueryDocumentSnapshot doc in orderItemsSnapshot.docs) {
        Map<String, dynamic> itemData = doc.data() as Map<String, dynamic>;
        String productName = itemData['name'];

        OrderModel.OrderItem orderItem = OrderModel.OrderItem(
          name: productName,
          unitPrice: (itemData['unitPrice'] as num).toDouble(),
          quantity: (itemData['quantity'] as num).toInt(),
          imageUrl: itemData['imageUrl'] as String,
          productId: doc.id,
        );

        orderItems.add(orderItem);
      }

      return orderItems;
    } catch (e) {
      print('Error fetching order items: $e');
      return [];
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(getCurrentUserId())
          .collection('orders')
          .doc(orderId)
          .update({
        'orderStatus': newStatus,
      });
      await fetchOrders(); // Refresh the order list after updating the status
    } catch (e) {
      print('Error updating order status: $e');
    }
  }

  String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  Future<void> leaveReview(
      String orderId, String productName, String reviewText, int rating) async {
    OrderModel.Order? order = getOrderById(orderId);
    if (order != null) {
      if (!userHasReviewed(order.userId, productName)) {
        await saveReview(orderId, productName, reviewText, rating);
        order.reviews.add(OrderModel.Review(
          orderId: orderId,
          userId: order.userId,
          reviewText: reviewText,
          rating: rating,
          productName: productName,
        ));
        notifyListeners();
      } else {
        print('You have already reviewed this product.');
      }
    } else {
      print('You can only review Delivered orders.');
    }
  }

  bool userHasReviewed(String userId, String productName) {
    return orders.any((order) =>
        order.userId == userId &&
        order.reviews.any((review) => review.productName == productName));
  }

  Future<void> saveReview(
      String orderId, String productName, String reviewText, int rating) async {
    try {
      await FirebaseFirestore.instance.collection('reviews').add({
        'orderId': orderId,
        'userId': getCurrentUserId(),
        'reviewText': reviewText,
        'rating': rating,
        'productName': productName,
      });
    } catch (e) {
      print('Error saving review: $e');
    }
  }

  OrderModel.Order getOrderById(String orderId) {
    try {
      return orders.firstWhere(
        (order) => order.orderId == orderId,
        orElse: () => OrderModel.Order(
          orderId: '',
          shippingAddress: '',
          orderStatus: '',
          items: [],
          orderDate: DateTime.now(),
          userId: '',
          reviews: [], // Make sure to include reviews or adjust the constructor accordingly
        ),
      );
    } catch (e) {
      print('Error getting order by ID: $e');
      throw e; // Rethrow the exception after printing
    }
  }
}
