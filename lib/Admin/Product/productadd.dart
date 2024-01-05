import 'package:bookstore/Admin/Product/productshow.dart';
import 'package:bookstore/Admin/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: ProductAdd()));
}

class ProductAdd extends StatefulWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  FilePickerResult? _filePickerResult;
  String? selectedAuthorId;
  String? selectedCategoryId;

  Future<void> _addProduct(BuildContext context) async {
    try {
      User? user = _auth.currentUser;
      if (user != null &&
          selectedAuthorId != null &&
          selectedCategoryId != null) {
        if (_filePickerResult != null && _filePickerResult!.files.isNotEmpty) {
          String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
          String uniqueFileName =
              '$timestamp${_filePickerResult!.files.single.name.replaceAll(" ", "_")}';

          await firebase_storage.FirebaseStorage.instance
              .ref()
              .child("product_images/$uniqueFileName")
              .putData(_filePickerResult!.files.single.bytes!);

          String imageUrl = await firebase_storage.FirebaseStorage.instance
              .ref("product_images/$uniqueFileName")
              .getDownloadURL();

          await _firestore.collection('product').add({
            'Product Name': _productNameController.text,
            'AuthorId': selectedAuthorId,
            'CategoryId': selectedCategoryId,
            'Price': _priceController.text,
            'Description': _descriptionController.text,
            'Image': imageUrl,
          });

          _productNameController.clear();
          _authorController.clear();
          _categoryController.clear();
          _priceController.clear();
          _descriptionController.clear();
          _filePickerResult = null;

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Success'),
                content: Text('Product added successfully!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProductShow()),
                      );
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('Please select an image.'),
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
    } catch (e) {
      print('Error adding product: $e');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Error adding product. Please try again.'),
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
  State<ProductAdd> createState() => _ProductAddState();
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

class _ProductAddState extends State<ProductAdd> {
  List<Author> authors = [];
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    fetchAuthors();
    fetchCategories();
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
              "Add Product",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              "Product's Details",
              style: TextStyle(
                fontSize: 18,
              ),
            ),
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
                        controller: widget._productNameController,
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
                              value: widget.selectedAuthorId,
                              hint: Text("Select Author"),
                              onChanged: (String? value) {
                                setState(() {
                                  widget.selectedAuthorId = value;
                                });
                              },
                              items: _buildAuthorDropdownItems(),
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: DropdownButton<String>(
                              value: widget.selectedCategoryId,
                              hint: Text("Select Category"),
                              onChanged: (String? value) {
                                setState(() {
                                  widget.selectedCategoryId = value;
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
                        controller: widget._priceController,
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
                        controller: widget._descriptionController,
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
                  _pickImage();
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
                    'Select Image',
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
                  widget._addProduct(context);
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
                    'Add Product',
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

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          widget._filePickerResult = result;
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }
}
