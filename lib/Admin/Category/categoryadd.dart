import 'package:bookstore/Admin/Category/categoryshow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: CategoryAdd()));
}

class CategoryAdd extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _catnameController = TextEditingController();

  Future<void> _addCategory(BuildContext context) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore
            .collection('category')
            .add({'category': _catnameController.text});
        _catnameController.clear();

        _showCustomAlertDialog(
          context,
          'Success',
          'Category added successfully!',
          () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CategoryShow()),
            );
          },
        );
      }
    } catch (e) {
      print('Error adding category: $e');

      _showCustomAlertDialog(
        context,
        'Error',
        'Error adding crops. Please try again.',
        () {
          Navigator.of(context).pop();
        },
      );
    }
  }

  void _showCustomAlertDialog(
      BuildContext context, String title, String content, Function onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData(
            backgroundColor: Color(0xFFffd482),
          ),
          child: AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); 
                  Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CategoryShow()),
                      );
                },
                style: TextButton.styleFrom(
                  primary: Color(0xFF24375E),
                  backgroundColor: Color(0xFF24375E),
                ),
                child: Text('OK',
                    style: TextStyle(
                        color: Color(0xFFffd482), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF24375E),
        iconTheme: IconThemeData(
          color: Color(0xFFffd482), // Set the color for the back arrow
        ),
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              "Add Category",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Container(
                width: 450,
                padding: EdgeInsets.only(
                  top: 10,
                ),
                child: Expanded(
                  child: Column(
                    children: [
                      TextField(
                        controller: _catnameController,
                        decoration: InputDecoration(
                          hintText: 'Category Name',
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFffd482)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              width: 450,
              child: ElevatedButton(
                onPressed: () {
                  _addCategory(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF24375E),
                  foregroundColor: Color(0xFFffd482),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    'Add Category',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
