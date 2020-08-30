import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:provider/provider.dart';

import 'start_screen.dart';
import 'SignInDetailsModel.dart';

void main() => runApp(
      ChangeNotifierProvider(
        create: (_) => SignInDetailsModel(),
        child: MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final model = Provider.of<SignInDetailsModel>(context);
    Link link;
    final httpLink = HttpLink(
      uri: 'http://139.162.47.20/magento233/graphql',
    );

    if (model.isCustomer) {
      final authLink = AuthLink(getToken: () => 'Bearer ${model.token}');
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
