import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:html/parser.dart' show parse;
import 'package:provider/provider.dart';

import 'cart_provider.dart';
import 'product_cart.dart';
import 'widget/form_builder.dart';
import 'widget/form_builder_dropdown.dart';
import 'widget/form_builder_text_field.dart';
import 'widget/form_builder_validator.dart';
import 'utils.dart';

class ProductScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormBuilderState>();

  final String title;
  final String sku;

  ProductScreen({Key key, this.title, this.sku}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Query(
        options: QueryOptions(
          documentNode: gql(
            '''
            {
              products(filter: { sku: { eq: "$sku" }}) {
                items {
                  image {
                    url
                  }
                  __typename
                  price {
                    regularPrice {
                      amount {
                        value
                        currency
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
            ''',
          ),
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

          dynamic item = result.data['products']['items'][0];
          return SingleChildScrollView(
            child: FormBuilder(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: CachedNetworkImage(
                      imageUrl: item['image']['url'],
                      placeholder: (context, url) =>
                          Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      height: 300,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text(
                      currencyWithPrice(
                          item['price']['regularPrice']['amount']),
                    ),
                  ),
                  FormBuilderTextField(
                    attribute: 'quantity',
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Quantity',
                    ),
                    validators: [
                      FormBuilderValidators.required(),
                      FormBuilderValidators.min(1)
                    ],
                  ),
                  getConfigurableOptions(item),
                  Text('Product Details'),
                  Text(parse(item['description']['html']).documentElement.text),
                  SizedBox(
                    width: double.infinity, // match_parent
                    child: orderMutation(item, cartProvider),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget orderMutation(dynamic item, CartProvider cartProvider) {
    var mutationString = '';
    final types = item['__typename'];
    if (types == 'SimpleProduct') {
      mutationString = simpleProducts;
    } else if (types == 'VirtualProduct') {
      mutationString = virtualProducts;
    }

    if (mutationString.isEmpty) {
      return RaisedButton(
        child: Text('Add to cart'),
        onPressed: null,
      );
    }
    return Mutation(
      options: MutationOptions(
        documentNode: gql(mutationString),
        onError: (error) => print(error),
      ),
      builder: (runMutation, result) {
        return RaisedButton(
            child: Text('Add to cart'),
            onPressed: () {
              if (types == 'SimpleProduct' || types == 'VirtualProduct') {
                if (_formKey.currentState.saveAndValidate()) {
                  runMutation({
                    'id': cartProvider.id,
                    'qty': _formKey.currentState.value['quantity'],
                    'sku': sku
                  });
                }
              }
            });
      },
    );
  }

  Widget getConfigurableOptions(dynamic data) {
    var configurableOptions = data['configurable_options'];
    if (configurableOptions == null) {
      return Container();
    }
    var widgetList = <Widget>[];
    for (var option in configurableOptions) {
      widgetList.add(
        FormBuilderDropdown(
          attribute: option['label'].toLowerCase(),
          decoration: InputDecoration(labelText: option['label']),
          items: option['values']
              .map<DropdownMenuItem>((e) => DropdownMenuItem(
                    value: e['label'],
                    child: Text(e['label']),
                  ))
              .toList(),
          hint: Text('Select'),
          validators: [FormBuilderValidators.required()],
        ),
      );
    }

    return Column(
      children: widgetList,
    );
  }
}
