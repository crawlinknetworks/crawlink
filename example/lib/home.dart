import 'package:crawlink/crawlink.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Center(
          child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Home Page'),
          SizedBox(
            height: 16,
          ),
          TextButton(
              onPressed: () {
                Crawlink.of(context)!.push(context, '/profile');
              },
              child: Text('Open Profile')),
          SizedBox(
            height: 16,
          ),
          TextButton(
              onPressed: () {
                Crawlink.of(context)!.push(context, '/settings');
              },
              child: Text('Open Settings')),
          SizedBox(
            height: 16,
          ),
          TextButton(
              onPressed: () {
                Crawlink.of(context)!.push(context, '/users');
              },
              child: Text('Open Users')),
        ],
      )),
    );
  }
}
