import 'package:bookstore/Admin/Orders/ordershow.dart';
import 'package:bookstore/Admin/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class OrderUpdate extends StatefulWidget {
  final String userId;
  final String orderId;

  OrderUpdate({required this.userId, required this.orderId});

  @override
  State<OrderUpdate> createState() => _OrderUpdateState();
}

class _OrderUpdateState extends State<OrderUpdate> {
  String _selectedOrderStatus = 'Pending';
  List<String> _orderStatusOptions = [
    'Pending',
    'In Progress',
    'Delivered',
    'Cancelled'
  ];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('orders')
          .doc(widget.orderId)
          .get();

      if (orderSnapshot.exists) {
        setState(() {
          _selectedOrderStatus = orderSnapshot.get('orderStatus') ?? '';
        });
      } else {
        print('Order document with orderId ${widget.orderId} not found.');
      }
    } catch (e) {
      print("Error fetching order data: $e");
    }
  }

  Future<void> updateOrder(BuildContext context) async {
    try {
      // Fetch the latest order data
      DocumentSnapshot orderSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('orders')
          .doc(widget.orderId)
          .get();

      if (orderSnapshot.exists) {
        // Get the current order status
        String currentStatus = orderSnapshot.get('orderStatus') ?? '';

        // Check if the order status is "Delivered" or "Cancelled"
        if (currentStatus == 'Delivered' || currentStatus == 'Cancelled') {
          // Show an alert that the order can't be updated
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: Color(0xFFffd482),
                title: Text(
                  'ERROR',
                  style: TextStyle(
                      color: Color.fromARGB(255, 199, 13, 0),
                      fontWeight: FontWeight.bold),
                ),
                content: Text(
                    'This order has been Delivered or cancelled and cannot be updated.',style: TextStyle(color: Color(0xFF24375E)),),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
          return; // Exit the method without updating
        }
      } else {
        print('Order document with orderId ${widget.orderId} not found.');
        return; // Exit the method if the order document is not found
      }

      // Continue with the update logic
      await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .collection('orders')
          .doc(widget.orderId)
          .update({
        'orderStatus': _selectedOrderStatus,
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color(0xFFffd482),
            title: Text(
              'SUCCESS',
              style: TextStyle(
                  color: Color.fromARGB(255, 0, 175, 6),
                  fontWeight: FontWeight.bold),
            ),
            content: Text(
              'Order updated successfully!',
              style: TextStyle(color: Color(0xFF24375E)),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Navigate to OrderShow page
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderShow(),
                    ),
                  );
                },
                child: Text(
                  'OK',
                  style: TextStyle(color: Color(0xFF24375E)),
                ),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error updating order: $e');

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
              'An error occurred while updating the order. Please try again.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      mybody: Center(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              "Update Order",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text("Order Details", style: TextStyle(fontSize: 18)),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Container(
                width: 450,
                padding: EdgeInsets.only(
                  top: 10,
                ),
                child: Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      // Shipping Address TextField (Removed)
                      SizedBox(
                        height: 10,
                      ),
                      // DropdownButton for Order Status
                      DropdownButton<String>(
                        value: _selectedOrderStatus,
                        onChanged: (String? value) {
                          setState(() {
                            _selectedOrderStatus = value ?? '';
                          });
                        },
                        items: _orderStatusOptions
                            .map((status) => DropdownMenuItem<String>(
                                  value: status,
                                  child: Text(status),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            // Update Button
            Container(
              width: 450,
              child: ElevatedButton(
                onPressed: () {
                  updateOrder(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF24375E),
                  foregroundColor: Color(0xFFffd482),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    'UPDATE',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
