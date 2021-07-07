import 'package:crawlink/crawlink.dart';
import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  final CrawlinkRoutePath path;
  UserPage({Key? key, required this.path}) : super(key: key) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User"),
      ),
      body: Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('User : ${path.queryParams['id']}'),
        ],
      )),
    );
  }
}
