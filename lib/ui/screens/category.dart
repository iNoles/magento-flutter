import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'product.dart';
import '../../utils.dart';

class CategoryScreen extends StatelessWidget {
  final String title;
  final int categoryId;

  CategoryScreen({
    Key key,
    @required this.title,
    @required this.categoryId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Query(
        options: QueryOptions(
          document: gql('''
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
          '''),
        ),
        builder: (result, {fetchMore, refetch}) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.isLoading) {
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

          return GridView.count(
            crossAxisCount: certainPlatformGridCount(),
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
              Text(
                currencyWithPrice(
                    item['price_range']['minimum_price']['final_price']),
              ),
            ],
          ),
        ),
      );
}
