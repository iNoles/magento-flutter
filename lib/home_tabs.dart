import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'categories_screen.dart';
import 'product_screen.dart';
import 'utils.dart';

class HomeTabs extends StatelessWidget {
  HomeTabs({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Magento Shop'),
      ),
      body: featuredCategory(context),
    );
  }

  Widget productsList(BuildContext context, int categoryId) {
    return Query(
      options: QueryOptions(
        documentNode: gql('''
        {
          category(id: $categoryId) {
            products {
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

        List items = result.data['category']['products']['items'];
        return Container(
          height: 185,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                height: 115,
                margin: EdgeInsets.all(5),
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
                            Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        height: 130,
                        width: 115,
                        fit: BoxFit.fitHeight,
                      ),
                      Text(item['name']),
                      Text(
                        currencyWithPrice(
                            item['price']['regularPrice']['amount']),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget featuredCategory(BuildContext context) {
    var category = <Map<String, dynamic>>[
      {'title': 'Women Sale', 'category': 20},
      {'title': 'Men Sale', 'category': 11}
    ];
    final children = <Widget>[];
    category.forEach((element) {
      children.add(
        Column(
          children: [
            Container(
              margin: EdgeInsets.all(10),
              child: Text(
                element['title'],
                style: TextStyle(fontSize: 20),
              ),
            ),
            productsList(context, element['category'])
          ],
        ),
      );
    });
    children.add(
      RaisedButton(
        child: Text('All Categories'),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoriesScreen(),
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
