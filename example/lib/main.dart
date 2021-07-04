import 'package:crawlink/crawlink.dart';
import 'package:example/home.dart';
import 'package:example/profile.dart';
import 'package:example/settings.dart';
import 'package:example/user.dart';
import 'package:example/users.dart';
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
      context: context,
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
          url: '/',
          onPages: (path) => <Page>[
            MaterialPage(child: HomePage()),
          ],
        ),
        CrawlinkRouter(
          url: '/users',
          onPages: (path) => <Page>[
            MaterialPage(child: HomePage()),
            MaterialPage(child: UsersPage()),
          ],
        ),
        CrawlinkRouter(
          url: '/users/:id',
          onPages: (path) => <Page>[
            MaterialPage(child: HomePage()),
            MaterialPage(child: UsersPage()),
            MaterialPage(
                child: UserPage(
              path: path,
            )),
          ],
        ),
        CrawlinkRouter(
          url: '/profile',
          onPages: (path) => <Page>[
            MaterialPage(child: HomePage()),
            MaterialPage(child: ProfilePage()),
          ],
        ),
        CrawlinkRouter(
          url: '/settings',
          onPages: (path) => <Page>[
            MaterialPage(child: HomePage()),
            MaterialPage(child: SettingsPage()),
          ],
        ),
      ],
    );
  }
}
