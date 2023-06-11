import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

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
  return '$currency${price['value'].toString()}';
}

/// Desktop Platform = 4 and Mobile Platform = 2
int certainPlatformGridCount() {
  var gridViewCount = 4;
  if (Platform.isIOS || Platform.isAndroid || Platform.isFuchsia) {
    gridViewCount = 2;
  }
  return gridViewCount;
}

Future<String> getCart(BuildContext context) async {
  final client = GraphQLProvider.of(context).value;
  var result = await client.mutate(
    MutationOptions(document: gql('''
    mutation {
      createEmptyCart
    }
    ''')),
  );

  if (result.hasException) {
    if (kDebugMode) {
      print(result.exception.toString());
    }
    return "";
  }

  return result.data?['createEmptyCart'];
}
