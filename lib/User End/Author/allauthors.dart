import 'package:bookstore/Common/Custom%20Loader/customloader.dart';
import 'package:bookstore/User%20End/Layout%20Widgets/bookcard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AllAuthors extends StatefulWidget {
  @override
  State<AllAuthors> createState() => _AllAuthorsState();
}

class _AllAuthorsState extends State<AllAuthors> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "All Authors",
          style: TextStyle(
            color: Color(0xFFffd482),
          ),
        ),
        foregroundColor: Color(0xFFffd482),
        centerTitle: true,
        backgroundColor: Color(0xFF24375E),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: _firestore.collection('author').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CustomLoader(
                message: 'Exploring the Minds Behind the Books...',
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error loading authors'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No authors available'));
          } else {
            var authors = snapshot.data!.docs;

            return ListView.builder(
              itemCount: (authors.length / 2).ceil(),
              itemBuilder: (context, index) {
                var startIndex = index * 2;
                var endIndex = (index + 1) * 2;

                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          2,
                          (i) {
                            if (startIndex + i < authors.length) {
                              var author =
                                  authors[startIndex + i].data() as Map<String, dynamic>;
                      
                              return Expanded(
                                child: BookCard(
                                  imageUrl: author['Image'],
                                  authorName: author['Author Name'],
                                ),
                              );
                            } else {
                              return SizedBox.shrink();
                            }
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0), // Add space between rows
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}
