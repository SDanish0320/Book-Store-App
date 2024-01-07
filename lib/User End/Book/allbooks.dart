import 'package:bookstore/User%20End/Layout%20Widgets/booktile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AllBooks extends StatefulWidget {
  @override
  State<AllBooks> createState() => _AllBooksState();
}

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
String? selectedAuthor;
String? selectedCategory;

class _AllBooksState extends State<AllBooks> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Color(0xFFffd482),
        title: Text(
          "All Books",
          style: TextStyle(
            color: Color(0xFFffd482),
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(0xFF24375E),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First Row (Authors)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('category').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading categories'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No categories available'));
                } else {
                  var categories = snapshot.data!.docs;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // "All" option
                        InkWell(
                          onTap: () {
                            setState(() {
                              selectedCategory =
                                  null; // Set selectedCategory to null for "All"
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: selectedCategory == null
                                  ? Color(0xFFffd482)
                                  : Color(0xFF24375E),
                            ),
                            child: Text(
                              "All",
                              style: TextStyle(
                                color: selectedCategory == null
                                    ? Color(0xFF24375E)
                                    : Color(0xFFffd482),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        // Existing categories
                        ...List.generate(
                          categories.length,
                          (index) {
                            var category = categories[index];
                            var categoryId = category.id; // Access document ID
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  selectedCategory =
                                      categoryId ?? ''; // Null check
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  color: selectedCategory == categoryId
                                      ? Color(0xFFffd482)
                                      : Color(0xFF24375E),
                                ),
                                child: Text(
                                  category['category'],
                                  style: TextStyle(
                                    color: selectedCategory == categoryId
                                        ? Color(0xFF24375E)
                                        : Color(0xFFffd482),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('author').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error loading authors'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No authors available'));
                } else {
                  var authors = snapshot.data!.docs;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // "All" option
                        InkWell(
                          onTap: () {
                            setState(() {
                              selectedAuthor =
                                  null; // Set selectedAuthor to null for "All"
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              color: selectedAuthor == null
                                  ? Color(0xFFffd482)
                                  : Color(0xFF24375E),
                            ),
                            child: Text(
                              "All",
                              style: TextStyle(
                                color: selectedAuthor == null
                                    ? Color(0xFF24375E)
                                    : Color(0xFFffd482),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        // Existing authors
                        ...List.generate(
                          authors.length,
                          (index) {
                            var author = authors[index];
                            var authorId = author.id; // Access document ID
                            return InkWell(
                              onTap: () async {
                                try {
                                  setState(() {
                                    selectedAuthor =
                                        authorId ?? ''; // Null check
                                  });
                                } catch (e) {
                                  print('Error fetching author name: $e');
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  color: selectedAuthor == authorId
                                      ? Color(0xFFffd482)
                                      : Color(0xFF24375E),
                                ),
                                child: Text(
                                  author['Author Name'],
                                  style: TextStyle(
                                    color: selectedAuthor == authorId
                                        ? Color(0xFF24375E)
                                        : Color(0xFFffd482),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  FutureBuilder<List<QueryDocumentSnapshot>>(
                    future: fetchProducts(),
                    builder: (context, snapshot) {
                      try {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          print('Error loading products: ${snapshot.error}');
                          return Center(child: Text('Error loading products'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return Center(child: Text('No products available'));
                        } else {
                          var products = snapshot.data!;

                          return Column(
                            children: List.generate(
                              products.length,
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
                      } catch (error) {
                        print('Error: $error');
                        return Center(child: Text('Error: $error'));
                      }
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<List<QueryDocumentSnapshot>> fetchProducts() async {
    try {
      QuerySnapshot productsSnapshot =
          await _firestore.collection('product').get();
      List<QueryDocumentSnapshot> products = productsSnapshot.docs;

      List<QueryDocumentSnapshot> filteredProducts = [];

      for (var product in products) {
        // Assuming 'AuthorId' and 'CategoryId' are fields in the 'product' document
        var productAuthorId = product['AuthorId'];
        var productCategoryId = product['CategoryId'];

        // Check if both author and category match the selected ones
        if ((selectedAuthor == null || productAuthorId == selectedAuthor) &&
            (selectedCategory == null ||
                productCategoryId == selectedCategory)) {
          filteredProducts.add(product);
        }
      }

      return filteredProducts;
    } catch (e) {
      print('Error fetching products: $e');
      return [];
    }
  }
}
