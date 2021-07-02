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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Crawlink(
        builder: Builder(
          builder: (context) => MaterialApp.router(
              routeInformationParser: context.routeInformationParser,
              routerDelegate: context.routerDelegate),
        ),
        routers: [
          CrawlinkRouter(
            url: '/',
            onPush: (context, path) => <Page>[
              MaterialPage(child: HomePage()),
            ],
          ),
          CrawlinkRouter(
            url: '/users',
            onPush: (context, path) => <Page>[
              MaterialPage(child: HomePage()),
              MaterialPage(child: UsersPage()),
            ],
          ),
          CrawlinkRouter(
            url: '/users/:id',
            onPush: (context, path) => <Page>[
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
            onPush: (context, path) => <Page>[
              MaterialPage(child: HomePage()),
              MaterialPage(child: ProfilePage()),
            ],
          ),
          CrawlinkRouter(
            url: '/settings',
            onPush: (context, path) => <Page>[
              MaterialPage(child: HomePage()),
              MaterialPage(child: SettingsPage()),
            ],
          ),
        ]);
  }
}
