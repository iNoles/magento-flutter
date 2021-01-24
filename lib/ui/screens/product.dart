import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:html/parser.dart' show parse;
import 'package:provider/provider.dart';

import '../../providers/cart.dart';
import '../../product_utils.dart';
import '../widget/form_builder.dart';
import '../widget/form_builder_dropdown.dart';
import '../widget/form_builder_field_option.dart';
import '../widget/form_builder_radio_group.dart';
import '../widget/form_builder_text_field.dart';
import '../widget/form_builder_validator.dart';
import '../../utils.dart';

class ProductScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormBuilderState>();

  final String title;
  final String sku;

  ProductScreen({
    Key key,
    @required this.title,
    @required this.sku,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Query(
        options: QueryOptions(
          document: gql(
            '''
            {
              products(filter: { sku: { eq: "$sku" }}) {
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

          if (result.isLoading) {
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
                  CachedNetworkImage(
                    imageUrl: item['image']['url'],
                    placeholder: (context, url) =>
                        Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    height: 300,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        left: 15, right: 15, top: 20, bottom: 20),
                    color: productCell(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text('SKU'), Text(item['sku'])],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        left: 15, right: 15, top: 20, bottom: 20),
                    color: productCell(context),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Price'),
                        Text(
                          currencyWithPrice(
                            item['price_range']['minimum_price']['final_price'],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  loadSpecificTypesOption(context, item),
                  FormBuilderTextField(
                    name: 'quantity',
                    keyboardType: TextInputType.number,
                    initialValue: '1',
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                    ),
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(context),
                      FormBuilderValidators.min(context, 1),
                    ]),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(
                        left: 15, right: 15, top: 20, bottom: 20),
                    color: productCell(context),
                    child: Column(
                      children: [
                        Text('Product Details'),
                        SizedBox(
                          height: 15,
                        ),
                        Text(parse(item['description']['html'])
                            .documentElement
                            .text),
                      ],
                    ),
                  ),
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
      mutationString = Product.simple;
    } else if (types == 'VirtualProduct') {
      mutationString = Product.virtual;
    } else if (types == 'ConfigurableProduct') {
      mutationString = Product.configurable;
    }

    if (mutationString.isEmpty) {
      return ElevatedButton(
        child: Text('Add to cart'),
        onPressed: null,
      );
    }
    return Mutation(
      options: MutationOptions(
        document: gql(mutationString),
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
      var zero = attributes
          .firstWhere((element) => element['code'] == formValues[0].key);
      var first = attributes
          .firstWhere((element) => element['code'] == formValues[1].key);
      if (formValues.length > 3) {
        var second = attributes
            .firstWhere((element) => element['code'] == formValues[3].key);
        if (zero['label'] == formValues[0].value &&
            first['label'] == formValues[1].value &&
            second['label'] == formValues[2].value) {
          variantSku = variant['product']['sku'];
          break;
        }
      } else if (zero['label'] == formValues[0].value &&
          first['label'] == formValues[1].value) {
        variantSku = variant['product']['sku'];
        break;
      }
    }
    return variantSku;
  }

  Widget loadSpecificTypesOption(BuildContext context, dynamic data) {
    final types = data['__typename'];
    if (types == 'ConfigurableProduct') {
      return getConfigurableOptions(context, data);
    } else if (types == 'BundleProduct') {
      return getBundleItem(context, data);
    }
    return Container();
  }

  Widget getBundleItem(BuildContext context, dynamic data) {
    var bundleItems = data['items'];
    if (bundleItems == null) {
      return Container();
    }
    var widgetList = <Widget>[];
    for (var item in bundleItems) {
      var type = item['type'];
      widgetList.add(Text(item['title']));
      if (type == 'radio') {
        widgetList.add(
          FormBuilderRadioGroup(
            name: item['option_id'].toString(),
            validator: FormBuilderValidators.required(context),
            options: (item['options'] as List)
                .map((e) => FormBuilderFieldOption(
                      value: e['id'],
                      child: Text(e['label']),
                    ))
                .toList(),
          ),
        );
      } else {
        widgetList.add(
          FormBuilderDropdown(
            name: item['option_id'].toString(),
            validator: FormBuilderValidators.required(context),
            items: (item['options'] as List)
                .map((e) => DropdownMenuItem(
                      value: e['id'],
                      child: Text(e['label']),
                    ))
                .toList(),
            hint: Text('Select'),
          ),
        );
      }
      widgetList.add(
        FormBuilderTextField(
          name: '${item['option_id']}_quantity',
          keyboardType: TextInputType.number,
          initialValue: '1',
          decoration: InputDecoration(
            labelText: 'Quantity',
          ),
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.required(context),
            FormBuilderValidators.min(context, 1),
          ]),
        ),
      );
      widgetList.add(SizedBox(height: 25.0));
    }
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: widgetList,
      ),
    );
  }

  Widget getConfigurableOptions(BuildContext context, dynamic data) {
    var configurableOptions = data['configurable_options'];
    if (configurableOptions == null) {
      return Container();
    }
    var widgetList = <Widget>[];
    for (var option in configurableOptions) {
      widgetList.add(
        FormBuilderDropdown(
          name: option['label'].toLowerCase(),
          decoration: InputDecoration(labelText: option['label']),
          items: option['values']
              .map<DropdownMenuItem>((e) => DropdownMenuItem(
                    value: e['label'],
                    child: Text(e['label']),
                  ))
              .toList(),
          hint: Text('Select'),
          validator: FormBuilderValidators.required(context),
        ),
      );
    }

    return Column(
      children: widgetList,
    );
  }
}
