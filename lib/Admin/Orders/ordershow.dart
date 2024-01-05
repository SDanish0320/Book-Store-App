import 'package:bookstore/Common/Custom%20Loader/customloader.dart';
import 'package:bookstore/User%20End/OrderAll/ordermodel.dart' as CustomOrder;
import 'package:bookstore/Admin/Orders/orderupdate.dart';
import 'package:bookstore/Admin/drawer.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: OrderShow(),
  ));
}

class OrderShow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      mybody: MyListView(),
    );
  }
}

class MyListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CustomOrder.Order>>(
      future: fetchOrders(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CustomLoader(
              message: "Organizing Book Orders...",
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error loading orders'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text('No orders available'),
          );
        } else {
          var orders = snapshot.data!;
          orders.sort((a, b) {
            // Custom order of statuses for sorting
            List<String> statusOrder = [
              'Pending',
              'In Progress',
              'Delivered',
              'Cancelled'
            ];

            int statusIndexA = statusOrder.indexOf(a.orderStatus);
            int statusIndexB = statusOrder.indexOf(b.orderStatus);

            // Compare the order status indices
            return statusIndexA.compareTo(statusIndexB);
          });
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];

              return Card(
                margin: EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                color: Color(0xFFffd482),
                child: ListTile(
                  title: Text('Order ID: ${order.orderId}',
                      style: TextStyle(color: Color(0xFF24375E))),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Shipping Address: ${order.shippingAddress}',
                          style: TextStyle(color: Color(0xFF24375E))),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Order Status: ',
                              style: TextStyle(color: Color(0xFF24375E)),
                            ),
                            TextSpan(
                              text: order.orderStatus,
                              style: TextStyle(
                                color: getOrderStatusColor(order.orderStatus),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrderUpdate(
                                userId: order.userId,
                                orderId: order.orderId,
                              ),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.remove_red_eye, color: Colors.green),
                        onPressed: () {
                          // Open the order details dialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return OrderDetailsDialog(order: order);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  Future<List<CustomOrder.Order>> fetchOrders() async {
    try {
      QuerySnapshot userSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      List<CustomOrder.Order> orders = [];

      for (QueryDocumentSnapshot userDoc in userSnapshot.docs) {
        QuerySnapshot orderSnapshot = await userDoc.reference
            .collection('orders')
            .orderBy('timestamp', descending: true)
            .get();

        for (QueryDocumentSnapshot orderDoc in orderSnapshot.docs) {
          // Extract orderId from the orderDoc ID
          String orderId = orderDoc.id;

          // Fetch order items
          QuerySnapshot orderItemsSnapshot = await orderDoc.reference
              .collection('order_items')
              .get(); // Updated to 'order_items'

          // Extract order items data
          List<Map<String, dynamic>> orderItemsData = orderItemsSnapshot.docs
              .map((itemDoc) => (itemDoc.data() as Map<String, dynamic>))
              .toList();

          List<CustomOrder.OrderItem> orderItems = orderItemsData
              .map((itemData) => CustomOrder.OrderItem(
                    name: itemData['name'],
                    unitPrice: itemData['unitPrice'],
                    quantity: itemData['quantity'],
                    imageUrl: itemData['imageUrl'] ?? '',
                    productId: '', // Add imageUrl with a default value
                  ))
              .toList();

          CustomOrder.Order order = CustomOrder.Order(
            orderId: orderId,
            shippingAddress: orderDoc['shippingAddress'],
            orderStatus: orderDoc['orderStatus'],
            items: orderItems,
            orderDate: (orderDoc['timestamp'] as Timestamp).toDate(),
            userId: userDoc.id,
          );

          orders.add(order);
        }
      }

      return orders;
    } catch (e) {
      print('Error fetching orders: $e');
      // Return an empty list to handle the error gracefully
      return [];
    }
  }

  Color getOrderStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange; // Set your desired color for 'Pending'
      case 'In Progress':
        return Colors.blue; // Set your desired color for 'In Progress'
      case 'Delivered':
        return Colors.green; // Set your desired color for 'Delivered'
      case 'Cancelled':
        return Colors.red; // Set your desired color for 'Cancelled'
      default:
        return Colors.black; // Default color for unknown status
    }
  }
}

class OrderDetailsDialog extends StatelessWidget {
  final CustomOrder.Order order;

  OrderDetailsDialog({required this.order});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Dialog(
        backgroundColor: Color(0xFFffd482), // Dialog background color
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Order ID: ${order.orderId}',
                  style: TextStyle(color: Color(0xFF24375E))),
              SizedBox(height: 5),
              Text('Shipping Address: ${order.shippingAddress}',
                  style: TextStyle(color: Color(0xFF24375E))),
              SizedBox(height: 5),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Order Status: ',
                      style: TextStyle(color: Color(0xFF24375E)),
                    ),
                    TextSpan(
                      text: order.orderStatus,
                      style: TextStyle(
                          color: getOrderStatusColor(order.orderStatus),
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5),
              Text('Order Items:', style: TextStyle(color: Color(0xFF24375E))),
              SizedBox(height: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: order.items.map((item) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('BOOK NAME: ${item.name}',
                          style: TextStyle(
                              color: Color(0xFF24375E),
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text('Quantity: ${item.quantity}',
                          style: TextStyle(color: Color(0xFF24375E))),
                      SizedBox(height: 5),
                      Text('Price: RS ${item.unitPrice}',
                          style: TextStyle(color: Color(0xFF24375E))),
                      SizedBox(height: 5),
                      Image.network(item.imageUrl),
                      SizedBox(height: 5), // Displaying the image
                    ],
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color getOrderStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange; // Set your desired color for 'Pending'
      case 'In Progress':
        return Colors.blue; // Set your desired color for 'In Progress'
      case 'Delivered':
        return Colors.green; // Set your desired color for 'Delivered'
      case 'Cancelled':
        return Colors.red; // Set your desired color for 'Cancelled'
      default:
        return Colors.black; // Default color for unknown status
    }
  }
}
