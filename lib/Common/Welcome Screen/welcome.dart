import 'package:bookstore/Common/Login/login.dart';
import 'package:bookstore/Common/Sign%20Up/signup.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 500,
              padding: EdgeInsets.all(20),
              color: Color(0xFF24375E),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 50),
                      Image.asset(
                        "assets/verseVoyage.png",
                        height: 200,
                        width: 200,
                      ),
                      const SizedBox(height: 60),
                      Text(
                        "Verse Voyage",
                        style: TextStyle(
                            color: Color(0xFFffd482),
                            fontWeight: FontWeight.bold,
                            fontSize: 24),
                      ),
                      const SizedBox(height: 10),
                      Flexible(
                          child: Text(
                              'Discover a world of books at your fingertips',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Color(0xFFffd482)))),
                    ],
                  ))
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Add your combined Google and Facebook login functionality here
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color(0xFF24375E), // Set the button color
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Login(),
                              ),
                            );
                          },
                          child: Text('Login',
                              style: TextStyle(
                                  fontSize: 16, color: Color(0xFFffd482))),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account? ',
                        style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF24375E),
                            fontFamily: 'Roboto'),
                      ),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => SignUp()),
                            );
                          },
                          child: Text(
                            'SIGN UP here.',
                            style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF24375E),
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color(0xFF24375E), // Set the background color
                      borderRadius:
                          BorderRadius.circular(12.0), // Set the border radius
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Login with  ",
                          style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFFffd482),
                              fontFamily: 'Roboto'),
                        ),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              // Add your Google login functionality here
                            },
                            child: FaIcon(
                              FontAwesomeIcons.google,
                              color:
                                  Color(0xFFffd482), // Set your desired color
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          " OR ",
                          style:
                              TextStyle(fontSize: 16, color: Color(0xFFffd482)),
                        ),
                        SizedBox(width: 8),
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              // Add your Facebook login functionality here
                            },
                            child: FaIcon(
                              FontAwesomeIcons.facebook,
                              color:
                                  Color(0xFFffd482), // Set your desired color
                            ),
                          ),
                        ),
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
}
