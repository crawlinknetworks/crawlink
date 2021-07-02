library crawlink;

import 'package:flutter/widgets.dart';

/// Imparative way Url navigator based on Flutter Navigator 2.0
class Crawlink extends InheritedWidget {
  final CrawlinkRouteInformationParser routeInformationParser =
      CrawlinkRouteInformationParser();
  final CrawlinkRouterDelegate routerDelegate = CrawlinkRouterDelegate();
  final List<CrawlinkRouter> routers;

  Crawlink({
    Key? key,
    required Builder builder,
    required this.routers,
  }) : super(key: key, child: builder) {}

  /// Return Crawlink nearest [Crawlink] instance
  static Crawlink? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Crawlink>();

  CrawlinkRouter? findRouter(CrawlinkRoutePath path) {
    Map<String, String> params = {};
    try {
      CrawlinkRouter router = this.routers.firstWhere((router) {
        params.clear();
        if (router._segmentMap.length == path._segmentMap.length) {
          for (int i = 0; i < router._segmentMap.length; i++) {
            if (router._segmentMap[i]!._segment !=
                    path._segmentMap[i]!._segment &&
                router._segmentMap[i]!._value != null) {
              return false;
            }
            if (router._segmentMap[i]!._value == null) {
              params[router._segmentMap[i]!._segment] =
                  path._segmentMap[i]!._value!;
            }
          }
          return true;
        }
        return false;
      });
      path._params.clear();
      path._params.addAll(params);
      return router;
    } catch (e) {}

    try {
      return routers.where((router) => router.url == '**').first;
    } catch (e) {}
    return null;
  }

  void push(String location,
      {Map<String, String> params = const {}, Map<String, dynamic>? data}) {
    CrawlinkRoutePath path =
        CrawlinkRoutePath(location, params: params, data: data);
    routerDelegate.push(path);
  }

  void pop() {
    routerDelegate.pop();
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
}

/// Router trigger infromation
class CrawlinkRouter {
  /// URL for routing
  /// eg. 'root/path/:id/view'
  String url;

  /// Trigger when new url pushed to the navigator,
  /// Return [List<MaterialPage>]
  final List<Page> Function(BuildContext context, CrawlinkRoutePath path)
      onPush;

  /// Override default back locatoin with custome.
  final Future<String> Function(BuildContext context, CrawlinkRoutePath path)?
      onPop;

  /// Check the new route can be allowed or not.
  final Future<bool> Function(BuildContext context, CrawlinkRoutePath path)?
      canPush;

  /// Resolve route data before actual navigation, this data can be retrived
  /// `path.data` in onPush
  final Future<Map<String, dynamic>> Function(
      BuildContext context, CrawlinkRoutePath path)? resolve;

  /// Provide a router progress widget to display till route completed
  final Page Function(BuildContext context, CrawlinkRoutePath path)?
      progressPage;

  late List<_CrawlinkPathSegment> _segments;
  late Map<int, _CrawlinkPathSegment> _segmentMap;

  CrawlinkRouter({
    required this.url,
    required this.onPush,
    this.onPop,
    this.canPush,
    this.resolve,
    this.progressPage,
  }) {
    _segments = url
        .split('/')
        .where((segment) => segment.isNotEmpty)
        .map((segment) => _CrawlinkPathSegment(segment))
        .toList();
    _segmentMap = _segments.asMap();
  }
}

class _CrawlinkPathSegment {
  late String _segment;
  String? _value;
  _CrawlinkPathSegment(String segment) {
    if (segment.startsWith(':')) {
      _segment = segment.substring(1);
    } else {
      _segment = segment;
      _value = segment;
    }
  }

  String get segment => _segment;
  String? get value => _value;
  set value(val) => _value = val;
}

/// Extract path information from location/url
class CrawlinkRoutePath {
  late List<_CrawlinkPathSegment> _segments;
  late Map<int, _CrawlinkPathSegment> _segmentMap;
  late Uri _uri;
  late String _location;
  Map<String, String> _query = {};
  Map<String, String> _params = {};
  Map<String, dynamic>? data;

  CrawlinkRoutePath(String location,
      {Map<String, String> params = const {}, this.data}) {
    _uri = Uri.parse(location);
    _query.addAll(_uri.queryParameters);
    _segments = _uri.pathSegments
        .where((segment) => segment.isNotEmpty)
        .map((segment) => _CrawlinkPathSegment(segment))
        .toList();

    _segments.forEach((segment) {
      if (segment._value == null) {
        segment._value = params[segment._segment];
        params.remove(segment._segment);
      }
    });
    _segmentMap = _segments.asMap();
    _query.addAll(params);

    _location = _segments.map((segment) => segment._value).toList().join('/');
  }

  /// The original location of route
  String get location => _location;

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

  @override
  String toString() {
    return _location;
  }
}

/// CrawlinkRouteInformationParser convert the url to
/// [CrawlinkRoutePath]
class CrawlinkRouteInformationParser
    extends RouteInformationParser<CrawlinkRoutePath> {
  @override
  Future<CrawlinkRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    return CrawlinkRoutePath(routeInformation.location ?? '');
  }

  @override
  RouteInformation restoreRouteInformation(CrawlinkRoutePath path) {
    return RouteInformation(location: path.location);
  }
}

class CrawlinkRouterDelegate extends RouterDelegate<CrawlinkRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<CrawlinkRoutePath> {
  final GlobalKey<NavigatorState> navigatorKey;
  // final CrawlinkRouteInformationParser routeParser;
  CrawlinkRoutePath? _oldPath;
  CrawlinkRoutePath _path = CrawlinkRoutePath('');
  List<CrawlinkRoutePath> _paths = [];

  List<Page> _pages = [];

  CrawlinkRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  ValueNotifier<List<Page>> _pagesNotifier = ValueNotifier<List<Page>>([]);

  CrawlinkRoutePath get currentConfiguration {
    return _path;
  }

  void push(path) {
    _path = path;
    notifyListeners();
  }

  pop() {
    _paths.removeLast();
    _path = _paths.removeLast();
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    print('build');
    Crawlink? crawlink = Crawlink.of(context);
    Page? progressPage;
    if (crawlink != null) {
      CrawlinkRouter? router = crawlink.findRouter(_path);
      if (router != null) {
        if (router.progressPage != null) {
          progressPage = router.progressPage!(context, _path);
        }
        if (router.canPush != null) {
          router.canPush!(context, _path).then((canPush) async {
            if (canPush) {
              if (router.resolve != null) {
                return await router.resolve!(context, _path);
              }
            } else {
              if (_oldPath != null) {
                _setNewPath(_oldPath!, replace: true);
              }
              _pagesNotifier.value = _pages;
            }
            return null;
          }).then((Map<String, dynamic>? data) async {
            if (data != null) {
              var pages = router.onPush(context, _path);
              _setNewPath(_path);
              return pages;
            } else {
              return _pages;
            }
          }).then((pages) {
            progressPage = null;
            _pagesNotifier.value = pages;
          }).onError((e, stackTrace) => throw e!);
        } else {
          progressPage = null;
          _pagesNotifier.value = router.onPush(context, _path);
          _setNewPath(_path);
        }
      }
    }

    return ValueListenableBuilder(
        valueListenable: _pagesNotifier,
        builder: (context, List<Page> pages, child) {
          var pageList = progressPage != null
              ? [..._pages, progressPage!]
              : pages.length > 0
                  ? pages
                  : _pages;
          return pageList.length <= 0
              ? Container()
              : Navigator(
                  key: navigatorKey,
                  pages: pageList,
                  onPopPage: (route, result) {
                    if (!route.didPop(result)) {
                      return false;
                    }
                    pop();
                    return true;
                  });
        });
  }

  @override
  Future<void> setNewRoutePath(CrawlinkRoutePath path) async {
    _setNewPath(path);
  }

  _setNewPath(path, {bool replace = false}) {
    if (_oldPath != path) {
      _oldPath = path;
      _path = path;
      if (replace && _paths.length > 0) {
        _paths[_paths.length - 1] = path;
      } else {
        _paths.add(path);
      }
    }
  }

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
  CrawlinkRouteInformationParser get routeInformationParser {
    var crawlink = Crawlink.of(this);
    return crawlink!.routeInformationParser;
  }

  /// Current Router Deligate
  CrawlinkRouterDelegate get routerDelegate =>
      Crawlink.of(this)!.routerDelegate;
}
