import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'product_screen.dart';
import 'utils.dart';

class SearchTabs extends StatelessWidget {
  SearchTabs({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
        leading: IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            showSearch(
              context: context,
              delegate: ProductSearch(),
            );
          },
        ),
      ),
    );
  }
}

class ProductSearch extends SearchDelegate {
  @override
  ThemeData appBarTheme(BuildContext context) {
    assert(context != null);
    final theme = Theme.of(context);
    assert(theme != null);
    return theme;
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Query(
      options: QueryOptions(
        documentNode: gql('''
        {
          products(search: "$query") {
            items {
              name
              sku
              thumbnail {
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
        return ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
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
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Container();
  }
}
