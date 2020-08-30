import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'product_screen.dart';
import 'utils.dart';

class CategoryScreen extends StatelessWidget {
  final String title;
  final int categoryId;

  CategoryScreen({Key key, this.title, this.categoryId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Query(
        options: QueryOptions(
          documentNode: gql('''
          {
            products(filter: {
              category_id: {
                eq: "$categoryId"
              }
            } ) {
              items {
                name
                sku
                image {
                  url
                }
                price {
                  regularPrice {
                    amount {
                      value
                      currency
                    }
                  }
                }
              }
            }
          }
          '''),
        ),
        builder: (QueryResult result, {Refetch refetch, FetchMore fetchMore}) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List items = result.data['products']['items'];
          if (items.isEmpty) {
            return Center(
              child: Text('Items are not found. Please try again later'),
            );
          }
          // Maybe Gridview?
          return ListView.separated(
            separatorBuilder: (context, index) => Divider(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: CachedNetworkImage(
                  imageUrl: item['image']['url'],
                  width: 120,
                  height: 120,
                ),
                title: Text(item['name']),
                subtitle: Text(
                  currencyWithPrice(item['price']),
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductScreen(
                      title: item['name'],
                      sku: item['sku'],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
