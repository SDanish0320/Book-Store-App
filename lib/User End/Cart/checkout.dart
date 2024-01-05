
import 'package:bookstore/User%20End/OrderAll/ordermodel.dart' as OrderModel;
import 'package:bookstore/User%20End/OrderAll/orderprovider.dart';
import 'package:bookstore/User%20End/Cart/cartProvider.dart';
import 'package:bookstore/User%20End/Cart/orderConfirmation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CheckoutPage extends StatelessWidget {
  final CartProvider cartProvider;

  CheckoutPage({required this.cartProvider});

  final TextEditingController _shippingAddressController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF24375E),
      appBar: AppBar(
        title: Text("Checkout"),
        backgroundColor: Color(0xFF24375E),
        foregroundColor: Color(0xFFffd482),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildOrderSummary(),
            SizedBox(height: 16),
            _buildShippingAddress(),
            SizedBox(height: 16),
            _buildTotalPrice(),
            SizedBox(height: 32),
            _buildConfirmPurchaseButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      elevation: 4.0,
      color: Color(0xFFffd482),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Order Summary",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF24375E)),
            ),
            SizedBox(height: 12),
            Container(
              height: 150,
              child: _buildCartItems(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingAddress() {
    return Card(
      elevation: 4.0,
      color: Color(0xFFffd482),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Shipping Address",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF24375E)),
            ),
            SizedBox(height: 12),
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: InkWell(
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _shippingAddressController,
                    expands: true,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: "Enter shipping address",
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                    style: TextStyle(
                      color: Color(0xFF24375E),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalPrice() {
    return Card(
      elevation: 4.0,
      color: Color(0xFFffd482),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TOTAL PRICE',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF24375E)),
            ),
            SizedBox(height: 12),
            Text(
              '\$${cartProvider.calculateTotalPrice().toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF24375E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmPurchaseButton(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        String shippingAddress = _shippingAddressController.text.trim();

        if (shippingAddress.isNotEmpty) {
          // Update shipping address in CartProvider
          cartProvider.shippingAddress = shippingAddress;

          // Create the order document
          String orderId = await cartProvider.createOrder();

          // Add the order to the orders list
          OrderModel.Order newOrder = OrderModel.Order(
            orderId: orderId,
            items: cartProvider.cartItems
                .map((item) => OrderModel.OrderItem(
                      name: item.name,
                      unitPrice: item.unitPrice,
                      quantity: item.quantity,
                      imageUrl: item.imageUrl,
                      productId: '',
                    ))
                .toList(),
            shippingAddress: shippingAddress,
            orderStatus: 'Pending',
            orderDate: DateTime.now(),
            userId: cartProvider.getCurrentUserId(),
          );

          // Add the order to the orders provider
          Provider.of<OrdersProvider>(context, listen: false)
              .addOrder(newOrder);

          // Show a success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Checkout Successful! Order ID: $orderId'),
            ),
          );

          // Clear the cart
          cartProvider.clearCart();

          // Close the checkout page
          Navigator.pop(context);

          // Navigate to the OrderPurchased screen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => OrderPurchased()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please enter a shipping address!'),
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        primary: Color(0xFFffd482),
        padding: EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),
      child: Text(
        "CONFIRM ORDER",
        style: TextStyle(
          fontSize: 18,
          color: Color(0xFF24375E),
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildCartItems() {
    return ListView(
      children: [
        for (var item in cartProvider.cartItems)
          ListTile(
            title: Text(item.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('\Rs ${item.unitPrice}',
                    style: TextStyle(fontSize: 16, color: Color(0xFF24375E))),
                Text('Quantity: ${item.quantity}',
                    style: TextStyle(fontSize: 14, color: Color(0xFF24375E))),
              ],
            ),
          ),
      ],
    );
  }
}
