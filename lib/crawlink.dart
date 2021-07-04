library crawlink;

import 'package:flutter/widgets.dart';

/// Imparative way Url navigator based on Flutter Navigator 2.0
class Crawlink extends InheritedWidget {
  late final CrawlinkRouteInformationParser routeInformationParser;
  late final CrawlinkRouterDelegate routerDelegate;

  /// List of routers to be register
  /// eg.
  ///
  /// ```dart
  /// ```
  final List<CrawlinkRouter> routers;

  final CrawlinkRouter? fallbackRouter;
  final _ValueHolder<Crawlink> _previousCrawlink = _ValueHolder<Crawlink>();

  Crawlink({
    Key? key,
    required BuildContext context,
    required Builder builder,
    required this.routers,
    this.fallbackRouter,
  }) : super(
          key: key,
          child: builder,
        ) {
    routeInformationParser = CrawlinkRouteInformationParser(this);
    routerDelegate = CrawlinkRouterDelegate(this);
    _initPreviousCrawlink(context);
  }

  Future _initPreviousCrawlink(BuildContext context) async {
    // TODO : Workaround. Error: dependOnInheritedWidgetOfExactType<Crawlink>() or dependOnInheritedElement() was called before _UsersRouterPageState.initState() completed.
    // Execure in next frame.
    await Future.delayed(Duration.zero);
    _previousCrawlink._value = Crawlink.of(context);
  }

  String get activePath {
    String path = "";
    if (routerDelegate.currentConfiguration != null) {
      path = routerDelegate.currentConfiguration!.location;
    }
    return CrawlinkRoutePath.sanitizeUrl('$path');
  }

  String get rootPath {
    String path = "";
    if (_previousCrawlink._value != null) {
      path = _previousCrawlink._value!.activePath;
    }
    return CrawlinkRoutePath.sanitizeUrl('$path');
  }

  /// Return Crawlink nearest [Crawlink] instance
  static Crawlink? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Crawlink>();

  void push(BuildContext context, String url,
      {Map<String, String> params = const {}, Map<String, dynamic>? data}) {
    var sanitizedUrl = CrawlinkRoutePath.sanitizeUrl(url);
    CrawlinkRoutePath path =
        CrawlinkRoutePath('$sanitizedUrl', params: params, data: data);
    routerDelegate.push(path);
  }

  void pop(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
}

class _ValueHolder<T> {
  T? _value;
}

/// Router trigger infromation
class CrawlinkRouter {
  /// URL for routing
  /// * e.g.
  ///
  /// ```dart
  /// url: '/'
  /// ```
  /// ```dart
  /// url: '/root/path/:id/view'
  /// ```
  final String url;

  /// Trigger when new url pushed to the navigator,
  /// Return [List<Page>]
  ///
  /// * e.g.
  ///
  /// ```dart
  /// onPush: (CrawlinkRoutePath path) => <Page>[HomePage(path:path)]
  /// ```
  final List<Page> Function(CrawlinkRoutePath path) onPages;

  /// Check the router path and return new path if check failed.
  /// Return a [CrawlinkRoutePath] path from onPush to navigate
  /// Return the same path parameter if no change on the route navigation.
  ///
  /// * e.g.
  ///
  /// ##### Default navigation
  /// ```dart
  /// onPush : (CrawlinkRoutePath path) async => path;
  /// ```
  /// ##### Custome navigation
  /// ```dart
  /// onPush : (CrawlinkRoutePath path) async {
  ///     // Do something
  ///     // Construct new path if required
  ///   return new CrawlinkRoutePath(url:<new Url>, params:<new parms>, data: <new data>)
  /// }
  /// ```
  final Future<CrawlinkRoutePath> Function(CrawlinkRoutePath path)? onPush;

  /// Override default back routing implementation.
  /// Return a [CrawlinkRoutePath] path from onPop to navigate
  /// Return the same path parameter if not change on back navigation.
  ///
  /// This function need to implement on back navigation from deep link page.
  ///
  /// * e.g.
  ///
  /// ##### Default back navigation
  /// ```dart
  /// onPop : (CrawlinkRoutePath path) => path;
  /// ```
  /// ##### Default back navigation
  /// ```dart
  /// onPop : (CrawlinkRoutePath path) {
  ///     // Do something
  ///     // Construct new path if required
  ///   return new CrawlinkRoutePath(url:<new Url>, params:<new parms>, data: <new data>)
  /// }
  /// ```
  final Future<CrawlinkRoutePath> Function(CrawlinkRoutePath path)? onPop;

  /// Resolve route data before actual navigation, this data can be retrived
  /// `path.data` in onPush
  ///
  /// * e.g.
  /// ```dart
  /// onResolve: (
  ///   CrawlinkRoutePath path, Map<String, dynamic> data) async{
  ///       // Prepare data to before route
  ///       // ...
  ///
  ///        return data;
  ///   }
  /// ```
  final Future<Map<String, dynamic>> Function(
      CrawlinkRoutePath path, Map<String, dynamic> data)? onResolve;

  /// Provide a router progress widget to display till route completed
  // final Page Function(  CrawlinkRoutePath path)?
  //     progressPage;

  late List<_CrawlinkPathSegment> _segments;
  late Map<int, _CrawlinkPathSegment> _segmentMap;

  late String _sanitizedUrl;

  CrawlinkRouter({
    required this.url,
    required this.onPages,
    this.onPush,
    this.onPop,
    this.onResolve,
    // this.progressPage,
  }) {
    // Refactor given path
    _sanitizedUrl = CrawlinkRoutePath.sanitizeUrl(url);
    _segments = CrawlinkRoutePath.urlToSegments(url);
    _segmentMap = _segments.asMap();
  }
}

class _CrawlinkPathSegment {
  late String _param;
  String? _value;
  _CrawlinkPathSegment(String param) {
    if (param.startsWith(':')) {
      _param = param.substring(1);
    } else {
      _param = param;
      _value = param;
    }
  }

  String get param => _param;
  String? get value => _value;
  set value(val) => _value = val;
}

/// Extract path information from location/url
class CrawlinkRoutePath {
  late List<_CrawlinkPathSegment> _segments;
  late Map<int, _CrawlinkPathSegment> _segmentMap;
  late Uri _uri;
  late String _sanitizedUrl;
  Map<String, String> _query = {};
  Map<String, String> _params = {};
  Map<String, dynamic>? data;
  CrawlinkRouter? _router;
  List<Page>? _pages;

  CrawlinkRoutePath(
    String url, {
    Map<String, String> params = const {},
    this.data,
  }) {
    _sanitizedUrl = sanitizeUrl(url);
    _uri = Uri.parse(_sanitizedUrl);
    _query.addAll(_uri.queryParameters);

    _segments = urlToSegments(_sanitizedUrl);
    _segments.forEach((segment) {
      if (segment._value == null) {
        segment._value = params[segment._param];
        params.remove(segment._param);
      }
    });
    _segmentMap = _segments.asMap();
    _query.addAll(params);

    // Add dynamic params in the url
    _sanitizedUrl =
        sanitizeUrl(_segments.map((segment) => segment._value).join('/'));
  }

  static String sanitizeUrl(String url) {
    var result =
        url.split('/').where((segment) => segment.trim().isNotEmpty).join('/');
    return '/$result';
  }

  static List<_CrawlinkPathSegment> urlToSegments(String url) {
    var result = url
        .split('/')
        .where((segment) => segment.trim().isNotEmpty)
        .map((segment) => _CrawlinkPathSegment(segment))
        .toList();
    return result;
  }

  /// The original location of route
  String get location => _sanitizedUrl;

  /// Parsed [Uri] from location
  Uri get uri => _uri;

  /// Path Segments
  // List<String> get segments => _segments;

  /// Path Params
  Map<String, String> get params => _params;

  /// Uri Query parameter
  Map<String, String> get query => _query;

  /// Return Path segment by index
  // String? getSegment(index) {
  //   if (_segments.length > index) return _segments[index];
  // }

  /// Check path segment of specific position
  bool hasSegment(index) {
    if (_segments.length > index) return true;
    return false;
  }

  /// Return get query string based on key
  String getQuery(String key) {
    return _query[key] ?? '';
  }

  /// Return get path params based on key
  String getParams(String key) {
    return _params[key] ?? '';
  }

  CrawlinkRouter? findRouter(Crawlink crawlink) {
    Map<String, String> params = {};
    CrawlinkRouter? result;
    try {
      CrawlinkRouter router = crawlink.routers.firstWhere((router) {
        params.clear();
        if (router._segmentMap.length == this._segmentMap.length) {
          for (int i = 0; i < router._segmentMap.length; i++) {
            if (router._segmentMap[i]!._param != this._segmentMap[i]!._param &&
                router._segmentMap[i]!._value != null) {
              return false;
            }
            if (router._segmentMap[i]!._value == null) {
              params[router._segmentMap[i]!._param] =
                  this._segmentMap[i]!._value!;
            }
          }
          return true;
        }
        return false;
      });
      this._params.clear();
      this._params.addAll(params);
      result = router;
    } catch (e) {}
    result = result ?? crawlink.fallbackRouter;
    this._router = result;
    return result;
  }

  @override
  String toString() {
    return _sanitizedUrl;
  }
}

/// CrawlinkRouteInformationParser convert the url to
/// [CrawlinkRoutePath]
class CrawlinkRouteInformationParser
    extends RouteInformationParser<CrawlinkRoutePath> {
  Crawlink crawlink;

  CrawlinkRouteInformationParser(this.crawlink);

  @override
  Future<CrawlinkRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    var path = CrawlinkRoutePath(routeInformation.location ?? '');
    return path;
  }

  @override
  RouteInformation restoreRouteInformation(CrawlinkRoutePath path) {
    var info = RouteInformation(
        location: CrawlinkRoutePath.sanitizeUrl(
            '${crawlink.rootPath}${path.location}'));
    return info;
  }
}

class CrawlinkRouterDelegate extends RouterDelegate<CrawlinkRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<CrawlinkRoutePath> {
  late final Crawlink crawlink;
  late final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  CrawlinkRoutePath? _path;

  CrawlinkRouterDelegate(this.crawlink) {
    print('CrawlinkRouterDelegate:init');
  }

  CrawlinkRoutePath? get currentConfiguration {
    return _path;
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  List<Page> get pages {
    if (_path != null) {
      return _path!._pages ?? [];
    }
    return [];
  }

  void push(path) async {
    _path = path;
    notifyListeners();
    await setNewRoutePath(path);
    notifyListeners();
  }

  pop() {
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    print('build: ${pages.length}');

    return pages.length > 0
        ? Navigator(
            key: _navigatorKey,
            pages: pages,
            onPopPage: (route, result) {
              if (!route.didPop(result)) {
                return false;
              }

              return true;
            })
        : Container();
  }

  @override
  Future<bool> popRoute() {
    return super.popRoute();
  }

  @override
  Future<void> setNewRoutePath(CrawlinkRoutePath path) async {
    CrawlinkRouter? router = path._router ?? path.findRouter(crawlink);
    if (router != null) {
      // Check new rout can be pushed or not
      if (router.onPush != null) {
        path = await router.onPush!(path);
      }

      // Resolve Data if required before route
      var data = path.data ?? {};
      if (router.onResolve != null) {
        data = await router.onResolve!(path, data);
      }

      // Get List of Pages to be render in UI
      var pages = router.onPages(path);

      path.data = data;
      path._router = router;
      path._pages = pages;

      _path = path;
    }
  }

  // _setNewPath(path, {bool replace = false}) {
  //   if (_oldPath != path) {
  //     _oldPath = path;
  //     _path = path;
  //     notifyListeners();
  //   }
  // }

  // void navigatePath(CrawlinkRoutePath path) {
  //   // print('HomeRouterDelegate: navigate : path = $path');
  //   _path = path;
  //   notifyListeners();
  // }

  // Future<CrawlinkRoutePath> navigate(String location,
  //     {Map<String, dynamic>? data, Map<String, String>? params}) async {
  //   // print('HomeRouterDelegate: navigateLocation : location = $location');
  //   var path = await routeParser
  //       .parseRouteInformation(RouteInformation(location: location));
  //   path.data = data;
  //   navigatePath(path);

  //   return path;
  // }
}

/// Extention of build context
extension BuildContextCrawlinkExtension on BuildContext {
  /// Current Route Infromation Parser
  CrawlinkRouteInformationParser? get routeInformationParser {
    var crawlink = Crawlink.of(this);
    if (crawlink != null) {
      return crawlink.routeInformationParser;
    }
  }

  /// Current Router Deligate
  CrawlinkRouterDelegate? get routerDelegate {
    var crawlink = Crawlink.of(this);
    if (crawlink != null) {
      return crawlink.routerDelegate;
    }
  }

  /// Current Back button Dispatcher
  // CrawlinkBackButtonDispatcher? get backButtonDispatcher {
  //   var crawlink = Crawlink.of(this);
  //   if (crawlink != null) {
  //     return crawlink.backButtonDispatcher;
  //   }
  // }
}
