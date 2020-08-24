import 'package:flutter/material.dart';

class CartTabs extends StatelessWidget {
  CartTabs({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: cardBody(),
    );
  }

  Widget cardBody() {
    return Center(
      child: Text('Shopping Cart'),
    );
  }

  /*Widget cardBody() {
    return Column(
      children: [
        Card(
          child: Column(
            children: [
              Row(
                children: [
                  Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                    ],
                  ),
                  Spacer(),
                  Icon(Icons.delete)
                ],
              ),
            ],
          ),
        ),
        Text('Total: $0.00'),
        SizedBox(
          width: double.infinity, // match_parent
          child: RaisedButton(
            onPressed: () {},
            child: Text('Place the order'),
          ),
        ),
      ],
    );
  }*/
}
