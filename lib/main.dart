import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:magento_flutter/cart_provider.dart';
import 'package:provider/provider.dart';

import 'accounts_provider.dart';
import 'start_screen.dart';

void main() => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AccountsProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Link link;
    final httpLink = HttpLink(
      uri: 'https://devdemo.bsscommerce.com/magento234/default/graphql',
    );

    final provider = context.watch<AccountsProvider>();
    if (provider.isCustomer) {
      final authLink = AuthLink(getToken: () => 'Bearer ${provider.token}');
      link = authLink.concat(httpLink);
    } else {
      link = httpLink;
    }

    var client = ValueNotifier<GraphQLClient>(
      GraphQLClient(
        cache: InMemoryCache(),
        link: link,
      ),
    );

    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        title: 'Magento Shop',
        theme: ThemeData(
          // This is the theme of your application.
          primarySwatch: Colors.blue,
          // This makes the visual density adapt to the platform that you run
          // the app on. For desktop platforms, the controls will be smaller and
          // closer together (more dense) than on mobile platforms.
          visualDensity: VisualDensity.adaptivePlatformDensity,
          buttonColor: Colors.lightBlueAccent,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
        ),
        home: StartScreen(),
      ),
    );
  }
}
