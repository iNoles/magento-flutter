import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'start_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final httpLink = HttpLink(
      uri: 'http://mage2.local/graphql',
    );
    var client = ValueNotifier<GraphQLClient>(
      GraphQLClient(
        cache: InMemoryCache(),
        link: httpLink,
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
