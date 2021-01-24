import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../widget/form_builder_text_field.dart';
import '../widget/form_builder.dart';

class CheckoutAddressScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Billing & Shipping Address'),
      ),
      body: SingleChildScrollView(
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: [
              FormBuilderTextField(
                name: 'first_name',
                decoration: InputDecoration(
                  labelText: 'First Name',
                ),
              ),
              FormBuilderTextField(
                name: 'last_name',
                decoration: InputDecoration(
                  labelText: 'Last Name',
                ),
              ),
              FormBuilderTextField(
                name: 'phone_number',
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                ),
              ),
              FormBuilderTextField(
                name: 'street_address',
                decoration: InputDecoration(
                  labelText: 'Street Address',
                ),
              ),
              FormBuilderTextField(
                name: 'city',
                decoration: InputDecoration(
                  labelText: 'City',
                ),
              ),
              FormBuilderTextField(
                name: 'state',
                decoration: InputDecoration(
                  labelText: 'State',
                ),
              ),
              FormBuilderTextField(
                name: 'zip_code',
                decoration: InputDecoration(
                  labelText: 'Zip Code',
                ),
              ),
              /*FormBuilderCountryPicker(
                attribute: 'county',
                decoration: InputDecoration(
                  labelText: 'Country',
                ),
              )*/
            ],
          ),
        ),
      ),
    );
  }
}
