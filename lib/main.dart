import 'package:bookstore/Common/Splash%20Screen/splashscreen.dart';
import 'package:bookstore/User%20End/Cart/cartProvider.dart';
import 'package:bookstore/User%20End/OrderAll/orderprovider.dart';
import 'package:bookstore/User%20End/Wishlist/wishlistProvider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyBM0UGYGc95Qk2VOU66IApWE0Zran4Qd6M',
      appId: '1:381357708681:android:fb927e427d14f204523d58',
      messagingSenderId: '381357708681',
      projectId: 'verse-voyage',
      storageBucket: 'gs://verse-voyage.appspot.com',
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        // Add other providers as needed
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Verse Voyage',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
