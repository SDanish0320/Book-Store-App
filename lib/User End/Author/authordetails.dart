import 'package:bookstore/Common/Custom%20Loader/customloader.dart';
import 'package:bookstore/User%20End/Layout%20Widgets/booktile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthorDetails extends StatefulWidget {
  final String authorId;

  AuthorDetails({required this.authorId});

  @override
  State<AuthorDetails> createState() => _AuthorDetailsState();
}

class _AuthorDetailsState extends State<AuthorDetails> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<DocumentSnapshot> authorDetails;

  @override
  void initState() {
    super.initState();
    // Initialize authorDetails here
    authorDetails = fetchAuthorDetails();
  }

  Future<DocumentSnapshot> fetchAuthorDetails() async {
    try {
      final authorDetails = await FirebaseFirestore.instance
          .collection('author') // Replace with your actual collection name
          .doc(widget.authorId)
          .get();

      return authorDetails;
    } catch (e) {
      throw 'Error fetching author collection: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: Future.wait([authorDetails]),
          builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CustomLoader(
                  message: "Diving into the Authors World...",
                ),
              );
            } else if (snapshot.hasError ||
                snapshot.data == null ||
                snapshot.data!.isEmpty) {
              return Center(child: Text('Error loading details'));
            } else {
              var authorData = snapshot.data![0];

              return SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      // height: 500,
                      color: Color(0xFF24375E),
                      child: Row(
                        children: [
                          Expanded(
                              child: Column(
                            children: [
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.arrow_left_sharp,
                                            color: Color(0xFFffd482),
                                            size: 30,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 40),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      authorData['Image'],
                                      width: 170,
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 15),
                              Text(
                                authorData['Author Name'],
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFffd482),
                                    fontSize: 20),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          "Origin",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text('${authorData['Origin']}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: const Color.fromARGB(
                                                    255, 255, 233, 33))),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          "Language",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text('${authorData['Language']}',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromARGB(
                                                    255, 6, 194, 0))),
                                      ],
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ))
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                "About Author",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 21),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '${authorData['Details']}',
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontStyle: FontStyle.italic,
                                      fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 25),
                          Row(
                            children: [
                              Text(
                                "Author's Collections",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 21),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Container(
                              child: FutureBuilder<QuerySnapshot>(
                                  future: _firestore
                                      .collection('product')
                                      .where('AuthorId',
                                          isEqualTo: widget
                                              .authorId) // Filter by AuthorId
                                      .get(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Center(
                                          child: CircularProgressIndicator());
                                    } else if (snapshot.hasError) {
                                      return Center(
                                          child:
                                              Text('Error loading products'));
                                    } else if (!snapshot.hasData ||
                                        snapshot.data!.docs.isEmpty) {
                                      return Center(
                                          child: Text('No products available'));
                                    } else {
                                      var products = snapshot.data!.docs;
                                      return Column(
                                        children: List.generate(products.length,
                                            (index) {
                                          var product = products[index].data()
                                              as Map<String, dynamic>;
                                          return BookTile(
                                            imageUrl: product['Image'],
                                            productName:
                                                product['Product Name'],
                                            author: product['AuthorId'],
                                            price: product['Price'],
                                          );
                                        }),
                                      );
                                    }
                                  }))
                        ],
                      ),
                    )
                  ],
                ),
              );
            }
          }),
    );
  }
}
