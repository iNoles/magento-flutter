import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import 'category.dart';

class CategoriesScreen extends StatelessWidget {
  CategoriesScreen({Key key}) : super(key: key);

  final String query = '''
{
  categoryList {
    children {
      id
      name
      children {
        id
        name
        children {
          id
          name
        }
      }
    }
  }
}
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
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

          List childrens = result.data['categoryList'][0]['children'];
          return ListView.builder(
            itemCount: childrens.length,
            itemBuilder: (context, index) {
              final children = childrens[index];
              return _buildTitles(context, children);
            },
          );
        },
      ),
    );
  }

  Widget _buildTitles(BuildContext context, dynamic children) {
    if (children['children'] == null) {
      return ListTile(
        title: Text(children['name']),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryScreen(
              title: children['name'],
              categoryId: children['id'],
            ),
          ),
        ),
      );
    }
    return ExpansionTile(
      key: PageStorageKey<dynamic>(children),
      title: Text(children['name'] ?? 'Empty'),
      children: children['children']
          .map<Widget>((e) => _buildTitles(context, e))
          .toList(),
    );
  }
}
