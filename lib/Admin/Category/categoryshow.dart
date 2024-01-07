import 'package:bookstore/Admin/Category/categoryadd.dart';
import 'package:bookstore/Admin/Category/categoryupdate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: CategoryShow()));
}

class CategoryShow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF24375E),
        iconTheme: IconThemeData(
          color: Color(0xFFffd482), // Set the color for the back arrow
        ),
      ),
      body: MyListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CategoryAdd()),
          );
        },
        backgroundColor: Color(0xFF24375E),
        child: Icon(Icons.add, color: Color(0xFFffd482)),
      ),
    );
  }
}

class MyListView extends StatefulWidget {
  @override
  _MyListViewState createState() => _MyListViewState();
}

class _MyListViewState extends State<MyListView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firestore.collection('category').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        var category = snapshot.data!.docs;

        return ListView.builder(
          itemCount: category.length,
          itemBuilder: (context, index) {
            var cat = category[index];

            return Card(
              margin: EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              color: Color(0xFFffd482),
              child: ListTile(
                title: RichText(
                  text: TextSpan(
                    text: 'Category Name: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          Color(0xFF24375E) // You can set the color if needed
                    ),
                    children: [
                      TextSpan(
                        text: '${cat['category']}',
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF24375E), // You can set the color if needed
                        ),
                      ),
                    ],
                  ),
                ),
                subtitle: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CategoryUpdate(cat.id)),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteCategory(cat.id);
                      },
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _deleteCategory(String categoryId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Deletion',
            style: TextStyle(color: Color(0xFF24375E)),
          ),
          content: Text('Are you sure you want to delete this category?',
              style: TextStyle(color: Color(0xFF24375E))),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              style: TextButton.styleFrom(
                // Set the foreground color and background color of the "Cancel" button
                primary: Color(0xFF24375E),
                backgroundColor: Color(0xFF24375E),
              ),
              child: Text('Cancel',
                  style: TextStyle(
                      color: Color(0xFFffd482), fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('category')
                      .doc(categoryId)
                      .delete();
                  Navigator.of(context).pop(); // Close the dialog
                  // You can add additional actions after successful deletion
                } catch (e) {
                  print('Error deleting category: $e');
                  // Handle the error (show a dialog, snackbar, etc.)
                }
              },
              style: TextButton.styleFrom(
                // Set the foreground color and background color of the "OK" button
                primary: Color(0xFF24375E),
                backgroundColor: Color(0xFF24375E),
              ),
              child: Text('OK',
                  style: TextStyle(
                      color: Color(0xFFffd482), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
