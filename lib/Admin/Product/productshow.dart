import 'package:bookstore/Admin/Product/productadd.dart';
import 'package:bookstore/Admin/Product/productupdate.dart';
import 'package:bookstore/Admin/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: ProductShow(),
  ));
}

class ProductShow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      mybody: MyListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProductAdd()),
          );
        },
        backgroundColor: Color(0xFF24375E),
        child: Icon(Icons.add, color: Color(0xFFffd482)),
      ),
    );
  }
}

class MyListView extends StatelessWidget {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('product').doc(productId).delete();
    } catch (e) {
      print('Error deleting product: $e');
      throw 'Error deleting product';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: fetchProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CupertinoActivityIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Error loading products'),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Text('No products available'),
          );
        } else {
          var products = snapshot.data!;
          // Sort products by name
          products.sort((a, b) => a.productName.compareTo(b.productName));
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              var product = products[index];

              return Card(
                margin: EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                color: Color(0xFFffd482),
                child: ListTile(
                  title: Text('Product: ${product.productName}',style: TextStyle(color: Color(0xFF24375E))),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder<String>(
                        future: getAuthorName(product.authorId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text('Author: Loading...');
                          } else if (snapshot.hasError) {
                            return Text('Author: Error loading author name');
                          } else {
                            return Text('Author: ${snapshot.data}',style: TextStyle(color: Color(0xFF24375E)));
                          }
                        },
                      ),
                      FutureBuilder<String>(
                        future: getCategoryName(product.categoryId),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text('Category: Loading...');
                          } else if (snapshot.hasError) {
                            return Text(
                                'Category: Error loading category name');
                          } else {
                            return Text('Category: ${snapshot.data}',style: TextStyle(color: Color(0xFF24375E)));
                          }
                        },
                      ),
                      Text('Price: ${product.price}',style: TextStyle(color: Color(0xFF24375E))),
                      Text('Description: ${product.description}',style: TextStyle(color: Color(0xFF24375E))),
                    ],
                  ),
                  leading: AspectRatio(
                    aspectRatio: 4/5,
                    child: Container(
                      width: 70, // Adjust the width as needed
                      height: 100, // Adjust the height as needed
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductUpdate(
                                productId: product
                                    .id, // Assuming product has an 'id' property
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: 10),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Delete Product'),
                                content: Text('Are you sure you want to delete this product?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Close the dialog
                                    },
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      deleteProduct(product.id);
                                      Navigator.pop(context); // Close the dialog
                                    },
                                    child: Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    );
  }

  Future<List<Product>> fetchProducts() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('product').get();

      return querySnapshot.docs
          .map((doc) => Product.fromSnapshot(doc))
          .toList();
    } catch (e) {
      print('Error fetching products: $e');
      throw 'Error fetching products';
    }
  }

  Future<String> getAuthorName(String authorId) async {
    try {
      DocumentSnapshot authorSnapshot = await FirebaseFirestore.instance
          .collection('author')
          .doc(authorId)
          .get();
      return authorSnapshot['Author Name'];
    } catch (e) {
      return 'Unknown Author';
    }
  }

  Future<String> getCategoryName(String categoryId) async {
    try {
      DocumentSnapshot categorySnapshot = await FirebaseFirestore.instance
          .collection('category')
          .doc(categoryId)
          .get();
      return categorySnapshot['category'];
    } catch (e) {
      return 'Unknown Category';
    }
  }
}

class Product {
  final String id;
  final String productName;
  final String authorId;
  final String categoryId;
  final String price;
  final String description;
  final String imageUrl;

  Product({
    required this.id,
    required this.productName,
    required this.authorId,
    required this.categoryId,
    required this.price,
    required this.description,
    required this.imageUrl,
  });

  factory Product.fromSnapshot(QueryDocumentSnapshot doc) {
    return Product(
      id: doc.id,
      productName: doc['Product Name'],
      authorId: doc['AuthorId'],
      categoryId: doc['CategoryId'],
      price: doc['Price'],
      description: doc['Description'],
      imageUrl: doc['Image'],
    );
  }
}
