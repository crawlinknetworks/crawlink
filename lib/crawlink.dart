library crawlink;

import 'package:flutter/widgets.dart';

/// Imparative way Url navigator based on Flutter Navigator 2.0
class Crawlink extends InheritedWidget {
  final CrawlinkRouteInformationParser routeInformationParser =
      CrawlinkRouteInformationParser();
  final CrawlinkRouterDelegate routerDelegate = CrawlinkRouterDelegate();
  final List<CrawlinkRouter> routers;

  final CrawlinkRouter? fallbackRouter;

  Crawlink({
    Key? key,
    required BuildContext context,
    required Builder builder,
    required this.routers,
    this.fallbackRouter,
  }) : super(
          key: key,
          child: builder,
        ) {}

  String get activePath {
    String path =
        routerDelegate.currentConfiguration.uri.pathSegments.join('/');
    return '/$path';
  }

  /// Return Crawlink nearest [Crawlink] instance
  static Crawlink? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<Crawlink>();

  void push(String location,
      {Map<String, String> params = const {}, Map<String, dynamic>? data}) {
    // Sanitized route url
    location = location
        .split('/')
        .where((segment) => segment.trim().isNotEmpty)
        .join();

    // add '/' at begining of the location
    CrawlinkRoutePath path =
        CrawlinkRoutePath('/$location', params: params, data: data);
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
  final String url;

  // String _fullUrl;

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

  late String _absolutePath;
  late String _sanitizedUrl;

  CrawlinkRouter({
    required BuildContext context,
    required this.url,
    required this.onPush,
    this.onPop,
    this.canPush,
    this.resolve,
    this.progressPage,
  }) {
    // Refactor given path
    _sanitizedUrl = CrawlinkRoutePath.sanitizeUrl(url);
    _segments = CrawlinkRoutePath.urlToSegments(url);
    _segmentMap = _segments.asMap();

    // Find absolute path of the url
    String rootPath = '';
    Crawlink? previous = Crawlink.of(context);
    if (previous != null) {
      rootPath = previous.activePath;
    }
    _absolutePath = '$rootPath$_sanitizedUrl';
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

  CrawlinkRoutePath(String location,
      {Map<String, String> params = const {}, this.data}) {
    _sanitizedUrl = sanitizeUrl(location);
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
  @override
  Future<CrawlinkRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    var path = CrawlinkRoutePath(routeInformation.location ?? '');
    return path;
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
  // List<CrawlinkRoutePath> _paths = [];

  List<Page> _pages = [];

  CrawlinkRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  ValueNotifier<List<Page>> _pagesNotifier = ValueNotifier<List<Page>>([]);

  // int _counter = 0;

  CrawlinkRoutePath get currentConfiguration {
    return _path;
  }

  void push(path) {
    _path = path;
    notifyListeners();
  }

  pop() {
    // _paths.removeLast();
    // _path = _paths.removeLast();
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    // print('build : ${_counter++}');
    Crawlink? crawlink = Crawlink.of(context);
    Page? progressPage;
    if (crawlink != null) {
      CrawlinkRouter? router = _path._router ?? _path.findRouter(crawlink);
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
      // if (replace && _paths.length > 0) {
      //   _paths[_paths.length - 1] = path;
      // } else {
      //   _paths.add(path);
      // }
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
}
