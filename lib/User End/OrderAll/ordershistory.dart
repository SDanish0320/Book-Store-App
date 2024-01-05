// // order_history.dart
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:bookstore/OrderAll/orderdetails.dart';
// import 'package:bookstore/OrderAll/ordermodel.dart';
// import 'package:bookstore/OrderAll/orderprovider.dart';

// class OrderHistoryPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Order History'),
//       ),
//       body: FutureBuilder<List<Order>>(
//         future: Provider.of<OrdersProvider>(context).fetchOrders(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return CircularProgressIndicator();
//           } else if (snapshot.hasError) {
//             return Text('Error: ${snapshot.error}');
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Text('No orders found.');
//           } else {
//             List<Order> orders = snapshot.data!;
//             return ListView.builder(
//               itemCount: orders.length,
//               itemBuilder: (BuildContext context, int index) {
//                 return ListTile(
//                   title: Text('Order ID: ${orders[index].orderId}'),
//                   subtitle: Text('Order Status: ${orders[index].orderStatus}'),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => OrderDetailsPage(order: orders[index]),
//                       ),
//                     );
//                   },
//                 );
//               },
//             );
//           }
//         },
//       ),
//     );
//   }
// }
