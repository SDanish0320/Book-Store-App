import 'package:bookstore/Admin/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryUpdate extends StatefulWidget {
  String myid;
  CategoryUpdate(this.myid);

  @override
  State<CategoryUpdate> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<CategoryUpdate> {
  final TextEditingController _catnameController = TextEditingController();

  void initState() {
    super.initState();
    // Fetch user data when the widget is initialized
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      DocumentSnapshot data = await FirebaseFirestore.instance
          .collection('category')
          .doc(widget.myid)
          .get();
      if (data.exists) {
        _catnameController.text = data.get("category");
      }
    } catch (e) {
      print("Error fetching data: $e");
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
                  Navigator.of(context).pop(); // Close the dialog
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
    return CommonScaffold(
      mybody: Center(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              "Update Category",
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
                        decoration: InputDecoration(
                          hintText: 'Category Name',
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFffd482)),
                          ),
                        ),
                        controller: _catnameController,
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
                  _showCustomAlertDialog(
                    context,
                    'Confirm Update',
                    'Are you sure you want to update this category?',
                    () {
                      Update(widget.myid);
                    },
                  );
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
                    'UPDATE',
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

  Future<void> Update(String documentId) async {
    try {
      FirebaseFirestore db = FirebaseFirestore.instance;
      CollectionReference tab = db.collection('category');

      Map<String, dynamic> updatedData = {
        'category': _catnameController.text,
      };

      await tab.doc(documentId).update(updatedData);

      _catnameController.text = "";
    } catch (e) {
      print('Error updating category: $e');
      _showCustomAlertDialog(
        context,
        'Error',
        'Error updating category. Please try again.',
        () {
          Navigator.of(context).pop();
        },
      );
    }
  }
}
