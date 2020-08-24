import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class AccountsTabs extends StatelessWidget {
  AccountsTabs({Key key}) : super(key: key);

  final String query = '''
  {
    customer {
      firstname
      lastname
      email
    }
  }
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
      ),
      body: Query(
        options: QueryOptions(documentNode: gql(query)),
        builder: (QueryResult result, {Refetch refetch, FetchMore fetchMore}) {
          if (result.hasException) {
            return Align(
              alignment: Alignment.topCenter,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Logged in as Guest'),
                  RaisedButton(
                    child: Text('Sign in'),
                    onPressed: null,
                  )
                ],
              ),
            );
          }
          if (result.loading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          dynamic customer = result.data['customer'];
          return Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                Text('Contact Information'),
                Row(
                  children: [
                    Text(customer['firstname']),
                    Text(customer['lastname']),
                  ],
                ),
                Text(customer['email']),
                RaisedButton(
                  child: Text('Log Out'),
                  onPressed: null,
                ),
                RaisedButton(
                  child: Text('My Order'),
                  onPressed: null,
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
