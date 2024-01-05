import 'package:bookstore/Admin/Author/authoradd.dart';
import 'package:bookstore/Admin/Author/authorupdate.dart';
import 'package:bookstore/Admin/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: AuthorShow()));
}

class AuthorShow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      mybody: MyListView(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AuthorAdd()),
          );
        },
        backgroundColor: Color(0xFF24375E),
        child: Icon(Icons.add, color: Color(0xFFffd482)),
      ),
    );
  }
}

class MyListView extends StatefulWidget {
  @override
  _MyListViewState createState() => _MyListViewState();
}

class _MyListViewState extends State<MyListView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _showDeleteConfirmationDialog(String authorId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData(
            backgroundColor: Color.fromARGB(255, 219, 181, 154),
          ),
          child: AlertDialog(
            title: Text('Confirm Delete'),
            content: Text('Are you sure you want to delete this author?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                style: TextButton.styleFrom(
                  primary: Color.fromARGB(255, 251, 120, 74),
                  backgroundColor: Color.fromARGB(255, 251, 120, 74),
                ),
                child: Text('Cancel', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              TextButton(
                onPressed: () {
                  _deleteAuthor(authorId);
                  Navigator.of(context).pop(); // Close the dialog
                },
                style: TextButton.styleFrom(
                  primary: Color.fromARGB(255, 251, 120, 74),
                  backgroundColor: Color.fromARGB(255, 251, 120, 74),
                ),
                child: Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteAuthor(String authorId) async {
    try {
      await FirebaseFirestore.instance.collection('author').doc(authorId).delete();
    } catch (e) {
      print('Error deleting author: $e');
      // Handle the error (show a dialog, snackbar, etc.)
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firestore.collection('author').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CupertinoActivityIndicator(),
          );
        }

        var author = snapshot.data!.docs;
        return ListView.builder(
          itemCount: author.length,
          itemBuilder: (context, index) {
            var authors = author[index];

            return Card(
              margin: EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              color: Color(0xFFffd482),
              child: ListTile(
                title: Text('Author: ${authors['Author Name']}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Details: ${authors['Details']}',style: TextStyle(color: Color(0xFF24375E)),),
                    Text('Origin: ${authors['Origin']}',style: TextStyle(color: Color(0xFF24375E)),),
                    Text('Language: ${authors['Language']}',style: TextStyle(color: Color(0xFF24375E))),
                  ],
                ),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(authors['Image']),
                  radius: 30,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AuthorUpdate(authorId: authors.id),
                          ),
                        );
                      },
                    ),
                    SizedBox(width: 10),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _showDeleteConfirmationDialog(authors.id);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
