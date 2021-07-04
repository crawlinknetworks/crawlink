import 'package:crawlink/crawlink.dart';
import 'package:flutter/material.dart';

class UsersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('User routes'),
            SizedBox(
              height: 16,
            ),
            TextButton(
                onPressed: () {
                  Crawlink.of(context)!
                      .push(context, '/users/:id', params: {'id': "1"});
                },
                child: Text('Open User 1')),
            SizedBox(
              height: 16,
            ),
            TextButton(
                onPressed: () {
                  Crawlink.of(context)!
                      .push(context, '/users/:id', params: {'id': "2"});
                },
                child: Text('Open User 2')),
            SizedBox(
              height: 16,
            ),
            TextButton(
                onPressed: () {
                  Crawlink.of(context)!
                      .push(context, '/users/:id', params: {'id': "3"});
                },
                child: Text('Open  User 3')),
          ],
        ),
      ),
    );
  }
}
