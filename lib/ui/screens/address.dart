import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AddressScreen extends StatelessWidget {
  final String query = '''
  {
    customer {
      addresses {
        firstname
        lastname
        street
        city
        region {
          region
        }
        telephone
      }
    }
  }
  ''';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Addresses'),
      ),
      body: Query(
        options: QueryOptions(document: gql(query)),
        builder: (result, {fetchMore, refetch}) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List addresses = result.data['customer']['addresses'];
          return ListView.builder(
            itemCount: addresses.length,
            itemBuilder: (context, index) {
              var address = addresses[index];
              return Card(
                child: Column(
                  children: [
                    Text('${address['firstname']} ${address['lastname']}'),
                    Text('${address['street'][0]} ${address['street'][1]}'),
                    Text('${address['city']}'),
                    Text('${address['region']['region']}'),
                    Text('${address['telephone']}')
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
