import 'package:bookstore/User%20End/layout.dart';
import 'package:flutter/material.dart';
import 'package:bookstore/Admin/adminmain.dart';
import 'package:bookstore/Common/Login/ForgetPassword.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String? _email_val;
  String? _errorText_email;
  bool satetee = true;
  String? _errorText_password;
  String? _password_val;
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  bool showForgotPasswordButton = false;

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

  void _showErrorDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          backgroundColor: Color(0xFF24375E),
          titleTextStyle: TextStyle(color: Color(0xFFffd482)),
          contentTextStyle: TextStyle(color: Color(0xFFffd482)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> login() async {
    try {
      String email = _emailController.text.trim();
      String password = _passwordController.text;

      if (email.isEmpty || password.isEmpty) {
        return;
      }

      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('userId', userCredential.user!.uid);

        String userRole = userData['role'];

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
        // Show custom AlertDialog for user not found in the database
        _showErrorDialog(
          'Error',
          'Invalid email. Please enter a valid email.',
        );

        // Set the boolean variable to true to show the "Forgot Password" button
        setState(() {
          showForgotPasswordButton = true;
        });
      }
    } catch (e) {
      print('Error during login: $e');

      String errorMessage = 'An error occurred during login. Please try again.';

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'Invalid email. Please enter a valid email.';
            break;
          case 'wrong-password':
            errorMessage =
                'Invalid password. Please enter the correct password.';
            break;
        }
      }

      _showErrorDialog('Error', errorMessage);

      // Set the boolean variable to true to show the "Forgot Password" button
      setState(() {
        showForgotPasswordButton = true;
      });
    }
  }

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
                        hintStyle: TextStyle(color: Color(0xFFffd482)),
                        prefixIcon: Icon(Icons.email, color: Color(0xFFffd482)),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFffd482)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fillColor: Color(0xFFffd482),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFffd482)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      cursorColor: Color(0xFFffd482),
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
                        hintStyle: TextStyle(color: Color(0xFFffd482)),
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
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFffd482)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFFffd482)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        fillColor: Color(0xFFffd482),
                      ),
                      cursorColor: Color(0xFFffd482),
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
                                horizontal: 110, vertical: 10),
                            child: Text(
                              'LOGIN',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                      if (showForgotPasswordButton)
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
}
