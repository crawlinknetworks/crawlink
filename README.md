# crawlink

A simple routing library for flutter apps based on Navigator 2.0

## Getting Started

## Install

#### pubspec.yaml
```
crawlink: <latest-version>
```

##  Usage

```dart

void main() {
  setPathUrlStrategy();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key) {
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
          onPush: (path)=> path;
          onResolve(path, data) => data;
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

```

## CrawlinkRouter

```dart 
class CrawlinkRouter {
 
  final String url;

  final List<Page> Function(CrawlinkRoutePath path) onPages;

  final Future<CrawlinkRoutePath> Function(CrawlinkRoutePath path)? onPush;

  final CrawlinkRoutePath Function(CrawlinkRoutePath path)? onPop;
 
  final Future<Map<String, dynamic>> Function(CrawlinkRoutePath path, Map<String, dynamic> data)? onResolve;

}
```
