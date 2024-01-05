import 'package:bookstore/Common/Login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';

class ProfileEdit extends StatefulWidget {
  @override
  _ProfileEditState createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  dynamic profileImageUrl;
  bool _isHovered = false;
  @override
  void initState() {
    super.initState();
    // Fetch user data when the widget is initialized
    fetchUserData();
  }

  FilePickerResult? _filePickerResult;

  Future<void> _selectFile() async {
    try {
      _filePickerResult = await FilePicker.platform.pickFiles();
      print("File Selected!");
      setState(() {});
    } catch (e) {
      print("Error picking file: $e");
    }
  }

  Future<void> fetchUserData() async {
    // Get the current user from Firebase Auth
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String uid = user.uid;
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      try {
        DocumentSnapshot userDoc = await users.doc(uid).get();
        if (userDoc.exists) {
          setState(() {
            usernameController.text = userDoc['username'];
            emailController.text = user.email ?? '';
            contactNumberController.text = userDoc['contactNumber'];
            profileImageUrl = userDoc['file_path'];
          });
        } else {
          print("User document does not exist");
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    } else {
      print("User not authenticated");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF24375E),
        foregroundColor: Color(0xFFffd482),
        title: Text("Account Details"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 320,
              color: Color(0xFF24375E),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              border:
                                  Border.all(width: 2, color: Colors.white)),
                          child: InkWell(
                            onTap: () {
                              _selectFile();
                            },
                            child: MouseRegion(
                              onEnter: (_) {
                                _handleHover(true);
                              },
                              onExit: (_) {
                                _handleHover(false);
                              },
                              child: Container(
                                height: 120,
                                width: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: _isHovered
                                      ? Colors.grey[300]
                                      : Colors.transparent,
                                ),
                                child: profileImageUrl != null
                                    ? ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        child: Image.network(
                                          profileImageUrl!,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : Icon(Icons.group_outlined, size: 50),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      children: [
                        TextField(
                          controller: usernameController,
                          decoration: InputDecoration(
                              hintText: 'Username',
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              )),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                              hintText: 'Email Address',
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              )),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        TextField(
                          controller: contactNumberController,
                          decoration: InputDecoration(
                              hintText: 'Contact Number',
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              )),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        _filePickerResult != null &&
                                _filePickerResult!.files.isNotEmpty
                            ? Text(_filePickerResult!.files.single.name)
                            : Container(),
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  if (_filePickerResult != null &&
                                      _filePickerResult!.files.isNotEmpty) {
                                    uploadFile();
                                  } else {
                                    updateUserData();
                                  }
                                  updateUserData();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Login()),
                                  );
                                },
                                child: Container(
                                  height: 60,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: Color(0xFF24375E),
                                  ),
                                  child: Center(
                                    child: Text(
                                      "UPDATE",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFFffd482),
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> uploadFile() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String uid = user.uid;
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');
      try {
        if (_filePickerResult != null && _filePickerResult!.files.isNotEmpty) {
          String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
          String uniqueFileName =
              '$timestamp${_filePickerResult!.files.single.name.replaceAll(" ", "_")}';

          firebase_storage.Reference storageReference = firebase_storage
              .FirebaseStorage.instance
              .ref()
              .child("uploads/${uniqueFileName}");

          await storageReference
              .putData(_filePickerResult!.files.single.bytes!);

          String downloadURL = await storageReference.getDownloadURL();

          // Update the document instead of adding a new one
          await users.doc(uid).update({
            'username': usernameController.text,
            'email': emailController.text,
            'contactNumber': contactNumberController.text,
            'file_path': downloadURL,

            // Add other fields as needed
          });
        } else {
          print("Please select a file first");
        }
      } catch (e) {
        print("Error updating file: $e");
        print("Error updating file. Please try again.");
      }
    }
  }

  void updateUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String uid = user.uid;
      CollectionReference users =
          FirebaseFirestore.instance.collection('users');

      try {
        await users.doc(uid).update({
          'username': usernameController.text,
          'email': emailController.text,
          'contactNumber': contactNumberController.text,
          // Add other fields as needed
        });

        print('User data updated successfully');
      } catch (e) {
        print('Error updating user data: $e');
      }
    } else {
      print('User not authenticated');
    }
  }

  void _handleHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
  }
}
