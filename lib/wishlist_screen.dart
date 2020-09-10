import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:magento_flutter/product_screen.dart';
import 'package:magento_flutter/utils.dart';

class WishlistScreen extends StatelessWidget {
  final String query = '''
  {
    customer {
      wishlist {
        items {
          product {
            sku
            name
            price_range {
              maximum_price {
                regular_price {
                  value
                  currency
                }
              }
            }
          }
        }
      }
    }
  }
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlists'),
      ),
      body: Query(
        options: QueryOptions(documentNode: gql(query)),
        builder: (QueryResult result, {Refetch refetch, FetchMore fetchMore}) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List items = result.data['customer']['wishlist']['items'];
          return ListView.separated(
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                  title: Text(item['product']['name']),
                  subtitle: Text(
                    currencyWithPrice(
                        item['price_range']['maximum_price']['regular_price']),
                  ),
                  onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductScreen(
                            title: item['product']['name'],
                            sku: item['product']['sku'],
                          ),
                        ),
                      ));
            },
            separatorBuilder: (context, index) => Divider(),
            itemCount: items.length,
          );
        },
      ),
    );
  }
}
