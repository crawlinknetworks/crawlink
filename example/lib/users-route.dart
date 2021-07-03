import 'package:crawlink/crawlink.dart';
import 'package:example/user.dart';
import 'package:example/users.dart';
import 'package:flutter/material.dart';

class UsersRouterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Crawlink(
        context: context,
        builder: Builder(
          builder: (context) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 200,
                    child: MaterialApp.router(
                      routeInformationParser: context.routeInformationParser!,
                      routerDelegate: context.routerDelegate!,
                    ),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  TextButton(
                      onPressed: () {
                        Crawlink.of(context)!.push(':id', params: {'id': "1"});
                      },
                      child: Text('Open User 1')),
                  SizedBox(
                    height: 16,
                  ),
                  TextButton(
                      onPressed: () {
                        Crawlink.of(context)!.push(':id', params: {'id': "2"});
                      },
                      child: Text('Open User 2')),
                  SizedBox(
                    height: 16,
                  ),
                  TextButton(
                      onPressed: () {
                        Crawlink.of(context)!.push(':id', params: {'id': "3"});
                      },
                      child: Text('Open  User 3')),
                ],
              ),
            );
          },
        ),
        routers: [
          CrawlinkRouter(
            context: context,
            url: "",
            onPush: (context, path) => [
              MaterialPage(child: UsersPage()),
            ],
          ),
          CrawlinkRouter(
            context: context,
            url: ":id",
            onPush: (context, path) => [
              MaterialPage(child: UserPage(path: path)),
            ],
          ),
        ],
      ),
    );
  }
}
