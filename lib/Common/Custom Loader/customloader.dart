import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomLoader extends StatelessWidget {
  final String message;

  CustomLoader({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF24375E), // Set the dark background color
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFffd482),
              ),
              child: Center(
                child: Image.asset(
                  'assets/verseVoyage.png',
                  width: 100,
                  height: 100,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.montserrat(
                fontSize: 20,
                
                color: Colors.white, // Set text color to white
              ),
            ),
          ],
        ),
      ),
    );
  }
}
