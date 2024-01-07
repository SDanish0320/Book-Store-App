import 'package:bookstore/User%20End/OrderAll/orderdetails.dart';
import 'package:bookstore/User%20End/OrderAll/ordermodel.dart';
import 'package:bookstore/User%20End/OrderAll/orderprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const TextStyle boldTextStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold);
const TextStyle subtitleTextStyle = TextStyle(color: Color(0xFF757575), fontSize: 14);

class OrdersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Color(0xFFffd482),
          title: Text(
            'Orders',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFffd482)),
          ),
          backgroundColor: Color(0xFF24375E),
          bottom: TabBar(
            isScrollable: true,
            labelColor: Colors.white,
            unselectedLabelColor: Color(0xFFffd482),
            indicatorColor: Color(0xFFffd482),
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'InProgress'),
              Tab(text: 'Delivered'),
              Tab(text: 'Cancelled'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrderList(context, 'Pending'),
            _buildOrderList(context, 'In Progress'),
            _buildOrderList(context, 'Delivered'),
            _buildOrderList(context, 'Cancelled'),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, [String? status]) {
    return FutureBuilder(
      future: Provider.of<OrdersProvider>(context, listen: false).fetchOrders(status: status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CustomLoadingIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          List<Order> orders = snapshot.data as List<Order>? ?? [];
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: ListView.builder(
              itemCount: orders.length,
              itemBuilder: (BuildContext context, int index) {
                return CustomOrderCard(order: orders[index]);
              },
            ),
          );
        }
      },
    );
  }
}

class CustomOrderCard extends StatelessWidget {
  final Order order;

  const CustomOrderCard({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: Color(0xFFffd482),
      elevation: 3,
      margin: EdgeInsets.all(8),
      child: ListTile(
        title: Text(
          'Order ID: ${order.orderId}',
          style: boldTextStyle,
        ),
        subtitle: Text(
          'Order Status: ${order.orderStatus}',
          style: subtitleTextStyle,
        ),
        trailing: Tooltip(
          message: 'View Order Details',
          child: IconButton(
            icon: Icon(
              Icons.remove_red_eye,
              color: Color(0xFF24375E),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => OrderDetailsPage(order: order),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
class CustomLoadingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator();
  }
}
