import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

import 'cart_provider.dart';
import 'utils.dart';

class CartTabs extends StatelessWidget {
  CartTabs({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: cardBody(context),
    );
  }

  Widget cardBody(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    return Query(
      options: QueryOptions(documentNode: gql('''
      {
        cart(cart_id: "${cartProvider.id}") {
          items {
            id
            product {
              name
              thumbnail {
                url
              }
            }
            quantity
          }
          prices {
            grand_total {
              value
              currency
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
        dynamic prices = result.data['cart']['prices'];
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
                          CachedNetworkImage(
                            imageUrl: item['product']['thumbnail']['url'],
                            width: 120,
                            height: 120,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['product']['name']),
                              /*Text(
                                'Price: ${currencyWithPrice(item['prices']['row_total'])}',
                              ),*/
                              Text('qty: ${item['quantity']}')
                            ],
                          ),
                          Spacer(),
                          Icon(Icons.delete)
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  'Total: ${currencyWithPrice(prices['grand_total'])}',
                ),
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
  }
}
