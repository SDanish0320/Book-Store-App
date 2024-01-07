import 'package:flutter/material.dart';
import 'package:bookstore/Admin/Author/authorshow.dart';
import 'package:bookstore/Admin/Category/categoryshow.dart';
import 'package:bookstore/Admin/Orders/ordershow.dart';
import 'package:bookstore/Admin/Product/productshow.dart';
import 'package:bookstore/Common/Logout/logout.dart';
import 'package:bookstore/Admin/Users/usershow.dart';

class CommonScaffold extends StatelessWidget {
  final Widget? mybody;
  final dynamic myColor;
  final FloatingActionButton? floatingActionButton;

  CommonScaffold({
    required this.mybody,
    this.myColor = Colors.transparent,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: myColor,
      appBar: AppBar(
        foregroundColor: Color(0xFFffd482),
        backgroundColor: Color(0xFF24375E),
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(360),
            bottomRight: Radius.circular(360),
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          color: Color(0xFFffd482),
          child: Center(
            child: Column(
              children: <Widget>[
                YourHeaderWidget(),
                Center(
                  child: DrawerSection(
                    title: 'Main',
                    items: [
                      CompactDrawerItem(
                          icon: Icons.person,
                          label: 'Authors',
                          onTap: () => navigateTo(context, AuthorShow())),
                      CompactDrawerItem(
                          icon: Icons.category,
                          label: 'Categories',
                          onTap: () => navigateTo(context, CategoryShow())),
                      CompactDrawerItem(
                          icon: Icons.shopping_cart,
                          label: 'Products',
                          onTap: () => navigateTo(context, ProductShow())),
                    ],
                  ),
                ),
                Center(
                  child: DrawerSection(
                    title: 'Additional',
                    items: [
                      
                      CompactDrawerItem(
                          icon: Icons.account_circle,
                          label: 'Users',
                          onTap: () => navigateTo(context, UserShow())),
                      CompactDrawerItem(
                          icon: Icons.shopping_cart,
                          label: 'Order',
                          onTap: () => navigateTo(context, OrderShow())),
                    ],
                  ),
                ),
                Center(
                  child: DrawerSection(
                    title: 'Account',
                    items: [
                      CompactDrawerItem(
                          icon: Icons.logout,
                          label: 'Logout',
                          onTap: () => navigateTo(context, LogoutPage())),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: mybody,
      floatingActionButton: floatingActionButton,
    );
  }
}

class CompactDrawerItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  CompactDrawerItem(
      {required this.icon, required this.label, required this.onTap});

  @override
  State<CompactDrawerItem> createState() => _CompactDrawerItemState();
}

class _CompactDrawerItemState extends State<CompactDrawerItem> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        height: 50,
        color: Colors.transparent,
        child: Row(
          children: [
            Icon(
              widget.icon,
              color: Color(0xFF24375E),
            ),
            SizedBox(width: 5),
            Text(
              widget.label,
              style: TextStyle(color: Color(0xFF24375E), fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerSection extends StatelessWidget {
  final String title;
  final List<Widget> items;

  DrawerSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Divider(),
        Column(
          children: items,
        ),
      ],
    );
  }
}

// Helper functions/widgets
Widget YourHeaderWidget() {
  return Column(
    children: [
      Container(
        width: 120.0,
        height: 120.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: AssetImage('verseVoyage.png'),
            fit: BoxFit.cover,
          ),
        ),
      ),
      SizedBox(height: 5),
      Text(
        'Verse Vouyage',
        style: TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.w800,
          color: Color(0xFF24375E),
        ),
      ),
      Text(
        'E-Book Store',
        style: TextStyle(
          fontSize: 14.0,
          color: Color(0xFF24375E),
        ),
      ),
      SizedBox(
        height: 5,
      ),
    ],
  );
}

void navigateTo(BuildContext context, Widget page) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => page),
  );
}

class Ahutorr extends StatefulWidget {
  @override
  State<Ahutorr> createState() => _AhutorrState();
}

class _AhutorrState extends State<Ahutorr> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AuthorShow()),
          );
        },
        child: Container(
          height: 50,
          color: Colors.transparent,
          child: Row(
            children: [
              Container(
                child: Icon(
                  Icons.person,
                  color: Color(0xFF24375E),
                ),
              ),
              SizedBox(width: 5),
              Container(
                child: Text(
                  'Authors',
                  style: TextStyle(color: Color(0xFF24375E), fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Categoryy extends StatefulWidget {
  @override
  State<Categoryy> createState() => _CategoryyState();
}

class _CategoryyState extends State<Categoryy> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CategoryShow()),
          );
        },
        child: Container(
          height: 50,
          color: Colors.transparent,
          child: Row(
            children: [
              Icon(
                Icons.category,
                color: Color(0xFF24375E),
              ),
              SizedBox(width: 5),
              Text(
                'Categories',
                style: TextStyle(color: Color(0xFF24375E), fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Productss extends StatefulWidget {
  @override
  State<Productss> createState() => _ProductssState();
}

class _ProductssState extends State<Productss> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProductShow()),
          );
        },
        child: Container(
          height: 50,
          color: Colors.transparent,
          child: Row(
            children: [
              Icon(
                Icons.shopping_cart,
                color: Color(0xFF24375E),
              ),
              SizedBox(width: 5),
              Text(
                'Products',
                style: TextStyle(color: Color(0xFF24375E), fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class Userr extends StatefulWidget {
  @override
  State<Userr> createState() => _UserrState();
}

class _UserrState extends State<Userr> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => UserShow()),
          );
        },
        child: Container(
          height: 50,
          color: Colors.transparent,
          child: Row(
            children: [
              Icon(
                Icons.account_circle,
                color: Color(0xFF24375E),
              ),
              SizedBox(width: 5),
              Text(
                'Users',
                style: TextStyle(color: Color(0xFF24375E), fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Orderr extends StatefulWidget {
  @override
  State<Orderr> createState() => _OrderrState();
}

class _OrderrState extends State<Orderr> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OrderShow()),
          );
        },
        child: Container(
          height: 50,
          color: Colors.transparent,
          child: Row(
            children: [
              Icon(
                Icons.shopping_cart,
                color: Color(0xFF24375E),
              ),
              SizedBox(width: 5),
              Text(
                'Order',
                style: TextStyle(color: Color(0xFF24375E), fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Logout extends StatefulWidget {
  @override
  State<Logout> createState() => _LogoutState();
}

class _LogoutState extends State<Logout> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LogoutPage()),
          );
        },
        child: Container(
          height: 50,
          color: Colors.transparent,
          child: Row(
            children: [
              Icon(
                Icons.logout,
                color: Color(0xFF24375E),
              ),
              SizedBox(width: 5),
              Text(
                'Logout',
                style: TextStyle(color: Color(0xFF24375E), fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
