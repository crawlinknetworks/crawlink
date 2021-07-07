import 'package:crawlink/crawlink.dart';
import 'package:crawlink/src/crawlink-navigator.dart';
import 'package:flutter/widgets.dart';

class Crawlink extends StatefulWidget {
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

  final Widget Function(BuildContext context) builder;

  Crawlink({
    required Key key,
    required this.builder,
    required this.routers,
    this.fallbackRouter,
    this.initialPath = '/',
    this.smallScreenWidth = 576,
  }) : super(
          key: key,
        ) {}

  @override
  CrawlinkState createState() => CrawlinkState();

  static CrawlinkNavigator of(BuildContext context) {
    return CrawlinkNavigator.of(context);
  }
}

class CrawlinkState extends State<Crawlink> {
  late final CrawlinkRouteInformationParser _routeInformationParser;
  late final CrawlinkRouterDelegate _routerDelegate;
  late final RootBackButtonDispatcher _backButtonDispatcher;
  late final PlatformRouteInformationProvider _routeInformationProvider;

  late final void Function() _routeInformationProviderCallback;

  late final Future<bool> Function() _backButtonDispatcherCallback;

  @override
  void initState() {
    super.initState();

    _routeInformationParser =
        CrawlinkRouteInformationParser(initialPath: widget.initialPath);
    _routerDelegate = CrawlinkRouterDelegate(
        routers: widget.routers, fallbackRouter: widget.fallbackRouter);
    _backButtonDispatcher = RootBackButtonDispatcher();
    _routeInformationProvider = PlatformRouteInformationProvider(
      initialRouteInformation: RouteInformation(location: widget.initialPath),
    );

    _routeInformationProviderCallback = () {
      print('_routeInformationProviderCallback');
      // _routeInformationProvider.routerReportsNewRouteInformation(routeInformation)
    };

    _backButtonDispatcherCallback = () async {
      print('_backButtonDispatcherCallback');
      return false;
    };

    _routeInformationProvider.addListener(_routeInformationProviderCallback);
    _backButtonDispatcher.addCallback(_backButtonDispatcherCallback);
  }

  @override
  void dispose() {
    super.dispose();
    _routeInformationProvider.removeListener(_routeInformationProviderCallback);
    _backButtonDispatcher.removeCallback(_backButtonDispatcherCallback);
  }

  @override
  Widget build(BuildContext context) {
    return CrawlinkNavigator(
      builder: Builder(
        builder: widget.builder,
      ),
      routers: widget.routers,
      routeInformationParser: _routeInformationParser,
      routerDelegate: _routerDelegate,
      backButtonDispatcher: _backButtonDispatcher,
      routeInformationProvider: _routeInformationProvider,
      initialPath: widget.initialPath,
      smallScreenWidth: widget.smallScreenWidth,
    );
  }
}
