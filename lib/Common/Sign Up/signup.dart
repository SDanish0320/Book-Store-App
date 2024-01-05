import 'package:bookstore/Common/Login/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class SignUp extends StatefulWidget {
  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  //for email validation
  String? _email_val;
  String? _errorText_email;
  bool satetee = true;
  //for pass validation
  String? _errorText_password;
  String? _password_val;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _contactNumberController =
      TextEditingController();

  FilePickerResult? _filePickerResult;
  bool isSigningUp = false;

  Future<void> _selectFile() async {
    try {
      _filePickerResult = await FilePicker.platform.pickFiles();
      print("File Selected!");
      setState(() {});
    } catch (e) {
      print("Error picking file: $e");
    }
  }

  Future<void> _uploadFile() async {
    if (isSigningUp) {
      print("Already signing up, skipping...");
      return;
    }
    try {
      if (_filePickerResult != null && _filePickerResult!.files.isNotEmpty) {
        String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        String uniqueFileName =
            '$timestamp${_filePickerResult!.files.single.name.replaceAll(" ", "_")}';

        await firebase_storage.FirebaseStorage.instance
            .ref()
            .child("uploads/${uniqueFileName}")
            .putData(_filePickerResult!.files.single.bytes!);

        String downloadURL = await firebase_storage.FirebaseStorage.instance
            .ref("uploads/${uniqueFileName}")
            .getDownloadURL();
        isSigningUp = true; // Set the flag to true

        UserCredential userCredential =
            await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        User? user = userCredential.user;
        print('Sign up successful: ${user?.uid}');
        CollectionReference tab = FirebaseFirestore.instance
            .collection("users"); // Change to your collection name
        Map<String, dynamic> data = {
          'username': _usernameController.text,
          'password': _passwordController.text,
          'email': _emailController.text,
          'contactNumber': _contactNumberController.text,
          'role': "user",
          'file_path': downloadURL,
        };
        tab.doc(user?.uid).set(data);
        print("File uploaded successfully!");
      } else {
        print("Please select a file first");
      }
    } catch (e) {
      print("Error uploading file: $e");
      print("Error uploading file. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Scaffold(
        backgroundColor: Color(0xFF24375E),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Image(
                  image: AssetImage('verseVoyage.png'),
                  height: 200,
                  width: 200,
                ),
                // Container(
                //   height: 100,
                //   width: 400,
                //   child: Row(
                //     children: [
                //       Expanded(
                //         child: ElevatedButton(
                //           onPressed: () {
                //             Navigator.push(
                //               context,
                //               MaterialPageRoute(builder: (context) => MyApp()),
                //             );
                //           },
                //           style: ElevatedButton.styleFrom(
                //             backgroundColor: Color(0xFFffd482),
                //             foregroundColor: Color(0xFF24375E),
                //             elevation: 5,
                //             shape: RoundedRectangleBorder(
                //               borderRadius: BorderRadius.circular(10),
                //             ),
                //           ),
                //           child: Padding(
                //             padding: const EdgeInsets.all(12.0),
                //             child: Text(
                //               'Login',
                //               style: TextStyle(fontSize: 20),
                //             ),
                //           ),
                //         ),
                //       ),
                //       SizedBox(
                //         height: 100,
                //         width: 20,
                //       ),
                //       Expanded(
                //         child: ElevatedButton(
                //           onPressed: () {},
                //           style: ElevatedButton.styleFrom(
                //             backgroundColor: Color(0xFFffd482),
                //             foregroundColor: Color(0xFF24375E),
                //             elevation: 5,
                //             shape: RoundedRectangleBorder(
                //               borderRadius: BorderRadius.circular(10),
                //             ),
                //           ),
                //           child: Padding(
                //             padding: const EdgeInsets.all(12.0),
                //             child: Text(
                //               'Sign Up',
                //               style: TextStyle(fontSize: 20),
                //             ),
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                Container(
                  width: 450,
                  padding: EdgeInsets.only(
                    top: 10,
                  ),
                  child: Column(
                    children: [
                      TextField(
                        style: TextStyle(
                          color: Color(0xFFffd482),
                        ),
                        controller: _usernameController,
                        decoration: InputDecoration(
                          hintText: 'Username',
                          hintStyle:
                              TextStyle(fontSize: 14, color: Color(0xFFffd482)),
                          prefixIcon: Icon(
                            Icons.person,
                            color: Color(0xFFffd482),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        style: TextStyle(
                          color: Color(0xFFffd482),
                        ),
                        controller: _emailController,
                        decoration: InputDecoration(
                          errorText: _errorText_email,
                          errorStyle: TextStyle(color: Color(0xFFffd482)),
                          hintText: 'Email Address',
                          hintStyle:
                              TextStyle(fontSize: 14, color: Color(0xFFffd482)),
                          prefixIcon:
                              Icon(Icons.email, color: Color(0xFFffd482)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        cursorColor: Color(0xFFffd482), // Set cursor color
                      onChanged: _validateEmail,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        style: TextStyle(
                          color: Color(0xFFffd482),
                        ),
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          errorText: _errorText_password,
                          errorStyle: TextStyle(color: Color(0xFFffd482)),
                          hintText: 'Password',
                          hintStyle:
                              TextStyle(fontSize: 14, color: Color(0xFFffd482)),
                          prefixIcon:
                              Icon(Icons.lock, color: Color(0xFFffd482)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        cursorColor: Color(0xFFffd482), // Set cursor color
                      onChanged: _validatePassword,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        style: TextStyle(
                          color: Color(0xFFffd482),
                        ),
                        controller: _contactNumberController,
                        decoration: InputDecoration(
                          hintText: 'Contact Number',
                          hintStyle:
                              TextStyle(fontSize: 14, color: Color(0xFFffd482)),
                          prefixIcon: Icon(
                            Icons.contact_phone,
                            color: Color(0xFFffd482),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    _selectFile(); // Call the file picking method
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFffd482),
                    foregroundColor: Color(0xFF24375E),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Select File',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                ElevatedButton(
                  onPressed: () {
                    _uploadFile();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFffd482),
                    foregroundColor: Color(0xFF24375E),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                _filePickerResult != null && _filePickerResult!.files.isNotEmpty
                    ? Text(_filePickerResult!.files.single.name)
                    : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _validateEmail(String value) {
    final RegExp _emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    setState(() {
      if (value.isEmpty) {
        _errorText_email = 'Please enter your email';
      } else if (!_emailRegExp.hasMatch(value)) {
        _errorText_email = 'Please enter a valid email address';
      } else {
        _errorText_email = null;
      }
      _email_val = value;
    });
  }

  void _validatePassword(String value) {
    final RegExp _passwordRegExp = RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$',
    );
    setState(() {
      if (value.isEmpty) {
        _errorText_password = 'Please enter your password';
      } else if (!_passwordRegExp.hasMatch(value)) {
        _errorText_password =
            'Password must have at least 6 characters with a mix of letters and numbers';
      } else {
        _errorText_password = null;
      }
      _password_val = value;
    });
  }
}
