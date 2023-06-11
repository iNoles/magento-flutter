import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../screen/product.dart';
import '../utils.dart';

class SearchTabs extends StatefulWidget {
  const SearchTabs({super.key});

  @override
  State<SearchTabs> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTabs> {
  Widget _title = const Text('Product Search');
  Icon _actionButton = const Icon(Icons.search);
  Widget _body = Container();

  final TextEditingController _controller = TextEditingController();

  static const search = r'''
    query GetProductSearch($product: String)
    {
      products(search: $product) {
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
    }''';

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
        centerTitle: true,
        title: _title,
        actions: [
          IconButton(
            icon: _actionButton,
            onPressed: () {
              setState(() {
                if (_actionButton.icon == Icons.search) {
                  _actionButton = const Icon(Icons.close);
                  _title = TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    style: Theme.of(context).textTheme.titleLarge,
                    decoration: const InputDecoration(
                      hintText: 'Search',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) {
                      setState(() {
                        _body = _queryBody(_controller.text);
                      });
                    },
                  );
                } else {
                  _title = const Text('Product Search');
                  _actionButton = const Icon(Icons.search);
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

  Widget _queryBody(String product) {
    return Query(
      options: QueryOptions(
        document: gql(search),
        variables: {
          'product': product,
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
                imageUrl: item['thumbnail']['url'],
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
