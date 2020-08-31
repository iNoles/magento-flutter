import 'dart:io' show Platform;

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

          var gridViewCount = 4;
          if (Platform.isIOS || Platform.isAndroid || Platform.isFuchsia) {
            gridViewCount = 2;
          }
          return GridView.count(
            crossAxisCount: gridViewCount,
            children: List.generate(
              items.length,
              (index) => categoryBox(
                context,
                items[index],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget categoryBox(BuildContext context, dynamic item) => Container(
        decoration: BoxDecoration(border: Border.all()),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductScreen(
                title: item['name'],
                sku: item['sku'],
              ),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CachedNetworkImage(
                imageUrl: item['image']['url'],
                width: 120,
                height: 120,
              ),
              Text(item['name']),
              Text(currencyWithPrice(item['price'])),
            ],
          ),
        ),
      );
}
