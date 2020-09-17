import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'accounts_tabs.dart';
import 'cart_provider.dart';
import 'cart_tabs.dart';
import 'home_tabs.dart';
import 'search_tabs.dart';
import 'widget/custom_scaffold.dart';
import 'utils.dart';

class StartScreen extends StatefulWidget {
  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    if (cart.id.isEmpty) {
      getCart(context);
    }
    return CustomScaffold(
      scaffold: Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Customer',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart),
              label: 'Cart',
            )
          ],
        ),
      ),
      children: [
        HomeTabs(),
        SearchTabs(),
        AccountsTabs(),
        CartTabs(),
      ],
    );
  }
}
