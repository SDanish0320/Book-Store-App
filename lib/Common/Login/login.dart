import 'package:bookstore/User%20End/layout.dart';
import 'package:flutter/material.dart';
import 'package:bookstore/Admin/adminmain.dart';
import 'package:bookstore/ForgetPassword.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
//for email validation
  String? _email_val;
  String? _errorText_email;
  bool satetee = true;
  //for pass validation
  String? _errorText_password;
  String? _password_val;
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF24375E),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 80),
            Image(
              image: AssetImage('verseVoyage.png'),
              height: 200,
              width: 200,
            ),
            Container(
              width: 450,
              padding: EdgeInsets.only(
                top: 20,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      style: TextStyle(
                        color: Color(0xFFffd482),
                      ),
                      controller: _emailController,
                      decoration: InputDecoration(
                        errorText: _errorText_email,
                        errorStyle: TextStyle(color: Color(0xFFffd482)),
                        hintText: 'Email',
                        hintStyle: TextStyle(
                            color: Color(0xFFffd482)), // Set hint text color
                        prefixIcon: Icon(Icons.email,
                            color: Color(0xFFffd482)), // Set prefix icon color
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color(
                                  0xFFffd482)), // Set border color when focused
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fillColor: Color(0xFFffd482),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color(
                                  0xFFffd482)), // Set border color when not focused
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      cursorColor: Color(0xFFffd482), // Set cursor color
                      onChanged: _validateEmail,
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      style: TextStyle(
                        color: Color(0xFFffd482),
                      ),
                      obscureText: satetee,
                      controller: _passwordController,
                      decoration: InputDecoration(
                        errorText: _errorText_password,
                        errorStyle: TextStyle(color: Color(0xFFffd482)),
                        hintText: 'Password',
                        hintStyle: TextStyle(
                            color: Color(0xFFffd482)), // Set hint text color
                        prefixIcon: Icon(Icons.lock, color: Color(0xFFffd482)),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.visibility_off,
                              color: Color(0xFFffd482)),
                          onPressed: () {
                            setState(() {
                              if (satetee == false) {
                                satetee = true;
                              } else {
                                satetee = false;
                              }
                            });
                          },
                        ), // Set prefix icon color
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color(
                                  0xFFffd482)), // Set border color when focused
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Color(
                                  0xFFffd482)), // Set border color when not focused
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fillColor: Color(0xFFffd482),
                      ),
                      cursorColor: Color(0xFFffd482), // Set cursor color
                      onChanged: _validatePassword,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Column(
                    children: [
                      Container(
                        child: ElevatedButton(
                          onPressed: () {
                            login();
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
                            padding: EdgeInsets.symmetric(
                                horizontal: 140, vertical: 10),
                            child: Text(
                              'LOGIN',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ForgetPassword(),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot Password',
                          style: TextStyle(
                            color: Color(0xFFffd482),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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

  Future<void> login() async {
    try {
      String email = _emailController.text.trim();
      String password = _passwordController.text;

      // Sign in with email and password
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Retrieve user data from Firestore
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

        // Fetch the user's role from Firestore
        String userRole = userData['role'];

        // Navigate based on the user's role
        if (userRole == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Admin(),
            ),
          );
        } else if (userRole == 'user') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Layoutt(),
            ),
          );
        }
      } else {
        print('User not found in database');
        // Handle the case where user data is not found
      }
    } catch (e) {
      print('Error during login: $e');
      // Handle login errors here
    }
  }
}
