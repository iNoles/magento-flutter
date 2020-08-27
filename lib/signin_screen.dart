import 'package:flutter/material.dart';

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Map<String, String> _formValues = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Container(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.all(36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Company Logo'),
                SizedBox(
                  height: 45.0,
                ),
                TextFormField(
                  obscureText: false,
                  decoration: InputDecoration(
                    hintText: 'Username',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                  ),
                  validator: (String value) {
                    if (value.isEmpty) {
                      return 'Please enter username';
                    }
                    return null;
                  },
                  onSaved: (String value) {
                    _formValues['username'] = value;
                  },
                ),
                SizedBox(height: 25.0),
                TextFormField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    labelText: 'Enter your password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32.0),
                    ),
                  ),
                  validator: (newValue) {
                    if (newValue.isEmpty) {
                      return 'Please enter password';
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    _formValues['password'] = newValue;
                  },
                ),
                SizedBox(
                  height: 35.0,
                ),
                RaisedButton(
                  child: Text('Login'),
                  onPressed: null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void submit() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save(); // Save our form now.

      print('Printing the login data.');
      print(_formValues.values);
    }
  }
}
