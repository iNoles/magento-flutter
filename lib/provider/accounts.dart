import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountsProvider with ChangeNotifier {
  String? _token;
  String? get token => _token;
  bool get isCustomer => _token != null;

  AccountsProvider() {
    init();
  }

  void signIn(String token) async {
    final sharedPref = await SharedPreferences.getInstance();
    sharedPref.setString('customer', token);
    _token = token;
    notifyListeners();
  }

  void signOff() async {
    final sharedPref = await SharedPreferences.getInstance();
    sharedPref.remove('customer');
    _token = null;
    notifyListeners();
  }

  /// Load customer token's information from local storage
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      _token = prefs.getString('customer');
    } catch (e) {
      _token = null;
    }
  }
}
