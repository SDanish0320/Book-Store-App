import 'package:bookstore/Common/Custom%20Loader/customloader.dart';
import 'package:bookstore/User%20End/Layout%20Widgets/booktile.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryDetails extends StatefulWidget {
  final String categoryId;

  CategoryDetails({required this.categoryId});

  @override
  State<CategoryDetails> createState() => _CategoryDetailsState();
}

class _CategoryDetailsState extends State<CategoryDetails> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late Future<DocumentSnapshot> catDetails;

  @override
  void initState() {
    super.initState();
    catDetails = fetchCategoryDetails();
  }

  Future<DocumentSnapshot> fetchCategoryDetails() async {
    try {
      final categoryDetails = await FirebaseFirestore.instance
          .collection('category')
          .doc(widget.categoryId)
          .get();

      if (!categoryDetails.exists) {
        throw 'Error: Category document with ID ${widget.categoryId} does not exist.';
      }

      return categoryDetails;
    } catch (e) {
      throw 'Error fetching category details: $e';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DocumentSnapshot>(
        future: catDetails,
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CustomLoader(
                message: "Loading Category Details...",
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
              child: Text('Error: Category details not available.'),
            );
          } else {
            var catData = snapshot.data!;

            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
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
                              SizedBox(height: 25),
                              Text(
                                (catData.data() as Map<String, dynamic>)['category'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFffd482),
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(height: 25),
                            ],
                          ),
                        ),
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
                              "Books in this category",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 21,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        Container(
                          child: FutureBuilder<QuerySnapshot>(
                            future: _firestore
                                .collection('product')
                                .where('CategoryId',
                                    isEqualTo: widget.categoryId)
                                .get(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              } else if (snapshot.hasError) {
                                return Center(
                                  child: Text('Error loading products: ${snapshot.error}'),
                                );
                              } else if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return Center(
                                  child: Text('No products available.'),
                                );
                              } else {
                                var products = snapshot.data!.docs;
                                return Column(
                                  children: List.generate(
                                    products.length,
                                    (index) {
                                      var product =
                                          products[index].data() as Map<String, dynamic>;
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
                        ),
                      ],
                    ),
                  )
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
