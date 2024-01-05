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
    CollectionReference users = FirebaseFirestore.instance.collection('users');

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
          // padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          color: Color(0xFF24375E),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // SizedBox(height: 100),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(width: 2,
                      color: Color(0xFFffd482))
                    ),
                    child: Container(
                      height: 120,
                      width: 120,
                      child: profileImageUrl !=null ? ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.network(
                          profileImageUrl!,
                          fit: BoxFit.cover
                        ),
                      )
                      : Icon(Icons.group_add_outlined, size:50),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(userName ?? "User Name", style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFFffd482)
                  )),
                   Text(accountEmail ?? "Account Email", style: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: Color(0xFFffd482)
                  )),
                ],
              )
              )
            ],
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            Row(
              children: [
                Text("Your Books"),
              ],
            ),
            SizedBox(height: 10),
            Column(
              children: [
                FutureBuilder<QuerySnapshot>(
                    future: _firestore.collection('product').limit(3).get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error loading products'));
                      } else if (!snapshot.hasData ||
                          snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No products available'));
                      } else {
                        var products = snapshot.data!.docs;
                        return Column(
                          children: List.generate(
                            products.take(3).length,
                            (index) {
                              var product = products[index].data()
                                  as Map<String, dynamic>;

                              return BookTile(
                                imageUrl: product['Image'],
                                productName: product['Product Name'],
                                author: product['AuthorId'],
                                price: product['Price'],
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
              ],
            )
          ],),
        )
        ],
        ),
      ),
    );
  }
}
