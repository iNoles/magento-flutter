import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../utils.dart';
import 'product.dart';

class CategoryScreen extends StatelessWidget {
  final String title;
  final String categoryId;

  const CategoryScreen({
    super.key,
    required this.title,
    required this.categoryId,
  });

  static const query = """
   query GetProductsByCategory(\$categoryId) {
    products(filter: {
      category_uid: {
        eq: "\$categoryId"
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
  """;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(title),
      ),
      body: Query(
        options: QueryOptions(
          document: gql(query),
          variables: {
            'categoryId': categoryId.toString(),
          },
        ),
        builder: (result, {fetchMore, refetch}) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List items = result.data?['products']['items'];
          if (items.isEmpty) {
            return const Center(
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
