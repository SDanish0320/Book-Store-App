
import 'package:bookstore/User%20End/Author/authordetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BookCard extends StatelessWidget {
  final String imageUrl;
  final String authorName;

  BookCard({
    required this.imageUrl,
    required this.authorName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 15),
      child: SizedBox(
        width: 120,
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 4 / 5, // Adjust the ratio as needed
              child: GestureDetector(
                onTap: () async {
                QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                    .collection('author')
                    .where('Author Name', isEqualTo: authorName)
                    .limit(1)
                    .get();

                if (querySnapshot.docs.isNotEmpty) {
                  DocumentSnapshot authorSnapshot = querySnapshot.docs.first;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          AuthorDetails(authorId: authorSnapshot.id),
                    ),
                  );
                } else {
                  // Handle the case when no documents were found
                  print('No documents found for product: $authorName');
                }
              },
                child: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 8,
                        offset: Offset(2, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: Image.network(imageUrl, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text(
              authorName,
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            
          ],
        ),
      ),
    );
  }
}
