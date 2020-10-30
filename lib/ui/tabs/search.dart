import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../screens/product.dart';
import '../../utils.dart';

class SearchTabs extends StatefulWidget {
  SearchTabs({Key key}) : super(key: key);

  @override
  _SearchTabState createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTabs> {
  Widget _title = Text('Product Search');
  Icon _actionButton = Icon(Icons.search);
  Widget _body = Container();

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.removeListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title,
        actions: [
          IconButton(
            icon: _actionButton,
            onPressed: () {
              setState(() {
                if (_actionButton.icon == Icons.search) {
                  _actionButton = Icon(Icons.close);
                  _title = TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    style: Theme.of(context).textTheme.headline6,
                    decoration: InputDecoration(
                      hintText: 'Search',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) {
                      setState(() {
                        _body = queryBody(_controller.text);
                      });
                    },
                  );
                } else {
                  _title = Text('Product Search');
                  _actionButton = Icon(Icons.search);
                  _controller.clear();
                }
              });
            },
          ),
        ],
      ),
      body: _body,
    );
  }

  Widget queryBody(String query) => Query(
        options: QueryOptions(
          document: gql('''
        {
          products(search: "$query") {
            items {
              name
              sku
              thumbnail {
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
          return ListView.separated(
            separatorBuilder: (context, index) => Divider(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: CachedNetworkImage(
                  imageUrl: item['thumbnail']['url'],
                  width: 120,
                  height: 120,
                ),
                title: Text(item['name']),
                subtitle: Text(
                  currencyWithPrice(
                    item['price_range']['minimum_price']['final_price'],
                  ),
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
