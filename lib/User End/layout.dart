
import 'package:bookstore/User%20End/Author/allauthors.dart';
import 'package:bookstore/User%20End/Book/allbooks.dart';
import 'package:bookstore/User%20End/Layout%20Widgets/appbar.dart';
import 'package:bookstore/User%20End/Layout%20Widgets/bookcard.dart';
import 'package:bookstore/User%20End/Layout%20Widgets/booktile.dart';
import 'package:bookstore/User%20End/Layout%20Widgets/categoriesScroll.dart';
import 'package:bookstore/User%20End/Layout%20Widgets/inputfeild.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Layoutt extends StatefulWidget {
  @override
  State<Layoutt> createState() => _LayouttState();
}

class _LayouttState extends State<Layoutt> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User loggedInUser; // Assuming you have access to the logged-in user

  @override
  void initState() {
    super.initState();
    loggedInUser = FirebaseAuth.instance.currentUser!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              height: 320,
              color: Color(0xFF24375E),
              child: Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(height: 40),
                          HomeAppBar(),
                          Row(
                            children: [
                              Text(
                                "Hello ",
                                style: GoogleFonts.poppins(color: Color(0xFFffd482),
                                    fontWeight: FontWeight.bold)
                              ),
                              SizedBox(height: 10),
                              FutureBuilder<DocumentSnapshot>(
                                future: _firestore
                                    .collection('users')
                                    .doc(loggedInUser.uid)
                                    .get(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text(
                                      'Error loading username',
                                      style: TextStyle(
                                        color: Color(0xFFffd482),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  } else {
                                    String username =
                                        snapshot.data?['username'] ?? 'User';
                                    return Text(
                                      "What's Up ${username.toUpperCase()} ?",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                "Discover worlds between the pages, one book at a time.",
                                style: TextStyle(
                                  color: Color(0xFFffd482),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          MyInputFeild(),
                          SizedBox(height: 20),
                          Row(
                            children: [
                              Text(
                                "Genres",
                                style: TextStyle(
                                    color: Color(0xFFffd482),
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          CatScroll()
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Authors",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF24375E))),
                      InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AllAuthors()),
                            );
                          },
                          child: Text("See All Authors",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF24375E))))
                    ],
                  ),
                  SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: FutureBuilder<QuerySnapshot>(
                      future: _firestore.collection('author').get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error loading products'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return Center(child: Text('No products available'));
                        } else {
                          var authors = snapshot.data!.docs;
                          return Row(
                            children: List.generate(
                              authors.length,
                              (index) {
                                var author = authors[index].data()
                                    as Map<String, dynamic>;

                                return BookCard(
                                  imageUrl: author['Image'],
                                  authorName: author['Author Name'],
                                );
                              },
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Trending",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF24375E))),
                      InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AllBooks()),
                            );
                          },
                          child: Text("See All Books",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF24375E))))
                    ],
                  ),
                  SizedBox(height: 10),
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
              ),
            )
          ],
        ),
      ),
    );
  }
}
