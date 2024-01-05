import 'package:bookstore/Admin/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: Admin()));
}

class Admin extends StatelessWidget {
  const Admin({super.key});

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(mybody: MyGridView());
  }
}

class MyGridView extends StatefulWidget {
  @override
  _MyGridViewState createState() => _MyGridViewState();
}

class _MyGridViewState extends State<MyGridView> {
  int userCount = 0;
  int authorCount = 0;
  int productCount = 0;
  int categoryCount = 0;
  int orderCount = 0;
  int orderItemCount = 0;
  int wishlistCount = 0;
  int reviewCount = 0;

  @override
  void initState() {
    super.initState();
    // Fetch counts when the widget is initialized
    fetchCounts();
  }

  Future<void> fetchCounts() async {
    try {
      userCount = await getCollectionCount('users');
      authorCount = await getCollectionCount('author');
      productCount = await getCollectionCount('product');
      categoryCount = await getCollectionCount('category');
      orderCount = await getCollectionCount('orders');
      orderItemCount = await getCollectionCount('order_items');
      wishlistCount = await getCollectionCount('wishlist');
      reviewCount = await getCollectionCount('review');

      // Update the UI with the new counts
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error fetching counts: $e');
    }
  }

  Future<int> getCollectionCount(String collectionName) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collectionGroup(collectionName)
        .get();

    return querySnapshot.size;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.0,
      padding: EdgeInsets.all(16.0),
      children: <Widget>[
        _buildCategoryContainer(context, 'Users', Icons.person, userCount),
        _buildCategoryContainer(context, 'Author', Icons.edit, authorCount),
        _buildCategoryContainer(context, 'Products', Icons.shopping_cart, productCount),
        _buildCategoryContainer(context, 'Category', Icons.category, categoryCount),
        _buildCategoryContainer(context, 'Orders', Icons.assignment, orderCount),
        _buildCategoryContainer(context, 'Order Items', Icons.assignment_turned_in, orderItemCount),
        _buildCategoryContainer(context, 'Wishlist', Icons.favorite, wishlistCount),
        _buildCategoryContainer(context, 'Review', Icons.star, reviewCount),
      ],
    );
  }

  Widget _buildCategoryContainer(BuildContext context, String categoryName, IconData icon, int itemCount) {
    return InkWell(
      onTap: () {
        
      },
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xFF24375E),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
                color: Color(0xFFffd482),
              ),
              SizedBox(height: 10),
              Text(categoryName, style: TextStyle(color: Color(0xFFffd482))),
              SizedBox(height: 5),
              Text('$itemCount', style: TextStyle(color: Color(0xFFffd482))),
            ],
          ),
        ),
      ),
    );
  }
}
