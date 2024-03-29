import 'dart:async';

import 'package:crawlink/crawlink.dart';
import 'package:flutter/cupertino.dart';

/// Imparative way Url navigator based on Flutter Navigator 2.0
class CrawlinkNavigator extends InheritedWidget {
  final CrawlinkRouteInformationParser routeInformationParser;
  final CrawlinkRouterDelegate routerDelegate;
  final RootBackButtonDispatcher backButtonDispatcher;
  final PlatformRouteInformationProvider routeInformationProvider;

  /// List of routers to be register
  /// eg.
  ///
  /// ```dart
  /// ```
  final List<CrawlinkRouter> routers;

  /// Fallback router if not matched found
  final CrawlinkRouter? fallbackRouter;

  /// Set the screen breakpont to determine small screen, default: 576 (px).
  final int smallScreenWidth;

  // final _ValueHolder<Crawlink> _previousCrawlink = _ValueHolder<Crawlink>();

  final String initialPath;

  CrawlinkNavigator({
    Key? key,
    required Builder builder,
    required this.routers,
    required this.routeInformationParser,
    required this.routerDelegate,
    required this.backButtonDispatcher,
    required this.routeInformationProvider,
    this.fallbackRouter,
    this.initialPath = '/',
    this.smallScreenWidth = 576,
  }) : super(
          key: key,
          child: builder,
        ) {}

  /// Return Crawlink nearest [Crawlink] instance
  static CrawlinkNavigator of(BuildContext context) {
    CrawlinkNavigator? crawlink =
        context.dependOnInheritedWidgetOfExactType<CrawlinkNavigator>();

    assert(() {
      if (crawlink == null) {
        throw FlutterError(
          'Crawlink routing operation requested with a context that does not include a Crawlink Navigator initialized before.\n'
          'The context used to push or pop Crawlink routes from the Crawlink must be that of a '
          'widget that is a descendant of a Crawlink widget.',
        );
      }
      return true;
    }());

    return crawlink!;
  }

  Future<T?> push<T>(
    String path, {
    Map<String, String> params = const {},
    Map<String, dynamic> data = const {},
  }) async {
    CrawlinkRoutePath currentPath = CrawlinkRoutePath(
      activePath: path,
      initialPath: initialPath,
      params: params,
      data: data,
      completer: Completer<T>(),
    );

    routerDelegate.push(currentPath);

    if (currentPath.completer != null) {
      return await currentPath.completer!.future as Future<T>;
    }

    return null;
  }

  void pop<T>(T result) {
     routerDelegate.pop<T>(result);
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
}
