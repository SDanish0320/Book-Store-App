import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: UserReviewsPage(),
    );
  }
}

class UserReviewsPage extends StatefulWidget {
  @override
  _UserReviewsPageState createState() => _UserReviewsPageState();
}

class _UserReviewsPageState extends State<UserReviewsPage> {
  List<UserReview> userReviews = [
    UserReview(name: 'John Doe', rating: 4, review: 'Great product!'),
    UserReview(name: 'Jane Smith', rating: 5, review: 'Excellent quality.'),
    UserReview(name: 'Alice Johnson', rating: 3, review: 'Good, but could be better.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Reviews'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Average Rating:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Icon(Icons.star, size: 40, color: Colors.orange),
                Text(
                  calculateAverageRating().toStringAsFixed(1),
                  style: TextStyle(fontSize: 24),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'User Reviews:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: userReviews.length,
                itemBuilder: (context, index) {
                  return UserReviewWidget(userReview: userReviews[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  double calculateAverageRating() {
    if (userReviews.isEmpty) {
      return 0.0;
    }

    double totalRating = 0.0;
    for (var review in userReviews) {
      totalRating += review.rating;
    }

    return totalRating / userReviews.length;
  }
}

class UserReview {
  final String name;
  final double rating;
  final String review;

  UserReview({
    required this.name,
    required this.rating,
    required this.review,
  });
}

class UserReviewWidget extends StatelessWidget {
  final UserReview userReview;

  UserReviewWidget({required this.userReview});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.star, size: 24, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  userReview.rating.toString(),
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              '${userReview.name} says:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(userReview.review),
          ],
        ),
      ),
    );
  }
}


// import 'dart:html';

// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:flutter/material.dart';
// import 'package:watches/common.dart';
// import 'package:flutter_rating_bar/flutter_rating_bar.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:watches/login.dart';

// class Productdetail extends StatefulWidget {
//   String myid;
//   Productdetail(this.myid);
//   @override
//   State<Productdetail> createState() => _MyWidgetState();
// }

// class WatchImage {
//   String id;
//   String image;

//   WatchImage(
//     this.id,
//     this.image,
//   );
// }

// class Comment {
//   String id;
//   Timestamp time;
//   String comment;
//   double userratting; // Corrected data type
//   String name;

//   Comment(
//     this.id,
//     this.time,
//     this.comment,
//     this.userratting,
//     this.name,
//   );
// }

// class _MyWidgetState extends State<Productdetail> {
//   bool showRatingContainer = false;
//   dynamic Name;
//   dynamic price;
//   dynamic description;
//   double userRating = 0.0; // New: User rating
//   String userComment = ''; // New: User comment
//   List<WatchImage> _imageList = [];
//   void initState() {
//     fetchData();
//     fetchAverageRating();
//     _carouselController = CarouselController();
//     loadImageData().then((imageList) {
//       setState(() {
//         _imageList = imageList;
//       });
//     });
//   }

//   Future<List<WatchImage>> loadImageData() async {
//     try {
//       QuerySnapshot imageSnapshot =
//           await FirebaseFirestore.instance.collection('Watch_Image').get();
//       QuerySnapshot productSnapshot =
//           await FirebaseFirestore.instance.collection('Product').get();

//       List<QueryDocumentSnapshot> imageData = imageSnapshot.docs;
//       List<QueryDocumentSnapshot> productData = productSnapshot.docs;

//       List<WatchImage> mylist = [];

//       for (var product in productData) {
//         if (product.id == widget.myid) {
//           for (var image in imageData) {
//             if (image['Product_id_fk'] == product.id) {
//               mylist.add(WatchImage(
//                 image.id,
//                 image['watch_image'],
//               ));
//             }
//           }
//         }
//       }
//       print(mylist);
//       return mylist;
//     } catch (e) {
//       print("Error fetching data: $e");
//       throw e;
//     }
//   }

//   Future<void> fetchData() async {
//     try {
//       DocumentSnapshot data = await FirebaseFirestore.instance
//           .collection('Product')
//           .doc(widget.myid)
//           .get();
//       if (data.exists) {
//         Name = data.get("Product_Name");
//         price = data.get("Product_Price");
//         description = data.get("Product_Description");
//       }
//     } catch (e) {
//       print("Error fetching data: $e");
//     }
//   }

//   double ratingByUser = 0.0;

//   CarouselController _carouselController = CarouselController();
//   int _currentPage = 0;
//   dynamic a;
//   dynamic totalRatingsCount;

//   @override
//   Widget build(BuildContext context) {
//     FirebaseAuth auth = FirebaseAuth.instance;
//     User? currentUser = auth.currentUser;

//     if (currentUser == null) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => login()),
//       );
//     } else {}
//     a = currentUser?.uid;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Shopping Cart'),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Container(
//               child: Stack(
//                 children: [
//                   CarouselSlider.builder(
//                     itemCount: _imageList.length,
//                     itemBuilder:
//                         (BuildContext context, int index, int realIndex) {
//                       if (index >= 0 && index < _imageList.length) {
//                         return Stack(
//                           children: [
//                             Padding(
//                               padding:
//                                   const EdgeInsets.only(left: 8.0, right: 8.0),
//                               child: Container(
//                                 width: double.infinity,
//                                 height: 250,
//                                 // child: Image.network(
//                                 //   _imageList[index].image,
//                                 //   width: 100,
//                                 //   fit: BoxFit.cover,

//                                 // ),
//                                 child: Image.asset(
//                                   'logo.png',
//                                   width: 100,
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             ),
//                             Positioned(
//                               top: 20,
//                               left: 20,
//                               child: Container(
//                                 child: Center(
//                                   child: Text(
//                                     "$Name",
//                                     style: TextStyle(
//                                       fontSize: 35,
//                                       color: Color.fromARGB(255, 250, 170, 140),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         );
//                       } else {
//                         return Container();
//                       }
//                     },
//                     carouselController: _carouselController,
//                     options: CarouselOptions(
//                       height: 250.0,
//                       enlargeCenterPage: false,
//                       autoPlay: true,
//                       aspectRatio: 16 / 9,
//                       enableInfiniteScroll: true,
//                       viewportFraction: 1,
//                       onPageChanged: (index, reason) {
//                         setState(() {
//                           _currentPage = index;
//                         });
//                       },
//                     ),
//                   ),
//                   Positioned(
//                     bottom: 0,
//                     right: 0,
//                     child: Container(
//                       padding: EdgeInsets.all(16),
//                       child: Text(
//                         "\$$price",
//                         style: TextStyle(
//                           fontSize: 35,
//                           color: Color.fromARGB(255, 250, 170, 140),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Container(
//                   child: Center(
//                     child: Text(
//                       " $totalRatingsCount Rating",
//                       style: TextStyle(
//                           fontSize: 16,
//                           color: Color.fromARGB(255, 122, 118, 118)),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             Padding(
//               padding: const EdgeInsets.only(right: 20.0, left: 20.0),
//               child: Center(
//                 child: Container(
//                   child: Text(
//                     "$description",
//                     style: TextStyle(fontSize: 15),
//                   ),
//                 ),
//               ),
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 GestureDetector(
//                   onTap: () {},
//                   child: Container(
//                     width: 30.0,
//                     height: 30.0,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Color.fromARGB(255, 238, 232, 232),
//                     ),
//                     child: Center(
//                       child: Icon(
//                         Icons.favorite,
//                         color: Colors.black,
//                         size: 15,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   width: 5,
//                 ),
//                 GestureDetector(
//                   onTap: () {},
//                   child: Container(
//                     width: 30.0,
//                     height: 30.0,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Color.fromARGB(255, 238, 232, 232),
//                     ),
//                     child: Center(
//                       child: Icon(
//                         Icons.shopping_cart,
//                         color: Colors.black,
//                         size: 15,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   width: 5,
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     showRatingContainer = !showRatingContainer;
//                   },
//                   child: Container(
//                     width: 30.0,
//                     height: 30.0,
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: Color.fromARGB(255, 238, 232, 232),
//                     ),
//                     child: Center(
//                       child: Icon(
//                         Icons.comment,
//                         color: Colors.black,
//                         size: 15,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Visibility(
//               visible: showRatingContainer,
//               child: Container(
//                 padding: EdgeInsets.all(13),
//                 child: Column(
//                   children: [
//                     Container(
//                       alignment: Alignment.centerLeft,
//                       child: Text("Leave Your Comment"),
//                     ),
//                     RatingBar.builder(
//                       initialRating: userRating,
//                       minRating: 1,
//                       direction: Axis.horizontal,
//                       allowHalfRating: true,
//                       itemCount: 5,
//                       itemSize: 30.0,
//                       itemBuilder: (context, _) => Icon(
//                         Icons.star,
//                         color: Color.fromARGB(255, 250, 170, 140),
//                       ),
//                       onRatingUpdate: (rating) {
//                         setState(() {
//                           userRating = rating;
//                         });
//                       },
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.all(20.0),
//                       child: TextField(
//                         onChanged: (value) {
//                           setState(() {
//                             userComment = value;
//                           });
//                         },
//                         decoration: InputDecoration(
//                           hintText: 'Add your comment...',
//                         ),
//                       ),
//                     ),
//                     ElevatedButton(
//                       onPressed: () {
//                         saveRatingAndComment(widget.myid);
//                       },
//                       style: ElevatedButton.styleFrom(
//                         primary: Color.fromARGB(255, 250, 170, 140),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8.0),
//                         ),
//                       ),
//                       child: Container(
//                         width: 200,
//                         height: 50.0,
//                         child: Center(
//                           child: Text(
//                             "Submit Rating",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 15,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Container(
//               child: Text("Show Coment"),
//             ),
//             Container(
//               height: 100,
//               child: FutureBuilder(
//                   future: fetchRatingOfUser(),
//                   builder: (context, snapshot) {
//                     if (snapshot.hasError) {
//                       print("Error: ${snapshot.error}");
//                       return Center(child: Text("Error: ${snapshot.error}"));
//                     } else if (snapshot.data == null ||
//                         (snapshot.data as List<Comment>).isEmpty) {
//                       return Center(child: Text("No data available"));
//                     } else {
//                       List<Comment> mylist = snapshot.data as List<Comment>;

//                       return ListView.builder(
//                           itemCount: mylist.length,
//                           itemBuilder: (context, index) {
//                             Comment product = mylist[index];
//                             return Column(
//                               children: [
//                                 Row(
//                                   mainAxisAlignment:
//                                       MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Column(
//                                       children: [
//                                         Container(
//                                           child: RatingBar.builder(
//                                             initialRating:
//                                                 mylist[index].userratting,
//                                             itemCount: 5,
//                                             itemSize: 24,
//                                             itemBuilder: (context, _) => Icon(
//                                               Icons.star,
//                                               color: Color.fromARGB(
//                                                   255, 250, 170, 140),
//                                             ),
//                                             onRatingUpdate: (double rating) {},
//                                           ),
//                                         ),
//                                         Container(
//                                           child: Text(mylist[index].name),
//                                         )
//                                       ],
//                                     ),
//                                     Container(
//                                       child: Text(mylist[index]
//                                           .time
//                                           .toDate()
//                                           .toString()),
//                                     )
//                                   ],
//                                 ),
//                                 Container(
//                                   child: Text(mylist[index].comment),
//                                 )
//                               ],
//                             );
//                           });
//                     }
//                   }),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Future<void> fetchAverageRating() async {
//     try {
//       QuerySnapshot<Map<String, dynamic>> ratings = await FirebaseFirestore
//           .instance
//           .collection('Product_Rating')
//           .where('Product_id_fk', isEqualTo: widget.myid)
//           .get();

//       if (ratings.docs.isNotEmpty) {
//         double totalRating = 0.0;

//         for (QueryDocumentSnapshot<Map<String, dynamic>> rating
//             in ratings.docs) {
//           totalRating += rating.get("Rating");
//         }

//         ratingByUser = totalRating / ratings.docs.length;
//         totalRatingsCount = ratings.docs.length;

//         print("Total Ratings Count: $totalRatingsCount");
//         print("Average Rating: $ratingByUser");
//       } else {
//         print("No ratings found for product with ID: ${widget.myid}");
//       }
//     } catch (e) {
//       print("Error fetching data: $e");
//     }
//   }

//   Future<void> saveRatingAndComment(String id) async {
//     try {
//       FirebaseFirestore db = FirebaseFirestore.instance;
//       CollectionReference tab = db.collection('Product_Rating');

//       Map<String, dynamic> userInfo = {
//         'Rating': userRating,
//         'Comment': userComment,
//         'User_id_fk': a,
//         'Product_id_fk': id,
//         'Timestamp': FieldValue.serverTimestamp(),
//       };

//       await tab.add(userInfo);
//     } catch (e) {
//       print("Error saving rating and comment: $e");
//     }
//   }

//   Future<List<Comment>> fetchRatingOfUser() async {
//     try {
//       QuerySnapshot ratingSnapshot =
//           await FirebaseFirestore.instance.collection('Product_Rating').get();

//       List<QueryDocumentSnapshot> ratingData = ratingSnapshot.docs;

//       QuerySnapshot productSnapshot =
//           await FirebaseFirestore.instance.collection('Product').get();

//       List<QueryDocumentSnapshot> productData = productSnapshot.docs;

//       QuerySnapshot userSnapshot =
//           await FirebaseFirestore.instance.collection('Users').get();

//       List<QueryDocumentSnapshot> userData = userSnapshot.docs;

//       List<Comment> mylist = [];

//       for (var rating in ratingData) {
//         if (rating['Product_id_fk'] == widget.myid) {
//           for (var user in userData) {
//             if (user.id == rating['User_id_fk']) {
//               mylist.add(Comment(
//                 rating.id,
//                 rating['Timestamp'],
//                 rating['Comment'],
//                 rating['Rating'].toDouble(),
//                 user['Fullname'],
//               ));
//             }
//           }
//         }
//       }

//       return mylist;
//     } catch (e) {
//       print("Error fetching data: $e");
//       throw e;
//     }
//   }
// }