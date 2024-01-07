import 'package:bookstore/User%20End/Wishlist/wishlistProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Wishlist extends StatefulWidget {
  const Wishlist({Key? key}) : super(key: key);

  @override
  State<Wishlist> createState() => _WishlistState();
}

class _WishlistState extends State<Wishlist> {
  @override
  void initState() {
    super.initState();
    // Fetch wishlist data from Firestore when the widget is initialized
    Provider.of<WishlistProvider>(context, listen: false).fetchWishlistFromFirestore();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF24375E),
        foregroundColor: Color(0xFFffd482),
        title: Text('Wishlist'),
      ),
      body: Consumer<WishlistProvider>(
        builder: (context, wishlistProvider, child) {
          // Use the wishlistItems from the WishlistProvider
          List<WishlistItem> wishlistItems = wishlistProvider.wishlistItems;

          return Container(
            color: Colors.grey[100], // Set your desired background color
            child: Padding(
              padding: EdgeInsets.all(16),
              child: ListView.builder(
                itemCount: wishlistItems.length,
                itemBuilder: (BuildContext context, int index) {
                  return WishlistItemWidget(
                    wishlistItem: wishlistItems[index],
                    onRemove: () {
                      // Call removeItemFromWishlist when the remove button is pressed
                      wishlistProvider.removeItemFromWishlist(wishlistItems[index]);
                    },
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class WishlistItemWidget extends StatelessWidget {
  final WishlistItem wishlistItem;
  final VoidCallback onRemove;

  const WishlistItemWidget({
    required this.wishlistItem,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            wishlistItem.imageUrl,
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  wishlistItem.name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('\Rs${wishlistItem.unitPrice.toStringAsFixed(2)}'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: onRemove,
                  icon: Icon(Icons.favorite, color: Colors.red),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
