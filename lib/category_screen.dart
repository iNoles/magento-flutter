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
            categoryList(
              filters: {
                ids: {eq: "$categoryId"}
              }
            ) {
              products {
                items {
                  name
                  sku
                  image {
                    url
                  }
                  price_range {
                    minimum_price {
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

          List items = result.data['categoryList'][0]['products']['items'];
          if (items.isEmpty) {
            return Center(
              child: Text('Item is not found. Try again later'),
            );
          }
          return ListView.separated(
            separatorBuilder: (context, index) => Divider(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final regularPrice =
                  item['price_range']['minimum_price']['regular_price'];
              return ListTile(
                title: Text(item['name']),
                subtitle: Text(
                  currencyWithPrice(
                    regularPrice['currency'],
                    regularPrice['value'],
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductScreen(
                        title: item['name'],
                        sku: item['sku'],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
