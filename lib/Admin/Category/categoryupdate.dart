import 'package:bookstore/Admin/Category/categoryshow.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryUpdate extends StatefulWidget {
  final String categoryId;

  CategoryUpdate(this.categoryId);

  @override
  State<CategoryUpdate> createState() => _CategoryUpdateState();
}

class _CategoryUpdateState extends State<CategoryUpdate> {
  TextEditingController _catnameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      DocumentSnapshot categorySnapshot = await FirebaseFirestore.instance
          .collection('category')
          .doc(widget.categoryId)
          .get();

      if (categorySnapshot.exists) {
        setState(() {
          _catnameController.text = categorySnapshot.get("category");
        });
      }
    } catch (e) {
      print("Error fetching category data: $e");
    }
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData(
            backgroundColor: Color(0xFF2ECC71), // Green color
          ),
          child: AlertDialog(
            title: Text('Success'),
            content: Text(message),
          ),
        );
      },
    );
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
                child: Text('Cancel',
                    style: TextStyle(
                        color: Color(0xFFffd482), fontWeight: FontWeight.bold)),
              ),
              TextButton(
                onPressed: () {
                  onConfirm(); // Call the provided callback function
                  Navigator.of(context).pop(); // Close the dialog
                },
                style: TextButton.styleFrom(
                  primary: Color(0xFF24375E),
                  backgroundColor: Color(0xFF24375E),
                ),
                child: Text('Confirm',
                    style: TextStyle(
                        color: Color(0xFFffd482), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> updateCategory(BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection('category')
          .doc(widget.categoryId)
          .update({
        'category': _catnameController.text,
      });

      // Show a success dialog with green color
      _showSuccessDialog(
        context,
        'Category updated successfully!',
      );

      // Delay the navigation to CategoryShow page for 2 seconds (adjust as needed)
      Future.delayed(Duration(seconds: 2), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => CategoryShow()),
        );
      });
    } catch (e) {
      print('Error updating category: $e');

      _showCustomAlertDialog(
        context,
        'Error',
        'An error occurred while updating the category. Please try again.',
        () {
          // Handle the confirm action if needed
        },
      );
    }
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
                      SizedBox(
                        height: 10,
                      ),
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
                  // Show a confirmation alert before updating
                  _showCustomAlertDialog(
                    context,
                    'Confirmation',
                    'Are you sure you want to update this category?',
                    () {
                      updateCategory(
                          context); // Call the updateCategory method if confirmed
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
}
