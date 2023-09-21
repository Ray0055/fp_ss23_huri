import 'package:flutter/material.dart';
import 'package:logic_app/functions/DatabaseHelper.dart';
class CustomSearchDelegate extends SearchDelegate {

// first overwrite to
// clear the search text
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

// second overwrite to pop out of search menu
  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

// third overwrite to show query result
  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: DatabaseHelper.instance.getQuestionsByQuery(query), // 使用新方法
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final List<String>? results = snapshot.data;
          if (results == null || results.isEmpty) {
            return Text('No results found.');
          } else {
            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                var result = results[index];
                return ListTile(
                  title: Text(result),
                );
              },
            );
          }
        }
      },
    );
  }

// last overwrite to show the
// querying process at the runtime

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: DatabaseHelper.instance.getQuestionsByQuery(query), // 使用新方法
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          final List<String>? suggestions = snapshot.data;
          if (suggestions == null || suggestions.isEmpty) {
            return Text('No suggestions found.');
          } else {
            return ListView.builder(
              itemCount: suggestions.length,
              itemBuilder: (context, index) {
                var suggestion = suggestions[index];
                return ListTile(
                  title: Text(suggestion),
                  onTap: () {
                    // 您可以在这里添加点击建议后应执行的操作
                    query = suggestion;
                  },
                );
              },
            );
          }
        }
      },
    );
  }

}