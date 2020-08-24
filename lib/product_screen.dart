import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'widget/form_builder.dart';
import 'widget/form_builder_dropdown.dart';
import 'utils.dart';

class ProductScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormBuilderState>();

  final String title;
  final String sku;

  ProductScreen({Key key, this.title, this.sku}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  price_range {
                    minimum_price {
                      regular_price {
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
                      id
                      label
                      values {
                        value_index
                        label
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
          final regularPrice =
              item['price_range']['minimum_price']['regular_price'];
          return SingleChildScrollView(
            child: FormBuilder(
              key: _formKey,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text('Image go here'),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: Text(
                      currencyWithPrice(
                        regularPrice['currency'],
                        regularPrice['value'],
                      ),
                    ),
                  ),
                  getConfigurableOptions(item),
                  Text('Product Details'),
                  Text(item['description']['html']),
                  SizedBox(
                    width: double.infinity, // match_parent
                    child: RaisedButton(
                      onPressed: onPressedSubmit,
                      child: Text('Add to cart'),
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

  void onPressedSubmit() {
    _formKey.currentState.save();
    print(_formKey.currentState.value);
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
                      value: e['value_index'],
                      child: Text(e['label']),
                    ))
                .toList(),
            hint: Text('Select')),
      );
    }

    return Column(
      children: widgetList,
    );
  }
}
