import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

import 'providers/cart.dart';

const Map<String, String> _currencies = {
  'USD': '\$',
  'EUR': '€',
  'AUD': 'A\$',
  'GBP': '£',
  'CAD': 'CA\$',
  'CNY': 'CN¥',
  'JPY': '¥',
  'SEK': 'SEK',
  'CHF': 'CHF',
  'INR': '₹',
  'KWD': 'د.ك',
  'RON': 'RON',
};

String currencyWithPrice(dynamic price) {
  final currency = _currencies[price['currency']];
  return '${currency}${price['value'].toString()}';
}

/// Desktop Platform = 4 and Mobile Platform = 2
int certainPlatformGridCount() {
  var gridViewCount = 4;
  if (Platform.isIOS || Platform.isAndroid || Platform.isFuchsia) {
    gridViewCount = 2;
  }
  return gridViewCount;
}

Future<void> getCart(BuildContext context) async {
  final client = GraphQLProvider.of(context)?.value;
  var result = await client.mutate(
    MutationOptions(documentNode: gql('''
    mutation {
      createEmptyCart
    }
    ''')),
  );

  if (result.hasException) {
    print(result.exception.toString());
    return;
  }

  final cardId = result.data['createEmptyCart'];
  print(cardId);
  await context.read<CartProvider>().setId(cardId);
}

Color productCell(BuildContext context) {
  final brightness = Theme.of(context).brightness;
  return (brightness == Brightness.dark) ? Colors.grey : Colors.white;
}
