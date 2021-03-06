import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:magento_flutter/ui/screens/checkout_address.dart';
import 'package:provider/provider.dart';

import '../../providers/cart.dart';
import '../../utils.dart';

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
      options: QueryOptions(document: gql('''
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
            prices {
              row_total {
                value
                currency
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
      builder: (result, {fetchMore, refetch}) {
        if (result.hasException) {
          return Text(result.exception.toString());
        }

        if (result.isLoading) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        List items = result.data['cart']['items'];
        dynamic prices = result.data['cart']['prices'];
        return SingleChildScrollView(
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
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
                                    Text(
                                      'Price: ${currencyWithPrice(item['prices']['row_total'])}',
                                    ),
                                    Text('qty: ${item['quantity']}')
                                  ],
                                ),
                                Spacer(),
                                removeItems(context, item['id']),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TOTAL',
                          style: Theme.of(context).textTheme.subtitle2,
                        ),
                        Text(
                          currencyWithPrice(prices['grand_total']),
                          style: Theme.of(context).textTheme.headline5,
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                        ),
                        child: Text('CHECKOUT'),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CheckoutAddressScreen(),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget removeItems(BuildContext context, String id) => Mutation(
        options: MutationOptions(document: gql('''
        mutation RemoveItem(\$cartId: String!, \$itemId: Int!) {
          removeItemFromCart(
            input: {
              cart_id: \$cartId,
              cart_item_id: \$itemId
            }
          ) {
            cart {
              items {
                product {
                  name
                }
              }
            }
          }
        }
      ''')),
        builder: (runMutation, result) {
          final cartProvider = context.watch<CartProvider>();
          return IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              runMutation({
                'cartId': cartProvider.id,
                'itemId': id,
              });
            },
          );
        },
      );
}
