import 'package:bookstore/Admin/drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(debugShowCheckedModeBanner: false, home: UserShow()));
}


class UserShow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CommonScaffold(
      mybody: MyListView(),
    );
  }
}

class MyListView extends StatefulWidget {

  @override
  State<MyListView> createState() => _UserShowState();
}

class _UserShowState extends State<MyListView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firestore.collection('users').where('role', isEqualTo: 'user').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CupertinoActivityIndicator(),
          );
        }

        var user = snapshot.data!.docs;
        return ListView.builder(
          itemCount: user.length,
          itemBuilder: (context, index) {
            var users = user[index];

            return Card(
              margin: EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              color: Color(0xFFffd482),
              child: ListTile(
                title: Text('Username: ${users['username']}',style: TextStyle(color: Color(0xFF24375E))),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Role: ${users['role']}',style: TextStyle(color: Color(0xFF24375E))),
                    Text('Email: ${users['email']}',style: TextStyle(color: Color(0xFF24375E))),
                    Text('Contact No: ${users['contactNumber']}',style: TextStyle(color: Color(0xFF24375E))),
                  ],
                ),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(users['file_path']),
                  radius: 30,
                ),
              ),
            );
          },
        );
      },
    );
  }
}


