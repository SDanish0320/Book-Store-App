
import 'package:bookstore/User%20End/Book/bookdetails.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyInputFeild extends StatelessWidget {
  const MyInputFeild({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          SizedBox(width: 10),
          Icon(Icons.search),
          SizedBox(width: 6),
          Expanded(
            child: _buildSearchTextField(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTextField(BuildContext context) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('product').snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      }

      if (!snapshot.hasData) {
        return Text('Loading...');
      }

      final List<DocumentSnapshot> products = snapshot.data!.docs;

      return Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          final filteredProducts = products.where((product) =>
              product['Product Name']
                  .toString()
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase()));
          if (filteredProducts.isEmpty) {
            return ["Not Available"];
          } else {
            return filteredProducts
                .map<String>((product) => product['Product Name'].toString())
                .toList();
          }
        },
        onSelected: (String selectedProduct) {
          if (selectedProduct == "Not Available") {
            // Handle the case when the product is not available
            // You can show a dialog, display a message, etc.
            print("Product not available");
          } else {
            final selectedProductId = products
                .firstWhere(
                  (product) => product['Product Name'] == selectedProduct,
                )
                .id;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    BookDetails(productId: selectedProductId),
              ),
            );
          }
        },
        fieldViewBuilder: (BuildContext context,
            TextEditingController textEditingController,
            FocusNode focusNode,
            VoidCallback onFieldSubmitted) {
          return TextFormField(
            controller: textEditingController,
            focusNode: focusNode,
            onFieldSubmitted: (value) => onFieldSubmitted(),
            decoration: InputDecoration(
              hintText: "Search By Book Name Here..",
              border: OutlineInputBorder(borderSide: BorderSide.none),
            ),
          );
        },
        optionsViewBuilder: (BuildContext context,
            AutocompleteOnSelected<String> onSelected,
            Iterable<String> options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4.0,
              child: SizedBox(
                height: 200.0,
                child: ListView.builder(
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final String option = options.elementAt(index);
                    return ListTile(
                      title: Text(
                        option == "Not Available" ? option : option,
                        style: TextStyle(
                          color: option == "Not Available"
                              ? Colors.red
                              : Colors.black,
                        ),
                      ),
                      onTap: () {
                        onSelected(option);
                      },
                    );
                  },
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

}
