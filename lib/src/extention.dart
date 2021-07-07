import 'package:crawlink/crawlink.dart';
import 'package:crawlink/src/crawlink-information-parser.dart';
import 'package:flutter/widgets.dart';

/// Extention of build context
extension BuildContextCrawlinkExtension on BuildContext {
  /// Current Route Infromation Parser
  CrawlinkRouteInformationParser get routeInformationParser {
    var crawlink = Crawlink.of(this);
    return crawlink.routeInformationParser;
  }

  /// Current Router Deligate
  CrawlinkRouterDelegate get routerDelegate {
    var crawlink = Crawlink.of(this);
    return crawlink.routerDelegate;
  }

  BackButtonDispatcher get backButtonDispatcher {
    var crawlink = Crawlink.of(this);
    return crawlink.backButtonDispatcher;
  }

  RouteInformationProvider get routeInformationProvider {
    var crawlink = Crawlink.of(this);
    return crawlink.routeInformationProvider;
  }
}
