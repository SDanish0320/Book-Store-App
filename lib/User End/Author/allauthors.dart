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
        centerTitle: true,
        backgroundColor: Color(0xFF24375E),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                InkWell(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => PageName()),
                    // );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Color(0xFF24375E),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.category_outlined,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Category",
                          style: TextStyle(
                              color: Color(0xFFffd482),
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => PageName()),
                    // );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      color: Color(0xFF24375E),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 10),
                        Text("Author",
                            style: TextStyle(
                                color: Color(0xFFffd482),
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  FutureBuilder<QuerySnapshot>(
                      future: _firestore.collection('author').get(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CustomLoader(
                            message: 'Exploring the Minds Behind the Books...',
                          ),);
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Error loading authors'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.docs.isEmpty) {
                          return Center(child: Text('No authors available'));
                        } else {
                          var authors = snapshot.data!.docs;
                          return Center(
                            child: Column(
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
                            ),
                          );
                        }
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
