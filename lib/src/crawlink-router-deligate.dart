import 'package:crawlink/crawlink.dart';
import 'package:flutter/material.dart';

class CrawlinkRouterDelegate extends RouterDelegate<CrawlinkRoutePath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<CrawlinkRoutePath> {
  // late final CrawlinkNavigator crawlink;
  late final GlobalKey<NavigatorState> _navigatorKey =
      GlobalKey<NavigatorState>();

  CrawlinkRoutePath? _path;

  final List<CrawlinkRouter> routers;
  final CrawlinkRouter? fallbackRouter;
  final RouteInformationProvider routeInformationProvider;

  CrawlinkRouterDelegate(
      {required this.routers,
      this.fallbackRouter,
      required this.routeInformationProvider}) {}

  CrawlinkRoutePath? get currentConfiguration {
    return _path;
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  List<Page> get pages {
    if (_path != null) {
      return _path!.pages ?? [];
    }
    return [];
  }

  void push(CrawlinkRoutePath path) async {
    path.historyPath = _path;
    _path = path;
    notifyListeners();
    await setNewRoutePath(path);
    notifyListeners();
  }

  void pop<T>(T result) async {
    assert(_path!.historyPath == null);
    _path = _path!.historyPath!;
    if (_path!.completer != null) {
      _path!.completer!.complete(result);
    }
    notifyListeners();
    await setNewRoutePath(_path!);
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen with
    // if (_path != null) {
    //   _path!.screenSize = MediaQuery.of(context).size;
    //   _path!.isSmallScreen =
    //       _path!.screenSize!.width < crawlink.smallScreenWidth;
    // }

    return pages.length > 0
        ? Navigator(
            key: _navigatorKey,
            pages: pages,
            onPopPage: (route, result) {
              if (!route.didPop(result)) {
                return false;
              }

              handleOnPopPage(_path!);
              return true;
            })
        : Container();
  }

  @override
  Future<void> setInitialRoutePath(CrawlinkRoutePath configuration) {
    return setNewRoutePath(configuration);
  }

  @override
  Future<void> setNewRoutePath(CrawlinkRoutePath path) async {
    CrawlinkRouter? router = path.router ?? _findRouter(path);
    if (router != null) {
      // Check new rout can be pushed or not
      if (router.onPush != null) {
        path = await router.onPush!(path);
      }

      var data = path.data;
      if (router.onResolve != null) {
        data = await router.onResolve!(path, data);
      }

      // Get List of Pages to be render in UI
      var pages = router.onPages(path);

      path.data = data;
      path.router = router;
      path.pages = pages;

      _path = path;
    }
  }

  CrawlinkRouter? _findRouter(CrawlinkRoutePath path) {
    CrawlinkRouter? result;
    try {
      result = routers.firstWhere((router) {
        if (router.machableUri.pathSegments.length ==
            path.machableUri.pathSegments.length) {
          for (int i = 0; i < router.machableUri.pathSegments.length; i++) {
            String segment = path.machableUri.pathSegments[i];
            if (segment.startsWith(":")) {
              // Dynamic variable check
            } else if (router.machableUri.pathSegments[i] !=
                path.machableUri.pathSegments[i]) {
              return false;
            }
          }
          return true;
        }
        return false;
      });
    } catch (e) {}
    result = result ?? fallbackRouter;
    path.router = result;
    return result;
  }

  void handleOnPopPage(CrawlinkRoutePath path) async {
    if (path.historyPath != null) {
      routeInformationProvider.routerReportsNewRouteInformation(
          _path!.historyPath!.routeInformation);
      _path = path.historyPath;
      notifyListeners();
    }
  }
}
