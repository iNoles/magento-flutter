import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:html/parser.dart';
import 'package:provider/provider.dart';

import '../mutation.dart';
import '../provider/cart.dart';
import '../utils.dart';
import 'products/configurations.dart';

class ProductScreen extends StatefulWidget {
  final String title;
  final String sku;

  const ProductScreen({
    super.key,
    required this.title,
    required this.sku,
  });

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  final qtyController = TextEditingController(text: '1');
  final optionsMap = <String, String>{};
  final _formKey = GlobalKey<FormState>();

  static const query = r'''
   query GetProductsBySKU($sku: String) {
    products(filter: { sku: { eq: $sku }}) {
      items {
        image {
          url
        }
        sku
        __typename
        price_range {
          minimum_price {
            final_price {
              currency
              value
            }
          }
        }
        description {
          html
        }
        ... on ConfigurableProduct {
          configurable_options {
            label
            values {
              label
            }
          }
          variants {
            product {
              sku
            }
            attributes {
              label
              code
            }
          }
        }
      }
    }
   }
   ''';

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    qtyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Query(
        options: QueryOptions(
          document: gql(query),
          variables: {
            'sku': widget.sku,
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

          dynamic item = result.data?['products']['items'][0];
          return SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  CachedNetworkImage(
                    imageUrl: item['image']['url'],
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                    height: 300,
                  ),
                  Text(widget.title),
                  Text(
                    currencyWithPrice(
                      item['price_range']['minimum_price']['final_price'],
                    ),
                  ),
                  _options(
                    item: item,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextFormField(
                      obscureText: false,
                      controller: qtyController,
                      decoration: InputDecoration(
                        hintText: '1',
                        labelText: 'Quantity',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Please enter your quantity';
                        }
                        return null;
                      },
                    ),
                  ),
                  Text(
                    parse(item['description']['html']).documentElement?.text ??
                        "",
                  ),
                  SizedBox(
                    width: double.infinity, // match_parent
                    child: orderMutation(
                      cartProvider,
                      widget.sku,
                      qtyController,
                      _formKey,
                      item,
                      optionsMap,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _options({required dynamic item}) {
    if (item['__typename'] == "ConfigurableProduct") {
      return configurationOptions(item: item, options: optionsMap);
    }
    return Container();
  }
}
