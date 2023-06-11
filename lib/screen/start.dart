import 'package:flutter/material.dart';
import 'package:magento_flutter/tabs/search.dart';
import 'package:provider/provider.dart';

import '../provider/cart.dart';
import '../tabs/accounts.dart';
import '../tabs/cart.dart';
import '../tabs/home.dart';
import '../utils.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StatefulWidget> createState() => _StateScreenState();
}

class _StateScreenState extends State<StartScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomeTabs(),
    SearchTabs(),
    AccountsTabs(),
    CartTabs(),
  ];

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    if (cart.id.isEmpty) {
      getCart(context).then((value) {
        if (value.isNotEmpty) {
          context.read<CartProvider>().setId(value);
        }
      });
    }
    return Scaffold(
      body: _pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Account",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Cart",
          )
        ],
        currentIndex: _selectedIndex,
        onTap: (value) {
          setState(() {
            _selectedIndex = value;
          });
        },
      ),
    );
  }
}
