import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'provider/cart.dart';
import 'screen/products/configurations.dart';

const mutationQuery = r'''
mutation AddProductsToCart($cartId: String!, $sku: String!, $parent_sku: String, $qty: Int!) {
  addProductsToCart(
    cartId: $cartId,
    cartItems: [{
      quantity: $qty
      parent_sku: $parent_sku
      sku: $sku
    }]) {
    cart {
      items {
        product {
          name
          sku
        }
        quantity
      }
    }
    user_errors {
      code
      message
    }
  }
}
''';

Widget orderMutation(
  CartProvider cartProvider,
  String sku,
  TextEditingController qty,
  GlobalKey<FormState> key,
  dynamic data,
  Map<String, String> optionsMap,
) {
  return Mutation(
    options: MutationOptions(
      document: gql(mutationQuery),
      onCompleted: (data) {
        if (kDebugMode) {
          print(data);
        }
      },
      onError: (error) {
        if (kDebugMode) {
          print(error);
        }
      },
    ),
    builder: (runMutation, result) {
      key.currentState?.save();
      return ElevatedButton(
        child: const Text('Add to cart'),
        onPressed: () {
          if (key.currentState?.validate() != null) {
            runMutation({
              'cartId': cartProvider.id,
              'sku': sku,
              'parent_sku': getVariantSku(data: data, options: optionsMap),
              'qty': int.tryParse(qty.text) ?? 1,
            });
          }
        },
      );
    },
  );
}
