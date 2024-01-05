import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CatScroll extends StatelessWidget {
  const CatScroll({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('category').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error loading categories');
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Text('No categories available');
        } else {
          var categories = snapshot.data!.docs.map((doc) => doc['category'].toString()).toList();

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(
                categories.length,
                (index) {
                  String category = categories[index];
                  IconData iconData = Icons.book; // Default icon

                  return InkWell(
                    onTap: () {
                      // Add your navigation logic
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: Colors.white,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              iconData,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 10),
                            Text(category),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }
      },
    );
  }
}
