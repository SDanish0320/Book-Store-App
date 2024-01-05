import 'package:bookstore/Admin/Product/productshow.dart';
import 'package:bookstore/Admin/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class ProductUpdate extends StatefulWidget {
  final String productId;

  ProductUpdate({required this.productId});

  @override
  State<ProductUpdate> createState() => _ProductUpdateState();
}

class Author {
  final String id;
  final String name;

  Author({required this.id, required this.name});

  factory Author.fromSnapshot(QueryDocumentSnapshot doc) {
    return Author(
      id: doc.id,
      name: doc['Author Name'],
    );
  }
}

class Category {
  final String id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromSnapshot(QueryDocumentSnapshot doc) {
    return Category(
      id: doc.id,
      name: doc['category'],
    );
  }
}

class _ProductUpdateState extends State<ProductUpdate> {
  TextEditingController _productNameController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  String? selectedAuthorId;
  String? selectedCategoryId;
  TextEditingController _imageController = TextEditingController();

  FilePickerResult? _filePickerResult;

  List<Author> authors = [];
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    fetchData(); // Fetch product data when the widget is initialized
    fetchAuthors();
    fetchCategories();
  }

  Future<void> fetchData() async {
    try {
      DocumentSnapshot productSnapshot = await FirebaseFirestore.instance
          .collection('product')
          .doc(widget.productId)
          .get();

      if (productSnapshot.exists) {
        setState(() {
          _productNameController.text = productSnapshot.get('Product Name');
          _priceController.text = productSnapshot.get('Price');
          _descriptionController.text = productSnapshot.get('Description');
          selectedAuthorId = productSnapshot.get('AuthorId');
          selectedCategoryId = productSnapshot.get('CategoryId');
          _imageController.text = productSnapshot.get('Image');
        });
      }
    } catch (e) {
      print("Error fetching product data: $e");
    }
  }

  Future<void> fetchAuthors() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('author').get();

      setState(() {
        authors =
            querySnapshot.docs.map((doc) => Author.fromSnapshot(doc)).toList();
      });
    } catch (e) {
      print('Error fetching authors: $e');
    }
  }

  Future<void> fetchCategories() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('category').get();

      setState(() {
        categories = querySnapshot.docs
            .map((doc) => Category.fromSnapshot(doc))
            .toList();
      });
    } catch (e) {
      print('Error fetching categories: $e');
    }
  }

  List<DropdownMenuItem<String>> _buildAuthorDropdownItems() {
    return authors.map((author) {
      return DropdownMenuItem<String>(
        value: author.id,
        child: Text(author.name),
      );
    }).toList();
  }

  List<DropdownMenuItem<String>> _buildCategoryDropdownItems() {
    return categories.map((category) {
      return DropdownMenuItem<String>(
        value: category.id,
        child: Text(category.name),
      );
    }).toList();
  }

  Future<void> _selectFile() async {
    try {
      _filePickerResult = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      print("File Selected!");
    } catch (e) {
      print("Error picking file: $e");
    }
  }

  Future<void> updateProduct(BuildContext context) async {
    try {
      String imageUrl = '';

      if (_filePickerResult != null && _filePickerResult!.files.isNotEmpty) {
        String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
        String uniqueFileName =
            '$timestamp${_filePickerResult!.files.single.name.replaceAll(" ", "_")}';

        await firebase_storage.FirebaseStorage.instance
            .ref()
            .child("product_images/$uniqueFileName")
            .putData(_filePickerResult!.files.single.bytes!);

        imageUrl = await firebase_storage.FirebaseStorage.instance
            .ref("product_images/$uniqueFileName")
            .getDownloadURL();
      }
      else {
        // If no new image is selected, use the existing image URL
        imageUrl = _imageController.text;
      }

      await FirebaseFirestore.instance
          .collection('product')
          .doc(widget.productId)
          .update({
        'Product Name': _productNameController.text,
        'AuthorId': selectedAuthorId,
        'CategoryId': selectedCategoryId,
        'Price': _priceController.text,
        'Description': _descriptionController.text,
        'Image': imageUrl,
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Product updated successfully!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Add navigation or any other action after updating
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('Error updating product: $e');

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(
                'An error occurred while updating the product. Please try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      mybody: Center(
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              "Update Product",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text("Product Details", style: TextStyle(fontSize: 18)),
            SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Container(
                width: 450,
                padding: EdgeInsets.only(
                  top: 10,
                ),
                child: Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: _productNameController,
                        decoration: InputDecoration(
                          hintText: 'Product Name',
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFffd482)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButton<String>(
                              value: selectedAuthorId,
                              hint: Text("Select Author"),
                              onChanged: (String? value) {
                                setState(() {
                                  selectedAuthorId = value;
                                });
                              },
                              items: _buildAuthorDropdownItems(),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: DropdownButton<String>(
                              value: selectedCategoryId,
                              hint: Text("Select Category"),
                              onChanged: (String? value) {
                                setState(() {
                                  selectedCategoryId = value;
                                });
                              },
                              items: _buildCategoryDropdownItems(),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Price',
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFffd482)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: _descriptionController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: 'Description',
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFffd482)),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        controller: _imageController,
                        decoration: InputDecoration(
                          hintText: 'Image',
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFFffd482)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              width: 450,
              child: ElevatedButton(
                onPressed: () {
                  _selectFile();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF24375E),
                  foregroundColor: Color(0xFFffd482),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    'SELECT IMAGE',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              width: 450,
              child: ElevatedButton(
                onPressed: () {
                  updateProduct(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProductShow()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF24375E),
                  foregroundColor: Color(0xFFffd482),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    'UPDATE',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
