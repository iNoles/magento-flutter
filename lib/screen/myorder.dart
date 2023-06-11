import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class MyOrderScreen extends StatelessWidget {
  static const String query = """
  {
    customerOrders {
      items {
        order_number
        created_at
        grand_total
        status
      }
    }
  }
  """;

  const MyOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Orders'),
      ),
      body: Query(
        options: QueryOptions(document: gql(query)),
        builder: (result, {fetchMore, refetch}) {
          if (result.hasException) {
            return Text(result.exception.toString());
          }

          if (result.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          List items = result.data?['customerOrders']['items'];
          return ListView.separated(
            separatorBuilder: (context, index) => const Divider(),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Column(
                children: [
                  Text('Order # ${item['order_number']}'),
                  Text('Created: ${item['created_at']}'),
                  Text('Order Total: ${item['grand_total']}'),
                  Text('Status: ${item['status']}'),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
