import 'package:bookstore/User%20End/Cart/checkout.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cart_tile.dart';
import 'cartProvider.dart';

class Cart extends StatelessWidget {
  const Cart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    // Fetch cart data when the widget is built
    cartProvider.fetchCartFromFirestore();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF24375E),
        foregroundColor: Color(0xFFffd482),
        title: Text("My Cart"),
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              height: 600,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: ListView.builder(
                  itemCount: cartProvider.cartItems.length,
                  itemBuilder: (context, index) {
                    return CartTile(cartItem: cartProvider.cartItems[index]);
                  },
                ),
              ),
            ),
          ),
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            decoration: BoxDecoration(
                color: Color(0xFF24375E),
                borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Total Amount : \Rs${cartProvider.calculateTotalPrice()}",
                  style: TextStyle(
                    color: Color(0xFFffd482),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            decoration: BoxDecoration(
                color: Color(0xFF24375E),
                borderRadius: BorderRadius.circular(15)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () {
                    cartProvider.clearCart();
                  },
                  child: Row(
                    children: [
                      Icon(Icons.close, color: Color(0xFFffd482)),
                      SizedBox(width: 10),
                      Text("Clear List",
                          style: TextStyle(
                            color: Color(0xFFffd482),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ))
                    ],
                  ),
                ),
                Container(
                  height: 40,
                  width: 2,
                  color: Color(0xFFffd482),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CheckoutPage(cartProvider: cartProvider),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(Icons.play_arrow, color: Color(0xFFffd482)),
                      SizedBox(width: 10),
                      Text("Go To CheckOut",
                          style: TextStyle(
                            color: Color(0xFFffd482),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ))
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
