import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'myorder_screen.dart';
import 'signin_screen.dart';
import 'SignInDetailsModel.dart';

class AccountsTabs extends StatelessWidget {
  AccountsTabs({Key key}) : super(key: key);

  final String customerQuery = '''
  {
    customer {
      firstname
      lastname
      email
    }
  }
  ''';

  final String revokeToken = '''
  mutation {
    revokeCustomerToken {
      result
    }
  }
  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account'),
      ),
      body: accountsBody(context),
    );
  }

  Widget accountsBody(BuildContext context) {
    final signIn = Provider.of<SignInDetailsModel>(context);
    if (signIn.isCustomer) {
      return customer(context);
    }
    return guest(context);
  }

  Widget guest(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Logged in as Guest'),
            RaisedButton(
              child: Text('Sign in'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignInScreen()),
              ),
            )
          ],
        ),
      );

  Widget customer(BuildContext context) => Query(
        options: QueryOptions(documentNode: gql(customerQuery)),
        builder: (QueryResult result, {Refetch refetch, FetchMore fetchMore}) {
          if (result.hasException) {
            return Text(result.exception.toString());
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
                Text('${customer['firstname']} ${customer['lastname']}'),
                Text(customer['email']),
                Mutation(
                  options: MutationOptions(
                    documentNode: gql(revokeToken),
                    onCompleted: (data) async {
                      final result = data['revokeCustomerToken']['result'];
                      if (result) {
                        Scaffold.of(context).showSnackBar(
                          SnackBar(content: Text('Log out Succeeded!')),
                        );
                        Provider.of<SignInDetailsModel>(context, listen: false)
                            .signOff();
                        var sharedPref = await SharedPreferences.getInstance();
                        await sharedPref.remove('customer');
                      }
                    },
                    onError: (error) {
                      Scaffold.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error.toString()),
                        ),
                      );
                    },
                  ),
                  builder: (RunMutation runMutation, QueryResult result) {
                    return RaisedButton(
                      child: Text('Log Out'),
                      onPressed: () {
                        runMutation({});
                      },
                    );
                  },
                ),
                RaisedButton(
                  child: Text('My Orders'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyOrderScreen()),
                  ),
                )
              ],
            ),
          );
        },
      );
}
