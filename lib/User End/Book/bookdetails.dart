import 'package:bookstore/Common/Custom%20Loader/customloader.dart';
import 'package:bookstore/User%20End/Cart/cart.dart';
import 'package:bookstore/User%20End/Cart/cartProvider.dart';
import 'package:bookstore/User%20End/Wishlist/wishlistProvider.dart';
import 'package:bookstore/User%20End/Wishlist/wishlistuser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

class BookDetails extends StatefulWidget {
  final String productId;

  BookDetails({required this.productId});

  @override
  State<BookDetails> createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {
  late Future<DocumentSnapshot> bookDetails;
  late Future<DocumentSnapshot> authorDetails;
  late Future<DocumentSnapshot> catName;
  List<dynamic> bookReviews = [];
  late Future<List<DocumentSnapshot>> fetchData;

  @override
  void initState() {
    super.initState();
    fetchData = initializeData();
  }

  Future<List<DocumentSnapshot>> initializeData() async {
    try {
      final bookDetails = fetchBookDetails();
      final catName = fetchCatName();
      final authorDetails = fetchAuthorDetails();
      await fetchBookReviews();

      return Future.wait([bookDetails, catName, authorDetails]);
    } catch (error) {
      print('Error initializing data: $error');
      throw error;
    }
  }

  dynamic bookname;
  dynamic userName;

  Future<DocumentSnapshot> fetchBookDetails() async {
    try {
      final bookDetails = await FirebaseFirestore.instance
          .collection('product')
          .doc(widget.productId)
          .get();
      setState(() {
        bookname = bookDetails.get("Product Name");
      });
      return bookDetails;
    } catch (e) {
      throw 'Error fetching book details: $e';
    }
  }

  Future<DocumentSnapshot> fetchCatName() async {
    try {
      final bookDetails = await FirebaseFirestore.instance
          .collection('product')
          .doc(widget.productId)
          .get();

      final catId = bookDetails['CategoryId'];
      return await FirebaseFirestore.instance
          .collection('category')
          .doc(catId)
          .get();
    } catch (e) {
      throw 'Error fetching category details: $e';
    }
  }

  Future<DocumentSnapshot> fetchAuthorDetails() async {
    try {
      final bookDetails = await FirebaseFirestore.instance
          .collection('product')
          .doc(widget.productId)
          .get();

      final authorId = bookDetails['AuthorId'];
      return await FirebaseFirestore.instance
          .collection('author')
          .doc(authorId)
          .get();
    } catch (e) {
      throw 'Error fetching author details: $e';
    }
  }

  Future<DocumentSnapshot> fetchUserDetails(String userId) async {
    try {
      return await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
    } catch (e) {
      throw 'Error fetching user details: $e';
    }
  }

  Future<void> fetchBookReviews() async {
    try {
      await fetchBookDetails(); // Wait for fetchBookDetails to complete

      final reviewsSnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('productName', isEqualTo: bookname)
          .get();

      for (var reviewDoc in reviewsSnapshot.docs) {
        var review = reviewDoc.data();

        if (review.containsKey('userId') && review['userId'] != null) {
          final userId = review['userId'];
          final userSnapshot = await fetchUserDetails(userId);

          if (userSnapshot != null && userSnapshot['username'] != null) {
            final userName = userSnapshot['username'];

            if (userName != null &&
                review['reviewText'] != null &&
                review['rating'] != null &&
                review['orderId'] != null) {
              // Update the list of book reviews
              //setState(() {
              bookReviews.add({
                'userName': userName,
                'review': review,
                //})
              });
            }
          }
        }
      }
      setState(() {});
    } catch (e) {
      print('Error fetching reviews: $e');
    }
  }

  Future<double> calculateAverageRating(String productName) async {
    try {
      final reviewsSnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('productName', isEqualTo: productName)
          .get();

      if (reviewsSnapshot.docs.isNotEmpty) {
        double totalRating = 0.0;
        for (var reviewDoc in reviewsSnapshot.docs) {
          var review = reviewDoc.data();
          if (review.containsKey('rating') && review['rating'] != null) {
            totalRating += review['rating'];
          }
        }

        return totalRating / reviewsSnapshot.docs.length;
      } else {
        return 0.0; // No reviews available, return 0 as the default rating
      }
    } catch (e) {
      print('Error calculating average rating: $e');
      return 0.0; // Handle the error as needed, return 0 as the default rating
    }
  }

  void _showWishlistBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          color: Color(0xFF24375E), // Set the background color
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Item added to wishlist!',
                style: TextStyle(
                  color: Colors.white, // Text color
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the bottom sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Wishlist(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFffd482),
                  onPrimary: Color(0xFF24375E), // Text color
                ),
                child: Text('View Wishlist'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCartBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Item added to cart!',
                style: TextStyle(
                  color: Colors.white, // Text color
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close the bottom sheet
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Cart(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  primary: Color(0xFFffd482),
                  onPrimary: Color(0xFF24375E), // Button text color
                ),
                child: Text('View Cart'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: fetchData,
        builder: (context, AsyncSnapshot<List<DocumentSnapshot>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CustomLoader(
                message: 'Unraveling Book Secrets...',
              ),
            );
          } else if(snapshot.hasError ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            return Center(child: Text('Error loading details'));
          } else {
            var bookData = snapshot.data![0];
            var catData = snapshot.data![1];
            var authorData = snapshot.data![2];

            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    color: Color(0xFF24375E),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.arrow_left_sharp,
                                            color: Color(0xFFffd482),
                                            size: 30,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 40),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      bookData['Image'],
                                      width: 170,
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 15),
                              Text(
                                bookData['Product Name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFffd482),
                                  fontSize: 20,
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  style: DefaultTextStyle.of(context).style,
                                  children: [
                                    TextSpan(
                                      text: 'By: ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 18,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '${authorData['Author Name']}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFffd482),
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          "Ratings",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        FutureBuilder<double>(
                                          future:
                                              calculateAverageRating(bookname),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return CircularProgressIndicator();
                                            } else if (snapshot.hasError) {
                                              return Text(
                                                "Error loading average rating",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.red,
                                                ),
                                              );
                                            } else {
                                              double averageRating =
                                                  snapshot.data ?? 0.0;
                                              return Text(
                                                averageRating
                                                    .toStringAsFixed(1),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color.fromARGB(
                                                      255, 255, 233, 33),
                                                ),
                                              );
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          "Genre",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          '${catData['category']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(
                                              255,
                                              6,
                                              194,
                                              0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          "Price",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          '${bookData['Price']}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: const Color.fromARGB(
                                              255,
                                              255,
                                              17,
                                              0,
                                            ),
                                            fontWeight: FontWeight.bold,
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
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Description",
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          '${bookData['Description']}',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          height: 200,
                          padding:
                              EdgeInsets.all(16), // Add padding for spacing
                          decoration: BoxDecoration(
                            color: Colors.white, // Container background color
                            borderRadius: BorderRadius.circular(
                                10), // Optional: Add border radius
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 2,
                                blurRadius: 5,
                                offset:
                                    Offset(0, 2), // changes position of shadow
                              ),
                            ],
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Reviews",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 21,
                                  ),
                                ),
                                SizedBox(height: 8),
                                // Display reviews dynamically using bookReviews variable
                                if (bookReviews.isNotEmpty)
                                  Column(
                                    children: bookReviews
                                        .map(
                                          (reviewData) => ListTile(
                                            title: Text(
                                              reviewData['userName'],
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                RatingBarIndicator(
                                                  rating: reviewData['review']
                                                          ['rating']
                                                      .toDouble(),
                                                  itemBuilder:
                                                      (context, index) => Icon(
                                                    Icons.star,
                                                    color: const Color.fromARGB(
                                                        255, 255, 191, 0),
                                                  ),
                                                  itemCount: 5,
                                                  itemSize: 20.0,
                                                  unratedColor:
                                                      Colors.grey[300],
                                                  direction: Axis.horizontal,
                                                ),
                                                Text(
                                                  reviewData['review']
                                                      ['reviewText'],
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  )
                                else
                                  Text(
                                    'No reviews available.',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Container(
                          height: 60,
                          padding: EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFF24375E),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Consumer<CartProvider>(
                                builder: (context, cartProvider, child) {
                                  return GestureDetector(
                                    onTap: () {
                                      String name = bookData['Product Name'];
                                      double price =
                                          double.parse(bookData['Price']);
                                      String imageUrl = bookData['Image'];

                                      CartItem newItem = CartItem(
                                        name: name,
                                        quantity: 1,
                                        unitPrice: price,
                                        imageUrl: imageUrl,
                                      );

                                      cartProvider.addToCart(newItem);

                                      _showCartBottomSheet();
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.shopping_cart,
                                          color: Colors.orange,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "ADD TO CART",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                            color: Color(0xFFffd482),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              Container(
                                height: 40,
                                width: 2,
                                color: Colors.white,
                              ),
                              Consumer<WishlistProvider>(
                                builder: (context, wishlistProvider, child) {
                                  return GestureDetector(
                                    onTap: () {
                                      WishlistItem newItem = WishlistItem(
                                        name: bookData['Product Name'],
                                        unitPrice: double.parse(
                                          bookData['Price'],
                                        ),
                                        imageUrl: bookData['Image'],
                                      );

                                      wishlistProvider.addToWishlist(newItem);

                                      _showWishlistBottomSheet();
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.favorite,
                                          color: const Color.fromARGB(
                                            255,
                                            255,
                                            26,
                                            10,
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "ADD to WISHLIST",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.5,
                                            color: Color(0xFFffd482),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

