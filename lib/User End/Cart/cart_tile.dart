import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'cartProvider.dart';

class CartTile extends StatelessWidget {
  final CartItem cartItem;

  const CartTile({required this.cartItem, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        color: Colors.amber.withOpacity(0.3),
        child: Row(
          children: [
            Consumer<CartProvider>(
              builder: (context, cartProvider, child) {
                return Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: Image.network(cartItem.imageUrl, width: 100),
                  ),
                );
              },
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cartItem.name, maxLines: 2),
                  SizedBox(height: 4),
                  
                  Text("Price: \Rs${cartItem.quantity * cartItem.unitPrice}"),
                  SizedBox(height: 5),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    Provider.of<CartProvider>(context, listen: false)
                        .incrementQuantity(cartItem);
                  },
                ),
                Text('${cartItem.quantity}'),
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () {
                    Provider.of<CartProvider>(context, listen: false)
                        .decrementQuantity(cartItem);
                  },
                ),
              ],
            ),
            SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}
