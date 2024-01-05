import 'package:bookstore/User%20End/OrderAll/orderprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:bookstore/User%20End/OrderAll/ordermodel.dart' as CustomOrder;

class OrderDetailsPage extends StatelessWidget {
  final CustomOrder.Order order;

  OrderDetailsPage({required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Order Details',
          style: TextStyle(color: Color(0xFFffd482)),
        ),
        backgroundColor: Color(0xFF24375E),
        foregroundColor: Color(0xFFffd482), // Primary Color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildOrderInfo(),
            SizedBox(height: 16),
            buildOrderItems(context),
          ],
        ),
      ),
    );
  }

  Widget buildOrderInfo() {
    return Card(
      elevation: 4,
      color: Color(0xFFffd482), // Primary Color
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${order.orderId}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Order Status: ${order.orderStatus}',
                style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget buildOrderItems(BuildContext context) {
    return Card(
      elevation: 4,
      color: Color(0xFFffd482), // Primary Color
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Items:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            FutureBuilder(
              future: fetchOrderItems(order.orderId),
              builder: (context,
                  AsyncSnapshot<List<CustomOrder.OrderItem>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.data == null || snapshot.data!.isEmpty) {
                  return Text('No items found.');
                } else {
                  return Column(
                    children: snapshot.data!
                        .map((item) => buildOrderItem(context, item))
                        .toList(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOrderItem(BuildContext context, CustomOrder.OrderItem item) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8),
      color: Color(0xFF24375E),
      child: ListTile(
        title: Text(item.name, style: TextStyle(color: Color(0xFFffd482))),
        subtitle: Text(
          'Price: Rs ${item.unitPrice}',
          style: TextStyle(color: Color(0xFFffd482)),
        ),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(item.imageUrl),
        ),
        trailing: (order.orderStatus == 'Delivered')
            ? IconButton(
                icon: Icon(Icons.rate_review, color: Color(0xFFffd482)),
                onPressed: () {
                  _showReviewDialog(context, order, item);
                },
              )
            : null,
      ),
    );
  }

  Future<List<CustomOrder.OrderItem>> fetchOrderItems(String orderId) async {
    try {
      QuerySnapshot orderItemsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(order.userId) // Replace with the correct path to user document
          .collection('orders')
          .doc(orderId)
          .collection('order_items')
          .get();

      return orderItemsSnapshot.docs.map((doc) {
        Map<String, dynamic> itemData = doc.data() as Map<String, dynamic>;
        return CustomOrder.OrderItem(
          name: itemData['name'],
          unitPrice: itemData['unitPrice'],
          quantity: itemData['quantity'],
          imageUrl: itemData['imageUrl'],
          productId: '',
        );
      }).toList();
    } catch (e) {
      print('Error fetching order items: $e');
      return [];
    }
  }

  Future<void> _showReviewDialog(BuildContext context, CustomOrder.Order order,
      CustomOrder.OrderItem item) async {
    double rating = 0; // Variable to store the selected star rating
    String reviewText = ''; // Variable to store the review text

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Leave a Review'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Product: ${item.name}', // Use item.name here
                  ),
                  SizedBox(height: 16),
                  Text('Rating:'),
                  RatingBar.builder(
                    initialRating: rating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: false,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: const Color.fromARGB(255, 255, 191, 0),
                    ),
                    onRatingUpdate: (newRating) {
                      // Update the rating variable
                      rating = newRating;
                    },
                  ),
                  SizedBox(height: 16),
                  Text('Review:'),
                  TextFormField(
                    maxLines: 3,
                    onChanged: (value) {
                      setState(() {
                        reviewText = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Provider.of<OrdersProvider>(context, listen: false)
                        .leaveReview(
                      order.orderId,
                      item.name, // Use item.name here
                      reviewText,
                      rating.toInt(),
                    );
                    Navigator.pop(context); // Close the dialog
                  },
                  child: Text('Submit'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
