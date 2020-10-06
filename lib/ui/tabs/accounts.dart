import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/address.dart';
import '../screens/myorder.dart';
import '../screens/signin.dart';
import '../../providers/accounts.dart';
import '../../utils.dart';
import '../screens/wishlist.dart';

class AccountsTabs extends StatelessWidget {
  final String customerQuery = '''
  {
    customer {
      firstname
      lastname
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
        title: Text('Profile'),
      ),
      body: accountsBody(context),
    );
  }

  Widget accountsBody(BuildContext context) {
    final isLoggedOn =
        context.select<AccountsProvider, bool>((value) => value.isCustomer);
    if (isLoggedOn) {
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
            ElevatedButton(
              child: Text('Sign in'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SignInScreen()),
              ),
            )
          ],
        ),
      );

  Widget _buildCoverImage(Size screenSize) {
    return Container(
      height: screenSize.height / 2.6,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/profile_cover.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

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
          var screenSize = MediaQuery.of(context).size;
          return SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    _buildCoverImage(screenSize),
                    Column(
                      children: [
                        SizedBox(height: screenSize.height / 6.4),
                        _buildProfileImage(),
                        Text(
                          '${customer['firstname']} ${customer['lastname']}',
                        ),
                      ],
                    )
                  ],
                ),
                Card(
                  child: ListTile(
                    title: Text('Orders'),
                    subtitle: Text('Check your order status'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => MyOrderScreen()),
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text('Address'),
                    subtitle: Text('Save address for hassle-free checkout'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AddressScreen()),
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    title: Text('Wishlist'),
                    subtitle: Text('Check your wishlists'),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => WishlistScreen()),
                    ),
                  ),
                ),
                Mutation(
                  options: MutationOptions(
                    documentNode: gql(revokeToken),
                    onCompleted: (data) async {
                      final result = data['revokeCustomerToken']['result'];
                      if (result) {
                        Scaffold.of(context).showSnackBar(
                          SnackBar(content: Text('Log out Succeeded!')),
                        );
                        Provider.of<AccountsProvider>(context, listen: false)
                            .signOff();
                        var sharedPref = await SharedPreferences.getInstance();
                        await sharedPref.remove('customer');
                        await getCart(context);
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
                    return ElevatedButton(
                      child: Text('Logout'),
                      onPressed: () {
                        runMutation({});
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
      );

  Widget _buildProfileImage() {
    return Center(
      child: Container(
        width: 140.0,
        height: 140.0,
        decoration: BoxDecoration(
          /*image: DecorationImage(
            image: AssetImage('assets/images/nickfrost.jpg'),
            fit: BoxFit.cover,
          ),*/
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: Colors.white,
            width: 10.0,
          ),
        ),
      ),
    );
  }
}
