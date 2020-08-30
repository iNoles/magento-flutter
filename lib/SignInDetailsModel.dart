import 'package:flutter/material.dart';

class SignInDetailsModel with ChangeNotifier {
  String _token = '';
  bool _isCustomer = false;
  String get token => _token;
  bool get isCustomer => _isCustomer;

  void signIn(String token) {
    _token = token;
    _isCustomer = true;
    notifyListeners();
  }

  void signOff() {
    _token = '';
    _isCustomer = false;
    notifyListeners();
  }
}
