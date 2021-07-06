# crawlink

A simple routing library for flutter apps based on Navigator 2.0

## Getting Started

<img src="https://github.com/crawlinknetworks/crawlink/blob/master/screenshots/crawlink_web_demo.gif?raw=true" alt="mobile_demo" style="max-width:340px;"/>
 
<img src="https://github.com/crawlinknetworks/crawlink/blob/master/screenshots/crawlink_mobile_demo.gif?raw=true" alt="mobile_demo" style="max-width:340px;"/>
 
## Install

#### pubspec.yaml
```
crawlink: <latest-version>
```

## Push a  route
Syntax:
```dart 
Crawlink.of(context).pushpush(
    String url, {
    Map<String, String> params = const {},
    Map<String, dynamic> data = const {},
  });
```

```dart
 
Crawlink.of(context).push('/' );

// or,

Crawlink.of(context).push('/users/:id', params: {'id': "1"}, data: {'user':<user>});
```

## Pop a  route

```
Crawlink.of(context)!.pop()
```

## Define a route

``` dart
CrawlinkRouter(
  url: '/',  
  onPages: (path) => <Page>[
    MaterialPage(child: HomePage()),
  ],
),
```

##  Full Example Usage

```dart
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
            backButtonDispatcher: context.backButtonDispatcher!,
            routeInformationProvider: context.routeInformationProvider!,
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
          onPush: (path) async => path,
          onPop: (path) => CrawlinkRoutePath('/users'),
          onResolve: (path, data) async => data,
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
