import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  String _id = '';
  String get id => _id;

  void setId(String id) {
    _id = id;
    notifyListeners();
  }
}
