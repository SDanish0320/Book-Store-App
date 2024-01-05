import 'package:bookstore/Admin/Author/authorshow.dart';
import 'package:bookstore/Admin/drawer.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:file_picker/file_picker.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: AuthorAdd()));
}

class AuthorAdd extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _authornameController = TextEditingController();
  final TextEditingController _authordetailsController =
      TextEditingController();
  final TextEditingController _authorlanguageController =
      TextEditingController();
  final TextEditingController _authororiginController = TextEditingController();

  FilePickerResult? _filePickerResult;

  Future<void> _addAuthor(BuildContext context) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        if (_filePickerResult != null && _filePickerResult!.files.isNotEmpty) {
          String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
          String uniqueFileName =
              '$timestamp${_filePickerResult!.files.single.name.replaceAll(" ", "_")}';

          await firebase_storage.FirebaseStorage.instance
              .ref()
              .child("author_images/${uniqueFileName}")
              .putData(_filePickerResult!.files.single.bytes!);

          String imageUrl = await firebase_storage.FirebaseStorage.instance
              .ref("author_images/${uniqueFileName}")
              .getDownloadURL();

          await _firestore.collection('author').add({
            'Author Name': _authornameController.text,
            'Details': _authordetailsController.text,
            'Language': _authorlanguageController.text,
            'Origin': _authororiginController.text,
            'Image': imageUrl,
          });

          _authornameController.clear();
          _authordetailsController.clear();
          _authorlanguageController.clear();
          _filePickerResult = null;

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Success'),
                content: Text('Author added successfully!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AuthorShow()),
                      );
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('Please select an image.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      }
    } catch (e) {
      print('Error adding author: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Error adding author. Please try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _selectFile() async {
    try {
      _filePickerResult = await FilePicker.platform.pickFiles();
      print("File Selected!");
    } catch (e) {
      print("Error picking file: $e");
    }
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
              "Add Author",
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
                        controller: _authornameController,
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
                        controller: _authordetailsController,
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
                        controller: _authorlanguageController,
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
                        controller: _authororiginController,
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
                      
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            ElevatedButton(
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
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Select Image',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
            _filePickerResult != null && _filePickerResult!.files.isNotEmpty
                ? Text(_filePickerResult!.files.single.name)
                : Container(),
            SizedBox(
              height: 10,
            ),
            ElevatedButton(
              onPressed: () {
                _addAuthor(context);
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
                  'Add Author',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
