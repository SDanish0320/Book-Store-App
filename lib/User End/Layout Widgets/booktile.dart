
import 'package:bookstore/User%20End/Book/bookdetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BookTile extends StatelessWidget {
  final String imageUrl;
  final String productName;
  final String author;
  final String price;

  BookTile({
    required this.imageUrl,
    required this.productName,
    required this.author,
    required this.price,
  });

  Future<int> getReviewCount(String productName) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('productName', isEqualTo: productName)
          .get();

      return querySnapshot.docs.length;
    } catch (e) {
      print('Error fetching review count: $e');
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Container(
        color: Colors.amber.withOpacity(0.3),
        child: Row(
          children: [
            GestureDetector(
              onTap: () async {
                QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                    .collection('product')
                    .where('Product Name', isEqualTo: productName)
                    .limit(1)
                    .get();

                if (querySnapshot.docs.isNotEmpty) {
                  DocumentSnapshot productSnapshot = querySnapshot.docs.first;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          BookDetails(productId: productSnapshot.id),
                    ),
                  );
                } else {
                  // Handle the case when no documents were found
                  print('No documents found for product: $productName');
                }
              },
              child: Container(
                decoration: BoxDecoration(boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: Offset(2, 2),
                  )
                ]),
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  child: Image.network(
                    imageUrl,
                    width: 100,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(productName, maxLines: 2),
                  SizedBox(height: 4),
                  FutureBuilder<String>(
                    future: getAuthorName(author),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text('By: Loading...');
                      } else if (snapshot.hasError) {
                        return Text('By: Error loading author name');
                      } else {
                        return Text('By: ${snapshot.data}');
                      }
                    },
                  ),
                  SizedBox(height: 10),
                  Text("Price : \Rs " + price),
                  SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 16,
                      ),
                      
                      FutureBuilder<int>(
                        future: getReviewCount(productName),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Text("Review Count: Loading...");
                          } else if (snapshot.hasError) {
                            return Text("Review Count: Error loading");
                          } else {
                            return Text("${snapshot.data} Reviews");
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
}
