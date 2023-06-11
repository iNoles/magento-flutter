import 'package:flutter/material.dart';

Widget configurationOptions({
  dynamic item,
  required Map<String, String> options,
}) {
  var configurableOptions = item['configurable_options'];
  if (configurableOptions == null) {
    return Container();
  }
  var widgetList = <Widget>[];
  for (var option in configurableOptions) {
    widgetList.add(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: DropdownMenu<dynamic>(
          dropdownMenuEntries: option['values']
              .map<DropdownMenuEntry>((e) => DropdownMenuEntry(
                    value: e['label'],
                    label: e['label'],
                  ))
              .toList(),
          label: Text(option['label']),
          onSelected: (value) {
            options[option['label'].toLowerCase()] = value;
          },
        ),
      ),
    );
  }
  return Column(
    children: widgetList,
  );
}

String getVariantSku({dynamic data, required Map<String, String> options}) {
  var variantSku = '';
  var variants = data['variants'] as List;
  for (var variant in variants) {
    var attributes = variant['attributes'] as List;
    var zero = attributes
        .firstWhere((element) => element['code'] == options.keys.first);
    var first = attributes
        .firstWhere((element) => element['code'] == options.keys.last);
    if (zero['label'] == options.values.first &&
        first['label'] == options.values.last) {
      variantSku = variant['product']['sku'];
      break;
    }
  }
  return variantSku;
}
