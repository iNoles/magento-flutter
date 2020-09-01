import 'dart:io' show Platform;

final Map<String, String> _currency = {
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
  final regularPrice = price['regularPrice']['amount'];
  final currency = _currency[regularPrice['currency']];
  return '${currency}${regularPrice['value'].toString()}';
}

int certainPlatformGridCount() {
  var gridViewCount = 4;
  if (Platform.isIOS || Platform.isAndroid || Platform.isFuchsia) {
    gridViewCount = 2;
  }
  return gridViewCount;
}
