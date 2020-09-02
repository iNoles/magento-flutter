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

  /*Widget cardBody(BuildContext context) {
    return Query(
      options: QueryOptions(documentNode: gql('''
      {
        cart(cart_id: "") {
          items {
            product {
              name
              thumbnail {
                url
              }
            }
          }
        }
      }
      ''')),
      builder: (QueryResult result, {Refetch refetch, FetchMore fetchMore}) {
        if (result.hasException) {
          return Text(result.exception.toString());
        }

        if (result.loading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        List items = result.data['cart']['items'];
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
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
                              Text(item['product']['name']),
                            ],
                          ),
                          Spacer(),
                          Icon(Icons.delete)
                        ],
                      ),
                    ],
                  ),
                ),
                Text('Total: \$0.00'),
                SizedBox(
                  width: double.infinity, // match_parent
                  child: RaisedButton(
                    onPressed: () {},
                    child: Text('Place the order'),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }*/
}
