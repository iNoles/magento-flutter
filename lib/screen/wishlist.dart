import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'product.dart';
import '../../utils.dart';

class WishlistScreen extends StatelessWidget {
  static const String query = '''
  {
    customer {
      wishlist {
        items {
          product {
            sku
            name
            price_range {
              minimum_price {
                final_price {
                  currency
                  value
                }
              }
            }
          }
        }
      }
    }
  }
  ''';

  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Wishlists'),
      ),
      body: Query(
        options: QueryOptions(document: gql(query)),
        builder: (result, {fetchMore, refetch}) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List items = result.data?['customer']['wishlist']['items'];
          return ListView.separated(
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item['product']['name']),
                subtitle: Text(
                  currencyWithPrice(
                      item['price_range']['minimum_price']['final_price']),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductScreen(
                      title: item['product']['name'],
                      sku: item['product']['sku'],
                    ),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => const Divider(),
            itemCount: items.length,
          );
        },
      ),
    );
  }
}
