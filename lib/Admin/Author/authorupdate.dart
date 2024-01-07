import 'package:bookstore/Admin/Author/authorshow.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:file_picker/file_picker.dart';

class AuthorUpdate extends StatefulWidget {
  final String authorId; // Add this line to declare the required parameter

  AuthorUpdate({required this.authorId});

  @override
  State<AuthorUpdate> createState() => _AuthorUpdateState();
}

class _AuthorUpdateState extends State<AuthorUpdate> {
  TextEditingController _authorNameController = TextEditingController();
  TextEditingController _authorDetailsController = TextEditingController();
  TextEditingController _languageController = TextEditingController();
  TextEditingController _originController = TextEditingController();
  TextEditingController _imageController = TextEditingController();

  FilePickerResult? _filePickerResult;

  @override
  void initState() {
    super.initState();
    // Fetch author data when the widget is initialized
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      DocumentSnapshot authorSnapshot = await FirebaseFirestore.instance
          .collection('author')
          .doc(widget.authorId)
          .get();

      if (authorSnapshot.exists) {
        setState(() {
          _authorNameController.text = authorSnapshot.get("Author Name");
          _authorDetailsController.text = authorSnapshot.get("Details");
          _languageController.text = authorSnapshot.get("Language");
          _originController.text = authorSnapshot.get("Origin");
          _imageController.text = authorSnapshot.get("Image");
        });
      }
    } catch (e) {
      print("Error fetching author data: $e");
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
                Navigator.of(context).pop();
                Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AuthorShow()),
                      );
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

  Future<void> _selectFile() async {
    try {
      _filePickerResult = await FilePicker.platform.pickFiles();
      print("File Selected!");
    } catch (e) {
      print("Error picking file: $e");
    }
  }

  Future<void> updateAuthor(BuildContext context) async {
    try {
      String imageUrl = '';

      // Check if a new image is selected
      if (_filePickerResult != null && _filePickerResult!.files.isNotEmpty) {
        String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        String uniqueFileName =
            '$timestamp${_filePickerResult!.files.single.name.replaceAll(" ", "_")}';

        // Upload the new image to Firebase Storage
        await firebase_storage.FirebaseStorage.instance
            .ref()
            .child("author_images/$uniqueFileName")
            .putData(_filePickerResult!.files.single.bytes!);

        // Get the new image URL
        imageUrl = await firebase_storage.FirebaseStorage.instance
            .ref("author_images/$uniqueFileName")
            .getDownloadURL();
      } else {
        // If no new image is selected, use the existing image URL
        imageUrl = _imageController.text;
      }

      // Update author details in Firestore
      await FirebaseFirestore.instance
          .collection('author')
          .doc(widget.authorId)
          .update({
        'Author Name': _authorNameController.text,
        'Details': _authorDetailsController.text,
        'Language': _languageController.text,
        'Origin': _originController.text,
        'Image': imageUrl, // Update the image URL
      });

      // Show a success alert
      _showSuccessDialog(
      context,
      'Author updated successfully!',
    );

    // Delay the navigation to CategoryShow page for 2 seconds (adjust as needed)
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AuthorShow()),
      );
    });
  } catch (e) {
    print('Error updating author: $e');

    _showCustomAlertDialog(
      context,
      'Error',
      'An error occurred while updating the author. Please try again.',
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
              "Update Author",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text("Author's Details", style: TextStyle(fontSize: 18)),
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
                        controller: _authorNameController,
                        decoration: InputDecoration(
                          hintText: 'Author Name',
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFffd482)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: _authorDetailsController,
                        decoration: InputDecoration(
                          hintText: 'Author Details',
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFffd482)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: _languageController,
                        decoration: InputDecoration(
                          hintText: 'Language',
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFffd482)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: _originController,
                        decoration: InputDecoration(
                          hintText: 'Origin',
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFffd482)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: _imageController,
                        decoration: InputDecoration(
                          hintText: 'Image',
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
                  _selectFile(); // Call the file picking method
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
                    'SELECT IMAGE',
                    style: TextStyle(fontSize: 20),
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
                    'Are you sure you want to update this author?',
                    () {
                      updateAuthor(
                          context); // Call the updateAuthor method if confirmed
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
