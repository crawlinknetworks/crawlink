import 'package:crawlink/crawlink.dart';
import 'package:flutter/widgets.dart';

/// CrawlinkRouteInformationParser
class CrawlinkRouteInformationParser
    extends RouteInformationParser<CrawlinkRoutePath> {
  final String initialPath;

  CrawlinkRouteInformationParser({required this.initialPath});

  @override
  Future<CrawlinkRoutePath> parseRouteInformation(
      RouteInformation routeInformation) async {
    var activePath = routeInformation.location!.replaceFirst(initialPath, '');
    var path =
        CrawlinkRoutePath(activePath: activePath, initialPath: initialPath);
    return path;
  }

  @override
  RouteInformation restoreRouteInformation(CrawlinkRoutePath path) {
    var info = RouteInformation(
      location: path.absoluteUri.toString(),
    );

    return info;
  }
}
