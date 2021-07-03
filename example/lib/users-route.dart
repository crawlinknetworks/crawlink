import 'package:crawlink/crawlink.dart';
import 'package:example/user.dart';
import 'package:example/users.dart';
import 'package:flutter/material.dart';

class UsersRouterPage extends StatefulWidget {
  @override
  _UsersRouterPageState createState() => _UsersRouterPageState();
}

class _UsersRouterPageState extends State<UsersRouterPage> {
  late Crawlink _crawlink;

  @override
  void initState() {
    super.initState();
    _crawlink = _initCrawlink();
  }

  @override
  Widget build(BuildContext context) {
    return _crawlink;
  }

  Crawlink _initCrawlink() {
    return Crawlink(
      context,
      builder: Builder(
        builder: (context) {
          return MaterialApp.router(
            routeInformationParser: context.routeInformationParser!,
            routerDelegate: context.routerDelegate!,
          );
        },
      ),
      routers: [
        CrawlinkRouter(
          context: context,
          url: "",
          onPush: (path) => [
            MaterialPage(child: UsersPage()),
          ],
        ),
        CrawlinkRouter(
          context: context,
          url: ":id",
          onPush: (path) => [
            MaterialPage(child: UserPage(path: path)),
          ],
        ),
      ],
    );
  }
}
