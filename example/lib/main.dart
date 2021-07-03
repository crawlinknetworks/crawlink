import 'package:crawlink/crawlink.dart';
import 'package:example/home.dart';
import 'package:example/profile.dart';
import 'package:example/settings.dart';
import 'package:example/users-route.dart';
import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';

void main() {
  setPathUrlStrategy();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key) {
    print('MyApp:init');
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Crawlink _crawlink;

  @override
  void initState() {
    super.initState();
    _crawlink = _initCrawlink();
  }

  @override
  Widget build(BuildContext context) {
    print('MyApp : build');
    return _crawlink;
  }

  _initCrawlink() {
    return Crawlink(
      builder: Builder(
        builder: (context) {
          // print('MyApp : builder');
          return MaterialApp.router(
            routeInformationParser: context.routeInformationParser!,
            routerDelegate: context.routerDelegate!,
          );
        },
      ),
      routers: [
        CrawlinkRouter(
          context: context,
          url: '/',
          onPush: (path) => <Page>[
            MaterialPage(child: HomePage()),
          ],
        ),
        CrawlinkRouter(
          context: context,
          url: '/users',
          onPush: (path) => <Page>[
            MaterialPage(child: HomePage()),
            MaterialPage(child: UsersRouterPage()),
          ],
        ),
        // CrawlinkRouter(
        //   url: '/users/:id',
        //   onPush: (context, path) => <Page>[
        //     MaterialPage(child: HomePage()),
        //     MaterialPage(child: UsersPage()),
        //     MaterialPage(
        //         child: UserPage(
        //       path: path,
        //     )),
        //   ],
        // ),
        CrawlinkRouter(
          context: context,
          url: '/profile',
          onPush: (path) => <Page>[
            MaterialPage(child: HomePage()),
            MaterialPage(child: ProfilePage()),
          ],
        ),
        CrawlinkRouter(
          context: context,
          url: '/settings',
          onPush: (path) => <Page>[
            MaterialPage(child: HomePage()),
            MaterialPage(child: SettingsPage()),
          ],
        ),
      ],
    );
  }
}
