import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../utils.dart';
import '../screen/categories.dart';
import '../screen/product.dart';

class HomeTabs extends StatelessWidget {
  const HomeTabs({super.key});

  static const query = """
  {
    categoryList(filters: { ids: {in: ["21", "12"]}}) {
      name
      products {
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
  }
  """;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Magento Shop'),
      ),
      body: _featuredCategory(context),
    );
  }

  Widget _productsList(BuildContext context) {
    return Query(
      options: QueryOptions(
        document: gql(query),
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

        dynamic categoryList = result.data?['categoryList'];
        return Column(children: [
          _listColumn(
            categoryList[0],
          ),
          _listColumn(
            categoryList[1],
          )
        ]);
      },
    );
  }

  Widget _listColumn(dynamic categoryList) {
    List items = categoryList['products']['items'];
    String title = categoryList['name'] ?? 'Empty';
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(10),
          child: Text(
            title,
            style: const TextStyle(fontSize: 20),
          ),
        ),
        SizedBox(
          height: 185,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                height: 115,
                margin: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
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
                    children: [
                      CachedNetworkImage(
                        imageUrl: item['image']['url'],
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        height: 130,
                        width: 115,
                        fit: BoxFit.fitHeight,
                      ),
                      Text(item['name']),
                      Text(
                        currencyWithPrice(
                          item['price_range']['minimum_price']['final_price'],
                        ),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _featuredCategory(BuildContext context) {
    final children = <Widget>[];
    children.add(_productsList(context));
    children.add(
      ElevatedButton(
        child: const Text('All Categories'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const CategoriesScreen(),
          ),
        ),
      ),
    );
    return SingleChildScrollView(
      child: Column(
        children: children,
      ),
    );
  }
}
