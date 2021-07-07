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

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('MyApp : build');
    return Crawlink(
      key: ValueKey('MainCrawlink'),
      builder: (context) {
        return MaterialApp.router(
          routeInformationParser: context.routeInformationParser,
          routerDelegate: context.routerDelegate,
          backButtonDispatcher: context.backButtonDispatcher,
          routeInformationProvider: context.routeInformationProvider,
        );
      },
      routers: [
        CrawlinkRouter(
          path: '/',
          onPages: (path) => <Page>[
            MaterialPage(child: HomePage()),
          ],
        ),
        CrawlinkRouter(
          path: '/users',
          onPages: (path) => <Page>[
            MaterialPage(child: HomePage()),
            MaterialPage(child: UsersPage()),
          ],
          onPush: (path) async => path,
          onResolve: (path, data) async => data,
        ),
        CrawlinkRouter(
          path: '/users/:id',
          onPages: (path) => <Page>[
            MaterialPage(child: HomePage()),
            MaterialPage(child: UsersPage()),
            MaterialPage(
                child: UserPage(
              path: path,
            )),
          ],
          onPush: (path) async => path,
          onResolve: (path, data) async => data,
        ),
        CrawlinkRouter(
          path: '/profile',
          onPages: (path) => <Page>[
            MaterialPage(child: HomePage()),
            MaterialPage(child: ProfilePage()),
          ],
          onPush: (path) async => path,
          onResolve: (path, data) async => data,
        ),
        CrawlinkRouter(
          path: '/settings',
          onPages: (path) => <Page>[
            MaterialPage(child: HomePage()),
            MaterialPage(child: SettingsPage()),
          ],
          onPush: (path) async => path,
          onResolve: (path, data) async => data,
        ),
      ],
    );
  }
}
