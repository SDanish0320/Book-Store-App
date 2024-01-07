import 'package:flutter/material.dart';

class OrderPurchased extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        color: Color(0xFFffd482), // Set the background color here
        child: Stack(
          children: [
            Center(
              child: Column(
                children: [
                  SizedBox(height: 200),
                  Container(
                    height: 400,
                    width: 400,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          child: Image.asset("tick.png", width: 200),
                        ),
                        SizedBox(height: 20),
                        Text(
                          "You have successfully placed your order",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.none, // Remove underline
                          ),
                        ),
                        SizedBox(height: 20), // Add some spacing
                        Text(
                          "Thank you for shopping with us!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            decoration: TextDecoration.none, // Remove underline
                          ),
                        ),
                      ],
                    ),
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