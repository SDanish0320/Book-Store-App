import 'package:bookstore/User%20End/OrderAll/order.dart';
import 'package:bookstore/User%20End/Cart/cart.dart';
import 'package:bookstore/User%20End/Profile/profile.dart';
import 'package:bookstore/User%20End/Wishlist/wishlistuser.dart';
import 'package:bookstore/logout.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeAppBar extends StatefulWidget {
  @override
  State<HomeAppBar> createState() => _HomeAppBarState();
}

class _HomeAppBarState extends State<HomeAppBar> {
  String? profileImageUrl;

  @override
  void initState() {
    super.initState();
    // Fetch user data when the widget is initialized
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    // Get the current user from Firebase Auth
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String uid = user.uid;
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      try {
        DocumentSnapshot userDoc = await users.doc(uid).get();
        if (userDoc.exists) {
          setState(() {
            // Check if 'file_path' exists in the document before accessing it
            var data = userDoc.data();

            if (data is Map<String, dynamic> && data.containsKey('file_path')) {
              profileImageUrl = data['file_path'];
            }
          });
        } else {
          print("User document does not exist");
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    } else {
      print("User not authenticated");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LogoutPage()),
            );
          },
          icon: Icon(Icons.logout),
          color: Color(0xFFffd482),
        ),
        Text(
          "VERSE VOYAGE",
          style: TextStyle(
              color: Color(0xFFffd482),
              fontWeight: FontWeight.w900,
              fontSize: 25),
        ),
        GestureDetector(
          onTap: () {
            // Navigate to the profile page when the avatar is tapped
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Profile()),
            );
          },
          child: CircleAvatar(
            child: profileImageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(120),
                    child: Image.network(
                      profileImageUrl!,
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    ),
                  )
                : Icon(Icons.group_outlined, size: 50),
          ),
        ),
        // Add a PopupMenuButton for the dropdown
        PopupMenuButton<String>(
          iconColor:Color(0xFFffd482),
          onSelected: (value) {
            // Handle the selected option
            if (value == 'cart') {
              // Navigate to the cart page
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Cart()), // Replace CartPage() with your actual Cart page class
              );
            } else if (value == 'wishlist') {
              // Navigate to the wishlist page
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Wishlist()), // Replace WishlistPage() with your actual Wishlist page class
              );
            } else if (value == 'orders') {
              // Navigate to the orders page
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        OrdersPage()), // Replace OrdersPage() with your actual Orders Page class
              );
            }
          },
          itemBuilder: (BuildContext context) => [
            PopupMenuItem<String>(
              value: 'cart',
              
              child: ListTile(
                leading: Icon(
                  Icons.shopping_cart,
                  color: Colors.orange,
                ),
                title: Text(
                  'Cart',
                  style: TextStyle(
                    color: Color(0xFF24375E),
                  ),
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: 'wishlist',
              child: ListTile(
                leading: Icon(
                  Icons.favorite,
                  color: Colors.red,
                ),
                title: Text(
                  'Wishlist',
                  style: TextStyle(
                    color: Color(0xFF24375E),
                  ),
                ),
              ),
            ),
            PopupMenuItem<String>(
              value: 'orders',
              child: ListTile(
                leading: Icon(
                  Icons.assignment,
                  color: Colors.blue,
                ),
                title: Text(
                  'My Orders',
                  style: TextStyle(
                    color: Color(0xFF24375E),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
