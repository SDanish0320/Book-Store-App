import 'package:bookstore/User%20End/Layout%20Widgets/booktile.dart';
import 'package:bookstore/User%20End/Profile/profileedit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profile extends StatefulWidget {
  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userName;
  String? accountEmail;
  String? profileImageUrl;
  late String uid; // Declare uid variable

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
      uid = user.uid; // Assign uid here
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      try {
        DocumentSnapshot userDoc = await users.doc(uid).get();
        if (userDoc.exists) {
          setState(() {
            userName = userDoc['username'];
            accountEmail = user.email;

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF24375E),
        foregroundColor: Color(0xFFffd482),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileEdit()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 320,
              color: Color(0xFF24375E),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            border: Border.all(
                              width: 2,
                              color: Color(0xFFffd482),
                            ),
                          ),
                          child: Container(
                            height: 120,
                            width: 120,
                            child: profileImageUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: Image.network(
                                      profileImageUrl!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Icon(Icons.group_add_outlined, size: 50),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          userName ?? "User Name",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFFffd482),
                          ),
                        ),
                        Text(
                          accountEmail ?? "Account Email",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            color: Color(0xFFffd482),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text("Your Books"),
                    ],
                  ),
                  SizedBox(height: 10),
                  Column(
                    children: [
                      FutureBuilder<QuerySnapshot>(
                        future: _firestore
                            .collection('users')
                            .doc(
                                uid) // Use the uid of the currently logged-in user
                            .collection('orders')
                            .where('orderStatus', isEqualTo: 'Delivered')
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.hasError) {
                            return Center(child: Text('Error loading orders'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Center(
                                child: Text('No delivered orders available'));
                          } else {
                            var orders = snapshot.data!.docs;
                            return Column(
                              children: List.generate(
                                orders.length,
                                (index) {
                                  var order = orders[index];
                                  var orderId = order
                                      .id; // Use the 'id' property to get the document ID

                                  return FutureBuilder<QuerySnapshot>(
                                    future: _firestore
                                        .collection('users')
                                        .doc(uid)
                                        .collection('orders')
                                        .doc(orderId)
                                        .collection('order_items')
                                        .get(),
                                    builder: (context, itemSnapshot) {
                                      return _buildBookTile(
                                          context, itemSnapshot, uid);
                                    },
                                  );
                                },
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBookTile(
    BuildContext context,
    AsyncSnapshot<QuerySnapshot> itemSnapshot,
    String uid,
  ) {
    if (itemSnapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    } else if (itemSnapshot.hasError) {
      return Center(child: Text('Error loading order items'));
    } else if (!itemSnapshot.hasData || itemSnapshot.data!.docs.isEmpty) {
      return Center(child: Text('No order items available'));
    } else {
      var orderItems = itemSnapshot.data!.docs;
      return Column(
        children: List.generate(
          orderItems.length,
          (itemIndex) {
            var item = orderItems[itemIndex].data() as Map<String, dynamic>;
            var itemName = item['name'];

            if (itemName == null) {
              // Skip processing if itemName is null
              return SizedBox.shrink();
            }

            return FutureBuilder<QuerySnapshot>(
              future: _firestore
                  .collection('product')
                  .where('Product Name', isEqualTo: itemName)
                  .get(),
              builder: (context, productSnapshot) {
                if (productSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (productSnapshot.hasError) {
                  return Center(child: Text('Error loading product'));
                } else if (!productSnapshot.hasData ||
                    productSnapshot.data!.docs.isEmpty) {
                  return Center(child: Text('Product not available'));
                } else {
                  var productData = productSnapshot.data!.docs[0].data()
                      as Map<String, dynamic>;

                  // Check for null values and provide default values
                  var imageUrl = productData['Image'] ?? '';
                  var productName = productData['Product Name'] ?? '';
                  var author = productData['AuthorId'] ?? '';
                  var price = productData['Price'] ?? '';

                  return BookTile(
                    imageUrl: imageUrl,
                    productName: productName,
                    author: author,
                    price: price,
                  );
                }
              },
            );
          },
        ),
      );
    }
  }
}
