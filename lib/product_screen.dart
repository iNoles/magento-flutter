import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:html/parser.dart' show parse;
import 'package:provider/provider.dart';

import 'cart_provider.dart';
import 'product_cart.dart';
import 'widget/form_builder.dart';
import 'widget/form_builder_dropdown.dart';
import 'widget/form_builder_field_option.dart';
import 'widget/form_builder_radio_group.dart';
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
                  ... on BundleProduct {
                    items {
                      title
                      option_id
                      type
                      options {
                        label
                        id
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
                        item['price_range']['minimum_price']['final_price'],
                      ),
                    ),
                  ),
                  loadSpecificTypesOption(item),
                  FormBuilderTextField(
                    attribute: 'quantity',
                    keyboardType: TextInputType.number,
                    initialValue: '1',
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                    ),
                    validators: [
                      FormBuilderValidators.required(),
                      FormBuilderValidators.min(1)
                    ],
                  ),
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
    } else if (types == 'ConfigurableProduct') {
      mutationString = configurableProducts;
    }

    if (mutationString.isEmpty) {
      return ElevatedButton(
        child: Text('Add to cart'),
        onPressed: null,
      );
    }
    return Mutation(
      options: MutationOptions(
        documentNode: gql(mutationString),
        onCompleted: (data) => print(data),
        onError: (error) => print(error),
      ),
      builder: (runMutation, result) {
        return ElevatedButton(
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
              } else if (types == 'ConfigurableProduct' &&
                  _formKey.currentState.saveAndValidate()) {
                runMutation({
                  'id': cartProvider.id,
                  'qty': _formKey.currentState.value['quantity'],
                  'parentSku': sku,
                  'variantSku': getVariantSku(item),
                });
              }
            });
      },
    );
  }

  String getVariantSku(dynamic data) {
    var variantSku = '';
    var formValues = _formKey.currentState.value.entries.toList();
    print(formValues);
    var variants = data['variants'] as List;
    for (var variant in variants) {
      var attributes = variant['attributes'] as List;
      var first = attributes
          .firstWhere((element) => element['code'] == formValues[1].key);
      var second = attributes
          .firstWhere((element) => element['code'] == formValues[2].key);
      if (formValues.length > 3 && formValues.elementAt(3) != null) {
        var third = attributes
            .firstWhere((element) => element['code'] == formValues[3].key);
        if (first['label'] == formValues[1].value &&
            second['label'] == formValues[2].value &&
            third['label'] == formValues[3].value) {
          variantSku = variant['product']['sku'];
          break;
        }
      } else if (first['label'] == formValues[1].value &&
          second['label'] == formValues[2].value) {
        variantSku = variant['product']['sku'];
        break;
      }
    }
    return variantSku;
  }

  Widget loadSpecificTypesOption(dynamic data) {
    final types = data['__typename'];
    if (types == 'ConfigurableProduct') {
      return getConfigurableOptions(data);
    } else if (types == 'BundleProduct') {
      return getBundleItem(data);
    }
    return Container();
  }

  Widget getBundleItem(dynamic data) {
    var bundleItems = data['items'];
    if (bundleItems == null) {
      return Container();
    }
    var widgetList = <Widget>[];
    for (var item in bundleItems) {
      widgetList.add(Text(item['title']));
      widgetList.add(
        FormBuilderRadioGroup(
          attribute: item['option_id'].toString(),
          validators: [FormBuilderValidators.required()],
          options: (item['options'] as List)
              .map((e) => FormBuilderFieldOption(
                    value: e['id'],
                    child: Text(e['label']),
                  ))
              .toList(),
        ),
      );
      widgetList.add(
        FormBuilderTextField(
          attribute: '${item['option_id']}_quantity',
          keyboardType: TextInputType.number,
          initialValue: '1',
          decoration: InputDecoration(
            labelText: 'Quantity',
          ),
          validators: [
            FormBuilderValidators.required(),
            FormBuilderValidators.min(1),
          ],
        ),
      );
    }
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: widgetList,
      ),
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
